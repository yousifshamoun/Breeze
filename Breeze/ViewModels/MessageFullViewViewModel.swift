//
//  MessagesViewViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class MessageFullViewViewModel: ObservableObject {
    init() {}
    @Published var text: String = ""
    func sendMessage(mutualJob: MutualJob) {
        guard let _ = Auth.auth().currentUser?.uid, canMessageBeSent(text: text) else {return}
        let db = Firestore.firestore()
        
        // Create new message to be recieved by technician
        let newMessage = Message(id: UUID().uuidString, text: text, received: false, timeSent: Date().timeIntervalSince1970)
        var newMutualJob = mutualJob
        
        newMutualJob.messages.append(newMessage)
        
        db.collection("mutualJobs").document(mutualJob.id).setData(newMutualJob.asDictionary())
        text = ""
        
    }
    
    func canMessageBeSent(text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {return false}
        return true
    }
}
