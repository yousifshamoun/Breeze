//
//  MessagesListItemView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/1/23.
//

import SwiftUI

struct MessagesListItemView: View {
    let mutualJob: MutualJob
    let imageUrl = URL(string:"https://images.unsplash.com/photo-1557862921-37829c790f19?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1771&q=80")
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: imageUrl) { image in
                    image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading) {
                Text(mutualJob.technicianName)
                    .font(.title)
                    .bold()
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

struct MessagesListItemView_Previews: PreviewProvider {
    let message = Message(id: "940AEC2F-71A7-49C1-BB6A-ED34DB503531", text: "Hi Yousif Shamoun, this is Saad Shamoun from High Tech Plumbing. I'd be happy to service the water heater issues you reported on Thu, June 1. Would you be available Fri, June 2 at 1:50 PM for an initial appointment?", received: true, timeSent: 1685739057.8471298)
    static var previews: some View {
        MessagesListItemView(mutualJob: .init(id: "DCC324B6-6B7C-4D83-9346-6DF8DF3797A6", uId: "", tId: "QpXfuMDVIwNKGGLFZG8dIXLf7j23", serialNumber: "1", modelNumber: "String", createdDate: 0, customerName: "Jane", address: "", zipCode: "", customerIssues: "", jobUrgency: "", additionalNotes: "", technicianName: "Saad Shamoun",  messages: [Message(id: "940AEC2F-71A7-49C1-BB6A-ED34DB503531", text: "Hi Yousif Shamoun, this is Saad Shamoun from High Tech Plumbing. I'd be happy to service the water heater issues you reported on Thu, June 1. Would you be available Fri, June 2 at 1:50 PM for an initial appointment?", received: true, timeSent: 1685739057.8471298)], status: "")
        )
    }
}

