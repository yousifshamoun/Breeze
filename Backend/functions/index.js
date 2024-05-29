const { onRequest } = require('firebase-functions/v2/https');
const { OpenAIApi, Configuration } = require('openai');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { log } = require('firebase-functions/logger');
const os = require('os');
const path = require('path');
const fs = require('fs');
var easyinvoice = require('easyinvoice');
const nodemailer = require('nodemailer');

const axios = require('axios');
const cors = require('cors')({ origin: true });
admin.initializeApp();
const db = admin.firestore();
const debug = true;
const configuration = new Configuration({
    apiKey: process.env.OPENAI_API_KEY,
});
const openai = new OpenAIApi(configuration);
const { gptFunctions, phoneCallToJobFunction } = require('./utils.js');

let mailTransport = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: '',
        pass: '',
    },
});

exports.newVoiceCommand = functions.firestore
    .document('organizations/{org_id}/commands/{command_id}')
    .onCreate(async (snap, context) => {
        if (debug) {
            return;
        }
        // the id for the organization that the tech falls under
        const org_id = context.params.org_id;
        const command = snap.data();
        if (debug) {
            log('command', command);
        }
        // download the file into a temporary directory from the cloud firestore bucket
        const bucket = admin.storage().bucket();
        const tempFilePath = path.join(os.tmpdir(), 'recording.m4a');
        await bucket.file(command.recordingPath).download({ destination: tempFilePath });
        // get a transcription of the recording
        const transcriptionResponse = await openai.createTranscription(
            fs.createReadStream(tempFilePath),
            'whisper-1'
        );
        if (debug) {
            log(transcriptionResponse);
        }
        const plainTextTranscript = transcriptionResponse.data.text;
        if (debug) {
            log(plainTextTranscript);
        }
        // match the transcript to a function call
        const response = await openai.createChatCompletion({
            model: 'gpt-3.5-turbo-0613',
            messages: [
                {
                    role: 'system',
                    content:
                        "You are a helpful assistant who does not respond using '*' or any other tokens that cannot be converted to JSON using JSON.parse()",
                    role: 'user',
                    content: plainTextTranscript,
                },
            ],
            functions: gptFunctions,
        });
        // get the message response function call
        const messageResponse = response.data.choices[0].message;
        if (debug) {
            log('message', messageResponse);
        }
        const function_call = messageResponse.function_call;
        if (debug) {
            log('function_call', function_call);
        }
        if (debug) {
            log('function_name', function_call.name);
        }
        // get the JSON output that includes all the fields for the appropriate function
        const pureJSONOutput = JSON.parse(messageResponse.function_call.arguments);
        switch (function_call.name) {
            case 'change_job_status': {
                const newStatus = pureJSONOutput.status;
                if (debug) {
                    log('newStatus', newStatus);
                }
                const jobRef = db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('jobs')
                    .doc(command.currentJobId);
                const snapshot = await jobRef.get();
                if (debug) {
                    log('snapshot', snapshot);
                }
                const jobData = snapshot.data();
                const jobWithUpdatedStatus = {
                    id: jobData.id,
                    assigned_tech_id: jobData.assigned_tech_id,
                    customer_name: jobData.customer_name,
                    customer_address: jobData.customer_address,
                    arrival_time_start: jobData.arrival_time_start,
                    arrival_time_end: jobData.arrival_time_end,
                    job_type: jobData.job_type,
                    tags: jobData.tags,
                    status: newStatus,
                };
                await jobRef.set(jobWithUpdatedStatus);
                break;
            }
            // If the tech wants to change the arrival time for the CURRENT job
            case 'change_current_job_time': {
                const incrementingSeconds = pureJSONOutput.increment;
                if (debug) {
                    log('incrementingSeconds', incrementingSeconds);
                }
                const jobRef = db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('jobs')
                    .doc(command.currentJobId);
                const snapshot = await jobRef.get();
                if (debug) {
                    log('snapshot', snapshot);
                }
                const jobData = snapshot.data();
                const jobWithUpdatedArrival = {
                    id: jobData.id,
                    assigned_tech_id: jobData.assigned_tech_id,
                    customer_name: jobData.customer_name,
                    customer_address: jobData.customer_address,
                    arrival_time_start: jobData.arrival_time_start + incrementingSeconds,
                    arrival_time_end: jobData.arrival_time_end + incrementingSeconds,
                    job_type: jobData.job_type,
                    tags: jobData.tags,
                    status: jobData.status,
                };
                await jobRef.set(jobWithUpdatedArrival);
                break;
            }
            case 'change_next_job_time': {
                const incrementingSeconds = pureJSONOutput.increment;
                if (debug) {
                    log('incrementingSeconds', incrementingSeconds);
                }
                const jobRef = db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('jobs')
                    .doc(command.nextJobId);
                const snapshot = await jobRef.get();
                if (debug) {
                    log('snapshot', snapshot);
                }
                const jobData = snapshot.data();
                const [newArrivalStart, newArrivalEnd] = [
                    jobData.arrival_time_start + incrementingSeconds,
                    jobData.arrival_time_end + incrementingSeconds,
                ];
                if (debug) {
                    log('newArrivalStart', newArrivalStart, 'newArrivalEnd', newArrivalEnd);
                }
                const jobWithUpdatedArrival = {
                    id: jobData.id,
                    assigned_tech_id: jobData.assigned_tech_id,
                    customer_name: jobData.customer_name,
                    customer_address: jobData.customer_address,
                    arrival_time_start: newArrivalStart,
                    arrival_time_end: newArrivalEnd,
                    job_type: jobData.job_type,
                    tags: jobData.tags,
                    status: jobData.status,
                };
                await jobRef.set(jobWithUpdatedArrival);

                const smsMessagesRef = db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('sms-messages');
                const [arrivalStartDate, arrivalEndDate] = [
                    new Date(newArrivalStart * 1000),
                    new Date(newArrivalEnd * 1000),
                ];
                if (debug) {
                    log('StartDate', arrivalStartDate, 'EndDate', arrivalEndDate);
                }
                const options = {
                    timeZone: 'America/Los_Angeles',
                    hour: '2-digit',
                    minute: '2-digit',
                };
                const [localArrivalStart, localArrivalEnd] = [
                    arrivalStartDate.toLocaleTimeString([], options),
                    arrivalEndDate.toLocaleTimeString([], options),
                ];
                await smsMessagesRef.add({
                    to: '+16192706974',
                    body: `Hello ${jobData.customer_name}, your technician 
                    is running late due to unforeseen circumstances. Your
                    updated arrival window is
                    now ${localArrivalStart} to ${localArrivalEnd}`,
                });
                break;
            }
            case 'build_invoice': {
                const bills = pureJSONOutput.bills;
                const send_email = pureJSONOutput.send_email;
                if (debug) {
                    log('bills', bills);
                }

                const invoiceRef = db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('invoices')
                    .doc(command.currentJobId);

                const newInvoice = {
                    id: command.currentJobId,
                    org_id: org_id,
                    bills: bills,
                };

                await invoiceRef.set(newInvoice);

                if (send_email) {
                    const organizationDocumentRef = db.collection('organizations').doc(org_id);
                    const jobDocumentRef = db
                        .collection('organizations')
                        .doc(org_id)
                        .collection('jobs')
                        .doc(command.currentJobId);
                    if (debug) {
                        log('invoiceRef', invoiceRef);
                    }

                    const [snapshot, orgSnapshot, jobSnapshot] = await Promise.all([
                        invoiceRef.get(),
                        organizationDocumentRef.get(),
                        jobDocumentRef.get(),
                    ]);

                    const invoiceData = snapshot.data();
                    const organizationData = orgSnapshot.data();
                    const jobData = jobSnapshot.data();

                    if (debug) {
                        log(
                            'invoiceData',
                            invoiceData,
                            'organizationData',
                            organizationData,
                            'jobData',
                            jobData
                        );
                    }

                    var products = invoiceData.bills.map((item) => ({
                        quantity: item.quantity,
                        description: item.name,
                        'tax-rate': 0,
                        price: item.cost,
                    }));
                    console.log('products', products);
                    // Create PDF invoice
                    var easyinvoiceData = {
                        // Let's add a recipient
                        client: {
                            company: jobData.customer_name,
                            address: jobData.customer_address,
                            // "zip": "1234 AB",
                            // "city": "Sampletown",
                            // "country": "Samplecountry"
                        },

                        // Now let's add our own sender details
                        sender: {
                            company: organizationData.name,
                            address: organizationData.address,
                            // "zip": "4567 CD",
                            // "city": "Clientcity",
                            // "country": "Clientcountry"
                        },

                        images: {
                            //      Logo:
                            logo: '',
                        },

                        // Let's add some standard invoice data, like invoice number, date and due-date
                        information: {
                            // Invoice number
                            number: command.currentJobId,
                            // Invoice data
                            date: '06-20-2023',
                            // Invoice due date
                            'due-date': '07-01-2023',
                        },

                        // Now let's add some products! Calculations will be done automatically for you.
                        products: products,
                        // We will use bottomNotice to add a message of choice to the bottom of our invoice
                        bottomNotice: 'Kindly pay your invoice within 15 days.',

                        // Here you can customize your invoice dimensions, currency, tax notation, and number formatting based on your locale
                        settings: {
                            currency: 'USD', // See documentation 'Locales and Currency' for more info. Leave empty for no currency.
                            translate: {},
                            customize: {},
                        },
                    };

                    // console.log("easyinvoiceData", easyinvoiceData)
                    const result = await easyinvoice.createInvoice(easyinvoiceData);
                    const tempFilePath = path.join(os.tmpdir(), 'invoice.pdf');
                    console.log('tempFilePath', tempFilePath);
                    await fs.writeFileSync(tempFilePath, result.pdf, 'base64');

                    // console.log('enter exports.sendMail, data: ' + JSON.stringify(data));

                    const recipientEmail = '';
                    console.log('recipientEmail: ' + recipientEmail);

                    const mailOptions = {
                        from: 'HVAC Support <spring.twenty.twenty.three@gmail.com>',
                        to: recipientEmail,
                        html: `<p style="font-size: 16px;">Invoice for Work Completed</p>
            <p style="font-size: 12px;">Here is your invoice for the job completed today.</p>
            <p style="font-size: 12px;">Best Regards,</p>
            <p style="font-size: 12px;">-HVAC Team</p>`,
                        attachments: [
                            {
                                filename: 'invoice.pdf',
                                path: tempFilePath,
                            },
                        ],
                    };
                    mailOptions.subject = 'Invoice for Completed Job';

                    return mailTransport.sendMail(mailOptions).then(() => {
                        console.log('email sent to:', recipientEmail);
                        return new Promise((resolve, reject) => {
                            return resolve({
                                result: 'email sent to: ' + recipientEmail,
                            });
                        });
                    });
                }
                break;
            }
            default: {
            }
        }
    });

