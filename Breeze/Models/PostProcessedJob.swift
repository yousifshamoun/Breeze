//
//  PostProcessedJob.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/27/23.
//

import Foundation

struct PostProcessedJob: Codable, Identifiable {
    let id: String
    let serialNumber: String
    let modelNumber: String
    let usedSpecificNamespace: String
    let diagnosticQuestion: String
    let diagnosticAnswer: String
}
