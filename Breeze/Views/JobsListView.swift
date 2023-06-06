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
        self._jobs = FirestoreQuery(collectionPath: "users/\(userID)/postProcessedJobs",
                                    predicates: [.order(by: "createdDate", descending: true)])
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
                    .navigationTitle("Jobs List")
                    // TODO: If the user left the sheet before submitting a diagnosticQuestion, they should be taken to a temporary NewJobView to complete their preProcessedJob instead of an Estimate view
                    .navigationDestination(for: PostProcessedJob.self) {job in
                        EstimateView(job: job, path: $path)
                            .padding(.top, 80)
                            .edgesIgnoringSafeArea(.top)
                    }
                    .listStyle(PlainListStyle())
                }
             }
            .toolbar {
                if path.isEmpty {
                    Button {
                        viewModel.showingNewJobView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                } else {Spacer()}
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
