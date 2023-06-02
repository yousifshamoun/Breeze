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
    let recieved: Bool
    let timeSent: TimeInterval
}