exports.onJobUpdate = functions.firestore
    .document('organizations/{org_id}/jobs/{jobId}')
    .onUpdate(async (change, context) => {
        const org_id = context.params.org_id;
        const job = change.after.data();
        const beforeUpdate = change.before.data();
        if (debug) {
            log('job', job);
        }
        const {
            id,
            assigned_tech_id,
            customer_name,
            customer_address,
            arrival_time_start,
            arrival_time_end,
            job_type,
            tags,
            status,
        } = job;

        if (status === 'COMPLETED' && beforeUpdate.status != 'COMPLETED') {
            // If the current job is now completed, delete the job's id pointer from the tech's current-job collection
            const currentJobRef = db
                .collection('organizations')
                .doc(org_id)
                .collection('techs')
                .doc(assigned_tech_id)
                .collection('current-job')
                .doc(id);
            // Check if the job's id pointer exists
            const snapshot = await currentJobRef.get();
            if (debug) {
                log('snapshot', snapshot);
            }

            // Delete the job's id pointer
            if (snapshot.exists) {
                await currentJobRef.delete();
            }

            const nextJobCollectionRef = db
                .collection('organizations')
                .doc(org_id)
                .collection('techs')
                .doc(assigned_tech_id)
                .collection('next-job');
            const querySnapshot = await nextJobCollectionRef.get();

            for await (const doc of querySnapshot.docs) {
                if (debug) {
                    log('doc', doc.id);
                }
                // Update the current-job collection with this job's id
                await db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('techs')
                    .doc(assigned_tech_id)
                    .collection('current-job')
                    .doc(doc.id)
                    .set({});

                // Delete this job's id from the next-job collection
                await db
                    .collection('organizations')
                    .doc(org_id)
                    .collection('techs')
                    .doc(assigned_tech_id)
                    .collection('next-job')
                    .doc(doc.id)
                    .delete();
            }
        }
    });

