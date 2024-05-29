//
//  JobListItemViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/27/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
class JobListItemViewModel: ObservableObject {
    init() {}
    func deleteFromPost(dId: String) {
        // A user must be logged in to delete their data
        guard let uId = Auth.auth().currentUser?.uid else {return}
        let db = Firestore.firestore()
        // Delete from post Processed Jobs
        db
        .collection("users")
        .document(uId)
        .collection("postProcessedJobs")
        .document(dId)
        .delete() {err in
            if let err = err {
                print("Error deleting pre document, error: \(err)")
            }
        }
        // Delete from pre Processed Jobs
        db
        .collection("users")
        .document(uId)
        .collection("preProcessedJobs")
        .document(dId)
        .delete() {err in
            if let err = err {
                print("Error deleting post document, error: \(err)")
            }
        }
    }
}
