const gptFunctions = [
    {
        name: "change_job_status",
        description:
            "Changes the current status of the job to SCHEDULED, ARRIVED, or COMPLETED",
        parameters: {
            type: "object",
            properties: {
                status: {
                    type: "string",
                    enum: ["SCHEDULED", "ARRIVED", "COMPLETED"],
                },
            },
            required: ["status"],
        },
    },
    {
        name: "change_current_job_time",
        description:
            "Changes the arrival time of the current job by incrementing the arrival time with an amount in seconds",
        parameters: {
            type: "object",
            properties: {
                increment: {
                    type: "number",
                    description:
                        "The number of seconds to increment the arrival time of the current job by",
                },
            },
            required: ["increment"],
        },
    },
    {
        name: "change_next_job_time",
        description:
            "Changes the arrival time of the next job by incrementing the arrival time with an amount in seconds",
        parameters: {
            type: "object",
            properties: {
                increment: {
                    type: "number",
                    description:
                        "The number of seconds to increment the arrival time of the next job by",
                },
            },
            required: ["increment"],
        },
    },
    {
        name: "build_invoice",
        description:
            "Building an invoice for the current job with billable items",
        parameters: {
            type: "object",
            properties: {
                bills: {
                    type: "array",
                    items: {
                        type: "object",
                        properties: {
                            name: { type: "string" },
                            cost: {
                                type: "number",
                            },
                            quantity: { type: "number" },
                        },
                        required: ["name", "cost", "quantity"],
                    },
                },
                send_email: {
                    type: "boolean",
                    description:
                        "Indicates whether the invoice should be sent as an email",
                },
            },
            required: ["bills", "send_email"],
        },
    },
];
const phoneCallToJobFunction = [
    {
        name: "create_job_from_call",
        description:
            "Fills out the details of a job form from a phone call transcription between a employee and a customer",
        parameters: {
            type: "object",
            properties: {
                customer_name: {
                    type: "string",
                    description: "The name of the customer who is calling",
                },
                customer_address: {
                    type: "string",
                    description: "The address of the customer",
                },
                summary: {
                    type: "string",
                    description: "A summary of the job that is to be performed",
                },
                job_type: {
                    type: "string",
                    enum: [
                        "Clogged Drain",
                        "Leaking Faucet",
                        "Water Heater",
                        "Toilet",
                    ],
                },
                date: {
                    type: "string",
                    description:
                        "The date the job is scheduled to be performed",
                },
            },
            required: [
                "customer_name",
                "customer_address",
                "summary",
                "job_type",
                "date",
            ],
        },
    },
];
exports.gptFunctions = gptFunctions
exports.phoneCallToJobFunction = phoneCallToJobFunction 