// Saves a message to the Firebase Realtime Database but sanitizes the text by removing swearwords.
exports.addMessage = functions.https.onCall(async (data, context) => {
    // Get the invoice firestore document to create the PDF invoice
    const invoiceRef = db
        .collection('organizations')
        .doc('fyUAfcFk9o1EPc7e0BLj')
        .collection('invoices')
        .doc(data.text);
    const organizationDocumentRef = db.collection('organizations').doc('fyUAfcFk9o1EPc7e0BLj');
    const jobDocumentRef = db
        .collection('organizations')
        .doc('fyUAfcFk9o1EPc7e0BLj')
        .collection('jobs')
        .doc(data.text);
    if (debug) {
        log('invoiceRef', invoiceRef);
    }

    // const snapshot = await invoiceRef.get()
    // const orgSnapshot = await organizationDocumentRef.get()
    // const jobSnapshot = await jobDocumentRef.get()
    const [snapshot, orgSnapshot, jobSnapshot] = await Promise.all([
        invoiceRef.get(),
        organizationDocumentRef.get(),
        jobDocumentRef.get(),
    ]);

    const invoiceData = snapshot.data();
    const organizationData = orgSnapshot.data();
    const jobData = jobSnapshot.data();

    if (debug) {
        log('invoiceData', invoiceData, 'organizationData', organizationData, 'jobData', jobData);
    }

    var products = invoiceData.bills.map((item) => ({
        quantity: item.quantity,
        description: item.name,
        'tax-rate': 0,
        price: item.cost,
    }));
    console.log('products', products);
    // Create PDF invoice
    var easyinvoiceData = {
        // Let's add a recipient
        client: {
            company: jobData.customer_name,
            address: jobData.customer_address,
            // "zip": "1234 AB",
            // "city": "Sampletown",
            // "country": "Samplecountry"
        },

        // Now let's add our own sender details
        sender: {
            company: organizationData.name,
            address: organizationData.address,
            // "zip": "4567 CD",
            // "city": "Clientcity",
            // "country": "Clientcountry"
        },

        // Of course we would like to use our own logo and/or background on this invoice. There are a few ways to do this.
        images: {
            //      Logo:
            logo: '',
        },

        // Let's add some standard invoice data, like invoice number, date and due-date
        information: {
            // Invoice number
            number: data.text,
            // Invoice data
            date: '06-20-2023',
            // Invoice due date
            'due-date': '07-01-2023',
        },

        // Now let's add some products! Calculations will be done automatically for you.
        products: products,
        // We will use bottomNotice to add a message of choice to the bottom of our invoice
        bottomNotice: 'Kindly pay your invoice within 15 days.',

        // Here you can customize your invoice dimensions, currency, tax notation, and number formatting based on your locale
        settings: {
            currency: 'USD', // See documentation 'Locales and Currency' for more info. Leave empty for no currency.
            translate: {},
            customize: {},
        },
    };

    // console.log("easyinvoiceData", easyinvoiceData)
    const result = await easyinvoice.createInvoice(easyinvoiceData);
    const tempFilePath = path.join(os.tmpdir(), 'invoice.pdf');
    console.log('tempFilePath', tempFilePath);
    await fs.writeFileSync(tempFilePath, result.pdf, 'base64');

    console.log('enter exports.sendMail, data: ' + JSON.stringify(data));

    const recipientEmail = data['email'];
    console.log('recipientEmail: ' + recipientEmail);

    const mailOptions = {
        from: 'HVAC Support <spring.twenty.twenty.three@gmail.com>',
        to: recipientEmail,
        html: `<p style="font-size: 16px;">Invoice for Work Completed</p>
            <p style="font-size: 12px;">Here is your invoice for the job completed today.</p>
            <p style="font-size: 12px;">Best Regards,</p>
            <p style="font-size: 12px;">-HVAC Team</p>`,
        attachments: [
            {
                filename: 'invoice.pdf',
                path: tempFilePath,
            },
        ],
    };
    mailOptions.subject = 'Invoice for Completed Job';

    return mailTransport.sendMail(mailOptions).then(() => {
        console.log('email sent to:', recipientEmail);
        return new Promise((resolve, reject) => {
            return resolve({
                result: 'email sent to: ' + recipientEmail,
            });
        });
    });
});

