//
//  Job.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import Foundation

struct PreProcessedJob: Codable, Identifiable {
    let id: String
    let ratingPlateText: String
    let diagnosticQuestion: String
    let createdDate: TimeInterval
}
