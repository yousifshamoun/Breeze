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
    @Published var estimateIsShowing:Bool = false // change to false in production
    @Published var address: String = ""
    @Published var zipCode: String = ""
    @Published var customerIssues: String = ""
    @Published var jobUrgency: String = "Normal"
    @Published var additionalNotes: String = ""
    init() {}
    
    
    func setJobActive(job: PostProcessedJob) {
        guard validate(), job.status != "ACTIVE", let uId = Auth.auth().currentUser?.uid else {return}
        
        // Edit job to have "Active" status
        let activedJob = PostProcessedJob(
            id: job.id,
            serialNumber: job.serialNumber,
            modelNumber: job.modelNumber,
            usedSpecificNamespace: job.usedSpecificNamespace,
            diagnosticQuestion: job.diagnosticQuestion,
            diagnosticAnswer: job.diagnosticAnswer,
            status: "ACTIVE",
            createdDate: job.createdDate)
        let db = Firestore.firestore()
        db.collection("users").document(uId).collection("postProcessedJobs").document(job.id).setData(activedJob.asDictionary())
        
        // Fetch the homeowner name from their user document
        db.collection("users").document(uId).getDocument() {[weak self] (document, error) in
            if let document = document, document.exists {
                let userName = document.get("name")
                
                // Create job under "activeJobs" collections with homeowner info
                let newActiveJob = ActiveJob(
                    id: job.id,
                    uId: uId,
                    serialNumber: job.serialNumber,
                    modelNumber: job.modelNumber,
                    createdDate: Date().timeIntervalSince1970,
                    customerName: userName as? String ?? "",
                    address: self?.address as? String ?? "",
                    zipCode: self?.zipCode as? String ?? "",
                    customerIssues: self?.customerIssues as? String ?? "",
                    jobUrgency: self?.jobUrgency as? String ?? "",
                    additionalNotes: self?.additionalNotes as? String ?? ""
                )
                
                db.collection("activeJobs").document(job.id).setData(newActiveJob.asDictionary())
            } else {
                print("Error fetching the user name")
            }
        }
    }
    
    
    func validate() -> Bool {
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty,
            !zipCode.trimmingCharacters(in: .whitespaces).isEmpty,
              !customerIssues.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        return true
    }
}
