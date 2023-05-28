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
    @Published var completion: String = ""
    @Published var diagnosticQuestion = ""
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
        print("This is the document \n")
        print(document)
      
        // get user id
        guard let uId = Auth.auth().currentUser?.uid else {return}
        
        // create sub collection for user
        let newID = UUID().uuidString
        let newJob = PreProcessedJob(id: newID,
                                 ratingPlateText: document,
                                     diagnosticQuestion: self.diagnosticQuestion,
                                 createdDate: Date().timeIntervalSince1970)
        // create a document of the preproccesed job
        let db = Firestore.firestore()
        db.collection("users")
            .document(uId)
            .collection("preProcessedJobs")
            .document(newID)
            .setData(newJob.asDictionary())
    }
    
    func send(prompt: String) {
        // a function that will send a prompt to gpt 3.5 and set self.completion to the llm's completion
        // input: a prompt message of String
        // output: void
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer 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",
            forHTTPHeaderField: "Authorization"
        )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let json: [String: Any] = ["messages": [["role": "user", "content": prompt]], "max_tokens": 200, "model": "gpt-3.5-turbo", "temperature": 0]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           //no choices'
                           let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let message = firstChoice["message"] as? [String: Any],
                           let rawText = message["content"] as? String {
                            print("This is the rawText \n")
                            print(rawText)
                            let text = rawText.replacingOccurrences(of: "'", with: "\"")
                            let result = extractData(from: text)
                            self?.completion = "Model Number: \(result.model ?? rawText) \nSerial Number: \(result.serial ?? rawText)"
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }
        
        task.resume()
    }
}
func extractData(from string: String) -> (model: String?, serial: String?) {
    let modelPattern = #""Model Number":\s*"([^"]*)""#
    let serialPattern = #""Serial Number":\s*"([^"]*)""#
    
    let modelNumber = findMatch(for: modelPattern, in: string)
    let serialNumber = findMatch(for: serialPattern, in: string)
    
    return (modelNumber, serialNumber)
}

func findMatch(for pattern: String, in string: String) -> String? {
    do {
        let regex = try NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: string, options: [], range: NSRange(string.startIndex..., in: string))
        
        guard let match = matches.first else {
            return nil
        }
        
        if let range = Range(match.range(at: 1), in: string) {
            return String(string[range])
        }
    } catch {
        print("Invalid regex: \(error.localizedDescription)")
    }
    
    return nil
}
