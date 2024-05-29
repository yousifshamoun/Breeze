//
//  Message.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/1/23.
//

import Foundation

struct Message: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    // true -> sent by technician
    // false -> sent by homeowner
    let received: Bool
    let timeSent: TimeInterval
}