exports.twilioRecordingtwo = onRequest(async (request, response) => {
    cors(request, response, async () => {
        const twilioUrl = request.body.url;
        if (debug) log({ twilioUrl: twilioUrl });
        try {
            const getResponse = await axios({
                method: 'get',
                url: twilioUrl,
                responseType: 'stream',
            });

            const tempFilePath = path.join(os.tmpdir(), 'recording.wav');

            const writeStream = fs.createWriteStream(tempFilePath);

            getResponse.data.pipe(writeStream);

            await new Promise((resolve, reject) => {
                getResponse.data.on('end', () => {
                    writeStream.end();
                    resolve();
                });
                getResponse.data.on('error', (error) => {
                    reject(new Error(`Error downloading audio: ${error}`));
                });
            });

            // Now upload the local file to Firebase Cloud Storage
            const transcript = await openai.createTranscription(
                fs.createReadStream(tempFilePath),
                'whisper-1'
            );
            if (debug) {
                log(transcript);
            }
            const text = transcript.data.text;
            if (debug) {
                log(text);
            }
            const completion = await openai.createChatCompletion({
                model: 'gpt-3.5-turbo-0613',
                messages: [
                    {
                        role: 'system',
                        content:
                            "You are a helpful assistant who does not respond using '*' or any other tokens that cannot be converted to JSON using JSON.parse()",
                        role: 'user',
                        content: text,
                    },
                ],
                functions: phoneCallToJobFunction,
                function_call: 'create_job_from_call',
            });
            const message = completion.data.choices[0].message;
            if (debug) log({ message: message });
            const { customer_address, customer_name, summary, date, job_type } = JSON.parse(
                message.function_call.arguments
            );

            const collectionRef = db
                .collection('organizations')
                .doc('fyUAfcFk9o1EPc7e0BLj')
                .collection('jobs');

            await collectionRef.add({
                customer_address: customer_address,
                customer_name: customer_name,
                summary: summary,
                job_type: job_type,
                stringifyDate: date,
            });
            response.status(200).send(`Done downloading and uploading. Text: ${text}`);
        } catch (error) {
            console.error(error);
            response.status(500).send('Error initiating download process.');
        }
    });
});

