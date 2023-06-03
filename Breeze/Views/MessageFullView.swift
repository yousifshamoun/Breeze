//
//  MessageFullView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/1/23.
//


import SwiftUI
import FirebaseFirestoreSwift

struct MessageFullView: View {
    init(mutualJobId: String) {
        self._currentMutualJobs = FirestoreQuery(collectionPath: "mutualJobs", predicates: [.where("id", isEqualTo: mutualJobId)])
    }
    @FirestoreQuery var currentMutualJobs: [MutualJob]
    @StateObject var viewModel = MessageFullViewViewModel()
    // TODO: Add automatic scrolling of view to most recent message
    var body: some View {
        ForEach(currentMutualJobs) { currentMutualJob in
            VStack {
                VStack {
                    MessagesListItemView(mutualJob: currentMutualJob)
                    ScrollView {
                        ForEach(currentMutualJob.messages, id: \.self) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(Color.white)
                }
                .background(Color("Peach"))
                HStack {
                    CustomTextField(placeholder: Text("Enter your message here"), text: $viewModel.text)
                    Button {
                        viewModel.sendMessage(mutualJob: currentMutualJob)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color("Peach"))
                            .cornerRadius(50)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color("Gray"))
                .cornerRadius(50)
                .padding()
            }
        }
    }
}

//struct MessageFullView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageFullView(mutualJob: .init(id: "DCC324B6-6B7C-4D83-9346-6DF8DF3797A6", uId: "", tId: "QpXfuMDVIwNKGGLFZG8dIXLf7j23", serialNumber: "1", modelNumber: "String", createdDate: 0, customerName: "Jane", address: "", zipCode: "", customerIssues: "", jobUrgency: "", additionalNotes: "", technicianName: "Saad Shamoun",  messages: [Message(id: "940AEC2F-71A7-49C1-BB6A-ED34DB503531", text: "Hi Yousif, this is Saad from High Tech Plumbing. I'd be happy to service the water heater issues you reported on Thu, June 1. Would you be available Fri, June 2 at 1:50 PM for an initial appointment?", received: true, timeSent: 1685739057.8471298)], status: "")
//        )
//    }
//}
