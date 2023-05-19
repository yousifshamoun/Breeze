//
//  NewJobViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import Foundation

class NewJobViewViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var otherIssues: String = ""
    @Published var completion: String = ""
    @Published var selectedBrand = "Rheem"
    @Published var errorCode = 0
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
    func test() {
        self.loading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.loading = false
        }
    }
    func send() {
//        guard validate() else {
//            return
//        }
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(
            "Bearer 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",
            forHTTPHeaderField: "Authorization"
        )
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let json: [String: Any] = ["prompt": constructPrompt(), "max_tokens": 200, "model": "text-davinci-003"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request){[weak self] data, _, error in
            DispatchQueue.main.async {
            if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let text = firstChoice["text"] as? String {
                            print(text) // This should print the translated text
                                self?.completion = text
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        }

        task.resume()
    }
//    func validate() -> Bool {
//        guard !prompt.trimmingCharacters(in: .whitespaces).isEmpty else {
//            return false
//        }
//        return true
//    }
}
