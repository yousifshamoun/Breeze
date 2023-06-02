//
//  MessageFullView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/1/23.
//

import SwiftUI

struct MessageFullView: View {
    let mutualJob: MutualJob
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Spacer()
                    HStack {
                        
                    }
                    .padding()
                    .lineSpacing(4)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            Spacer()
        }
    }
}

//struct MessageFullView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageFullView(mutualJob: .init(id: "", uId: "", tId: "", serialNumber: "1", modelNumber: "String", createdDate: 1685409262, customerName: "Jane", technicianName: "Saad", companyName: "High Tech Plumbing", address: "", zipCode: "", customerIssues: "", jobUrgency: "", additionalNotes: "", initialAppointment: 1685638800, status: ""))
//    }
//}
