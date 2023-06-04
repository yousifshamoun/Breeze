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
                    ScrollViewReader { proxy in
                        LazyVStack {
                            ForEach(currentMutualJob.messages, id: \.self) { message in
                                MessageBubble(message: message)
                                    .id(message)
                            }
                        }
                        .onChange(of: currentMutualJobs) { _ in
                            proxy.scrollTo(currentMutualJobs.first!.messages.last, anchor: .bottom)
                            print("Should've scrolled")
                    }
                    .padding(.top, 10)
                    .background(Color.white)
                        //                            print("Debug for onChange: ", currentMutualJobs.first!.messages.last.id)
                    }
                    }
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

struct MessageFullView_Previews: PreviewProvider {
    static var previews: some View {
        MessageFullView(mutualJobId: "5DE5FBF2-592D-433D-BA63-932B49E687FC")
    }
}
