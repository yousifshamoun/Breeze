//
//  ActiveJob.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/31/23.
//

import Foundation

struct ActiveJob: Codable, Identifiable, Hashable {
    let id: String
    let uId: String
    let serialNumber: String
    let modelNumber: String
    let createdDate: TimeInterval
    let customerName: String
    let address: String
    let zipCode: String
    let customerIssues: String
    let jobUrgency: String
    let additionalNotes: String
}
