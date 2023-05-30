//
//  ChatViewViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
class EstimateViewViewModel: ObservableObject {
    @Published var estimateIsShowing:Bool = false
    init() {}
    func setJobActive(job: PostProcessedJob) {
        if job.status == "ACTIVE" {return}
        guard let uId = Auth.auth().currentUser?.uid else {return}
        // create job with "Active" status
        let activeJob = PostProcessedJob(
            id: job.id,
            serialNumber: job.serialNumber,
            modelNumber: job.modelNumber,
            usedSpecificNamespace: job.usedSpecificNamespace,
            diagnosticQuestion: job.diagnosticQuestion,
            diagnosticAnswer: job.diagnosticAnswer,
            status: "ACTIVE",
            createdDate: job.createdDate
        )
        let db = Firestore.firestore()
        db.collection("users").document(uId).collection("postProcessedJobs").document(job.id).setData(activeJob.asDictionary())
    }
}
