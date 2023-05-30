//
//  NewJobView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI
import FirebaseFirestoreSwift
struct JobsListView: View {
    init(userID: String) {
        self._jobs = FirestoreQuery(collectionPath: "users/\(userID)/postProcessedJobs")
    }
    @StateObject var viewModel = JobsListViewViewModel()
    @FirestoreQuery var jobs: [PostProcessedJob]
    @State var path: [PostProcessedJob] = []
    var body: some View {
        NavigationView {
            VStack {
                NavigationStack(path: $path) {
                    List(jobs) { job in
                        VStack {
                            NavigationLink(value: job) {
                                JobListItemView(job: job)
                            }
                        }
                    }
                    .navigationDestination(for: PostProcessedJob.self) {job in
                        EstimateView(job: job, path: $path)
                    }
                    .listStyle(PlainListStyle())
                }
             }
            .navigationTitle("Jobs List")
            .toolbar {
                Button {
                    viewModel.showingNewJobView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewJobView) {
                NewJobView(newJobPresented:
                            $viewModel.showingNewJobView)
            }
        }
    }
}
struct JobsListView_Previews: PreviewProvider {
    static var previews: some View {
        JobsListView(userID: "bGSCCrG3CphQGNE3QssKsJkvwlb2")
    }
}