exports.executeVoiceCommand = onRequest(async (request, response) => {
    cors(request, response, async () => {});
});

exports.initialVoiceCommand = onRequest(async (request, res) => {
    cors(request, res, async () => {
        // get the url of the firebase storage bucket that houses the recording
        const firebaseStorageBuckURL = request.body.url;
        // get the id of the firestore document that is to be changed
        const firestoreDocument = request.body.id;
        // download the file into a temporary directory from the cloud firestore bucket
        const bucket = admin.storage().bucket();
        const tempFilePath = path.join(os.tmpdir(), 'recording.m4a');
        await bucket.file(firebaseStorageBuckURL).download({ destination: tempFilePath });
        // get a transcription of the recording
        const transcriptionResponse = await openai.createTranscription(
            fs.createReadStream(tempFilePath),
            'whisper-1'
        );
        if (debug) {
            log(transcriptionResponse);
        }
        const plainTextTranscript = transcriptionResponse.data.text;
        if (debug) {
            log(plainTextTranscript);
        }
        // match the transcript to a function call
        const response = await openai.createChatCompletion({
            model: 'gpt-3.5-turbo-0613',
            messages: [
                {
                    role: 'system',
                    content:
                        "You are a helpful assistant who does not respond using '*' or any other tokens that cannot be converted to JSON using JSON.parse()",
                    role: 'user',
                    content: plainTextTranscript,
                },
            ],
            functions: gptFunctions,
        });
        // get the message response function call
        const messageResponse = response.data.choices[0].message;
        if (debug) {
            log('message', messageResponse);
        }
        const function_call = messageResponse.function_call;
        if (debug) {
            log('function_call', function_call);
        }
        if (debug) {
            log('function_name', function_call.name);
        }
        // get the JSON output that includes all the fields for the appropriate function
        const pureJSONOutput = JSON.parse(messageResponse.function_call.arguments);
        res.status(200).send(`{${function_call.name} ${JSON.stringify(pureJSONOutput)}}`);
    });
});
exports.initialVoiceCommandApp = functions.https.onCall(async (data, context) => {
    // get the url of the firebase storage bucket that houses the recording
    const firebaseStorageBuckURL = data.url;
    // get the id of the firestore document that is to be changed
    const firestoreDocumentId = data.id;
    // download the file into a temporary directory from the cloud firestore bucket
    const bucket = admin.storage().bucket();
    const tempFilePath = path.join(os.tmpdir(), 'recording.m4a');
    await bucket.file(firebaseStorageBuckURL).download({ destination: tempFilePath });
    // get a transcription of the recording
    const transcriptionResponse = await openai.createTranscription(
        fs.createReadStream(tempFilePath),
        'whisper-1'
    );
    if (debug) {
        log(transcriptionResponse);
    }
    const plainTextTranscript = transcriptionResponse.data.text;
    if (debug) {
        log(plainTextTranscript);
    }
    // match the transcript to a function call
    const response = await openai.createChatCompletion({
        model: 'gpt-3.5-turbo-0613',
        messages: [
            {
                role: 'system',
                content:
                    "You are a helpful assistant who does not respond using '*' or any other tokens that cannot be converted to JSON using JSON.parse()",
                role: 'user',
                content: plainTextTranscript,
            },
        ],
        functions: gptFunctions,
    });
    // get the message response function call
    const messageResponse = response.data.choices[0].message;
    if (debug) {
        log('message', messageResponse);
    }
    const function_call = messageResponse.function_call;
    if (debug) {
        log('function_call', function_call);
    }
    if (debug) {
        log('function_name', function_call.name);
    }
    // get the JSON output that includes all the fields for the appropriate function
    const pureJSONOutput = JSON.parse(messageResponse.function_call.arguments);
    return new Promise((resolve, reject) => {
        return resolve({
            functionCalled: function_call.name,
            inputs: JSON.stringify(pureJSONOutput),
        });
    });
});

