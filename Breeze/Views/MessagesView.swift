//
//  MessagesView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MessagesView: View {
    init(uId: String) {
        self._mutualJobs = FirestoreQuery(collectionPath: "mutualJobs",
                                          predicates: [.where("uId", isEqualTo: uId)])}
    @FirestoreQuery var mutualJobs: [MutualJob]
    var body: some View {
            VStack {
                NavigationStack {
                    List(mutualJobs) { job in
                        NavigationLink(value: job) {
                            MessagesListItemView(mutualJob: job)
                        }
                    }
                    .navigationTitle("Messages")
                    .navigationDestination(for: MutualJob.self) { job in
                        MessageFullView(mutualJob: job)
                    }
                    .listStyle(PlainListStyle())
                    
                }
            }
            .navigationTitle("Messages")
        }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView(uId: "12312421")
    }
}

//NavigationStack(path: $path) {
//    List(jobs) { job in
//        VStack {
//            NavigationLink(value: job) {
//                JobListItemView(job: job)
//            }
//        }
//    }
//    .navigationDestination(for: PostProcessedJob.self) {job in
//        EstimateView(job: job, path: $path)
//    }
//    .listStyle(PlainListStyle())
//}
