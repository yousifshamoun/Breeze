//
//  MutualJob.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/31/23.
//

import Foundation

struct MutualJob: Codable, Identifiable, Hashable {
    let id: String
    let uId: String
    let tId: String
    let serialNumber: String
    let modelNumber: String
    let createdDate: TimeInterval
    let customerName: String
    let address: String
    let zipCode: String
    let customerIssues: String
    let jobUrgency: String
    let additionalNotes: String
    let technicianName: String
    var messages: [Message]
//    let companyName: String
//    let initialAppointment: TimeInterval
    let status: String
}
