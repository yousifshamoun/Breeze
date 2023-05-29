//
//  NewJobViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import Foundation
import Vision
import UIKit
import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
class NewJobViewViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var diagnosticQuestion = ""
    private var dId: String?
    //    @Published var ratingPlateImage: [PhotosPickerItem] = []
    //    @Published var data: Data?
    init() {}
    func recognizeText(data: Data?) {
        var document = ""
        guard let data = data else {
            print("no data")
            return
        }
        
        guard let image: CGImage = UIImage(data: data)?.cgImage else {return}
        print(image)
        //         handler creation
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        // request creation
        let request = VNRecognizeTextRequest {request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }
            )
                .joined(separator: ", ")
            document = text
        }
        // process request
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        // get user id
        guard let uId = Auth.auth().currentUser?.uid else {return}
        let dId = UUID().uuidString
        self.dId = dId
        // create sub collection for user
        
        let newJob = PreProcessedJob(id: dId,
                                     ratingPlateText: document,
                                     diagnosticQuestion: "",
                                     createdDate: Date().timeIntervalSince1970)
        // create a document of the preproccesed job
        let db = Firestore.firestore()
        db.collection("users")
            .document(uId)
            .collection("preProcessedJobs")
            .document(dId)
            .setData(newJob.asDictionary())
    }
    func sendQuestion() {
        if let dId = self.dId {
            let updatedJob = PreProcessedJob(id: dId,
                                             ratingPlateText: "",
                                             diagnosticQuestion: self.diagnosticQuestion,
                                             createdDate: Date().timeIntervalSince1970)
            guard let uId = Auth.auth().currentUser?.uid else {return}
            let db = Firestore.firestore()
            db.collection("users")
                .document(uId)
                .collection("preProcessedJobs")
                .document(dId)
                .setData(updatedJob.asDictionary())
        } else {
            return
        }
    }
}