exports.executeVoiceCommandApp = functions.https.onCall(async (data, context) => {
    const functionCalled = data.functionCalled;
    const inputs = data.inputs;
    const id = data.id;
    const pureJSONOutput = JSON.parse(inputs);
    switch (functionCalled) {
        case 'change_job_status': {
            const newStatus = pureJSONOutput.status;
            if (debug) {
                log('newStatus', newStatus);
            }
            const jobRef = db
                .collection('organizations')
                .doc('fyUAfcFk9o1EPc7e0BLj')
                .collection('jobs')
                .doc(id);
            const snapshot = await jobRef.get();
            if (debug) {
                log('snapshot', snapshot);
            }
            await jobRef.update({
                status: newStatus,
            });
            break;
        }
        // If the tech wants to change the arrival time for the CURRENT job
        case 'change_current_job_time':
        case 'change_next_job_time': {
            const incrementingSeconds = pureJSONOutput.increment;
            if (debug) {
                log('incrementingSeconds', incrementingSeconds);
            }
            const jobRef = db
                .collection('organizations')
                .doc('fyUAfcFk9o1EPc7e0BLj')
                .collection('jobs')
                .doc(id);
            jobRef.update({
                arrival_time_start: admin.firestore.FieldValue.increment(incrementingSeconds),
                arrival_time_end: admin.firestore.FieldValue.increment(incrementingSeconds),
            });
            break;
        }
        case 'build_invoice': {
            const bills = pureJSONOutput.bills;
            const send_email = pureJSONOutput.send_email;
            if (debug) {
                log('bills', bills);
            }
            const invoiceRef = db
                .collection('organizations')
                .doc('fyUAfcFk9o1EPc7e0BLj')
                .collection('invoices')
                .doc(id);

            const newInvoice = {
                id: id,
                org_id: 'fyUAfcFk9o1EPc7e0BLj',
                bills: bills,
            };

            await invoiceRef.set(newInvoice);

            if (send_email) {
                const organizationDocumentRef = db
                    .collection('organizations')
                    .doc('fyUAfcFk9o1EPc7e0BLj');
                const jobDocumentRef = db
                    .collection('organizations')
                    .doc('fyUAfcFk9o1EPc7e0BLj')
                    .collection('jobs')
                    .doc(id);
                if (debug) {
                    log('invoiceRef', invoiceRef);
                }

                const [snapshot, orgSnapshot, jobSnapshot] = await Promise.all([
                    invoiceRef.get(),
                    organizationDocumentRef.get(),
                    jobDocumentRef.get(),
                ]);

                const invoiceData = snapshot.data();
                const organizationData = orgSnapshot.data();
                const jobData = jobSnapshot.data();

                if (debug) {
                    log(
                        'invoiceData',
                        invoiceData,
                        'organizationData',
                        organizationData,
                        'jobData',
                        jobData
                    );
                }

                var products = invoiceData.bills.map((item) => ({
                    quantity: item.quantity,
                    description: item.name,
                    'tax-rate': 0,
                    price: item.cost,
                }));
                console.log('products', products);
                // Create PDF invoice
                var easyinvoiceData = {
                    // Let's add a recipient
                    client: {
                        company: jobData.customer_name,
                        address: jobData.customer_address,
                        // "zip": "1234 AB",
                        // "city": "Sampletown",
                        // "country": "Samplecountry"
                    },

                    // Now let's add our own sender details
                    sender: {
                        company: organizationData.name,
                        address: organizationData.address,
                        // "zip": "4567 CD",
                        // "city": "Clientcity",
                        // "country": "Clientcountry"
                    },

                    // Of course we would like to use our own logo and/or background on this invoice. There are a few ways to do this.
                    images: {
                        //      Logo:
                        logo: '',
                    },

                    // Let's add some standard invoice data, like invoice number, date and due-date
                    information: {
                        // Invoice number
                        number: id,
                        // Invoice data
                        date: '06-20-2023',
                        // Invoice due date
                        'due-date': '07-01-2023',
                    },

                    // Now let's add some products! Calculations will be done automatically for you.
                    products: products,
                    // We will use bottomNotice to add a message of choice to the bottom of our invoice
                    bottomNotice: 'Kindly pay your invoice within 15 days.',

                    // Here you can customize your invoice dimensions, currency, tax notation, and number formatting based on your locale
                    settings: {
                        currency: 'USD', // See documentation 'Locales and Currency' for more info. Leave empty for no currency.
                        translate: {},
                        customize: {},
                    },
                };

                // console.log("easyinvoiceData", easyinvoiceData)
                const result = await easyinvoice.createInvoice(easyinvoiceData);
                const tempFilePath = path.join(os.tmpdir(), 'invoice.pdf');
                console.log('tempFilePath', tempFilePath);
                await fs.writeFileSync(tempFilePath, result.pdf, 'base64');

                // console.log('enter exports.sendMail, data: ' + JSON.stringify(data));

                const recipientEmail = '';
                console.log('recipientEmail: ' + recipientEmail);

                const mailOptions = {
                    from: 'HVAC Support <spring.twenty.twenty.three@gmail.com>',
                    to: recipientEmail,
                    html: `<p style="font-size: 16px;">Invoice for Work Completed</p>
            <p style="font-size: 12px;">Here is your invoice for the job completed today.</p>
            <p style="font-size: 12px;">Best Regards,</p>
            <p style="font-size: 12px;">-HVAC Team</p>`,
                    attachments: [
                        {
                            filename: 'invoice.pdf',
                            path: tempFilePath,
                        },
                    ],
                };
                mailOptions.subject = 'Invoice for Completed Job';

                return mailTransport.sendMail(mailOptions).then(() => {
                    console.log('email sent to:', recipientEmail);
                    return new Promise((resolve, reject) => {
                        return resolve({
                            result: 'email sent to: ' + recipientEmail,
                        });
                    });
                });
            }
            break;
        }
        default: {
        }
    }
});
