//
//  NewJobViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import Foundation
import Vision
import UIKit
class NewJobViewViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var otherIssues: String = ""
    @Published var completion: String = ""
    @Published var selectedBrand = "Rheem"
    @Published var errorCode = 1
    @Published var lowPressure = false
    @Published var hotWater = false
    @Published var leakPresent = false
//    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod \
//    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad \
//     minim veniam, quis nostrud exercitation ullamco laboris nisi ut \
//     aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit
//    in voluptate velit esse cillum dolore eu fugiat nulla pariatur. \
//   Excepteur sint occaecat cupidatat non proident, sunt in culpa qui \
//   officia deserunt mollit anim id est laborum.
    init() {}
    func recognizeText() {
        var document = ""
        guard let image: CGImage = UIImage(named: "example3")?.cgImage else {return}
        // handler creation
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        // request creation
        let request = VNRecognizeTextRequest {[weak self] request, error in
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
        let prompt =
        """
I am a highly intelligent question answering bot who finds the model number and serial number \
 in a document and formats their answer as a JSON object with keys 'Model Number' and 'Serial Number'.
        
    Document: \(document)

"""
        self.send(prompt: prompt)
    }
    func constructPrompt() -> String {
        var prompt: String = "I am a veteran plumber, please diagnose a "
        prompt += selectedBrand
        prompt += " tankless water heater with an error code of "
        prompt += String(errorCode)
        prompt += lowPressure || hotWater || leakPresent ? " and with issues " : ""
        prompt += lowPressure ? "low water pressure, " : ""
        prompt += hotWater ? "no hot water, " : ""
        prompt += leakPresent ? "leaking present, " : ""
        prompt += !otherIssues.trimmingCharacters(in: .whitespaces).isEmpty ? "and " + otherIssues : ""
        print(prompt)
        return prompt
    }

//    func postProcessWithLLM(text: String) -> String {
//        var res = ""
//        let url = URL(string: "https://api.openai.com/v1/completions")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue(
//            "Bearer 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",
//            forHTTPHeaderField: "Authorization"
//        )
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let json: [String: Any] = ["prompt": text, "max_tokens": 200, "model": "text-davinci-003"]
//        let jsonData = try? JSONSerialization.data(withJSONObject: json)
//        request.httpBody = jsonData
//        let task = URLSession.shared.dataTask(with: request) {data, _, error in
//            if let error = error {
//                    print("Error: \(error)")
//                } else if let data = data {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                           let choices = json["choices"] as? [[String: Any]],
//                           let firstChoice = choices.first,
//                           let response = firstChoice["text"] as? String {
//                            res = response
//                        }
//                    } catch {
//                        print("Error: \(error)")
//                    }
//                }
//
//        }
//        task.resume()
//        return res
//
//    }
    func send(prompt: String) {
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer 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",
            forHTTPHeaderField: "Authorization"
        )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let json: [String: Any] = ["prompt": constructPrompt(), "max_tokens": 200, "model": "text-davinci-003"]
        let json: [String: Any] = ["prompt": prompt, "max_tokens": 200, "model": "text-davinci-001", "temperature": 0]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            DispatchQueue.main.async {
            if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let rawText = firstChoice["text"] as? String {
                            let text = rawText.replacingOccurrences(of: "'", with: "\"")
                            let result = extractData(from: text)
                            self?.completion = "Model Number: \(result.model ?? "N/A") \nSerial Number: \(result.serial ?? "N/A")"
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
