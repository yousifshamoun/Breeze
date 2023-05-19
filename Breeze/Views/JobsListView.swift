//
//  NewJobView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI

struct JobsListView: View {
    @StateObject var viewModel = JobsListViewViewModel()
    var body: some View {
        NavigationView {
            VStack {
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
                NewJobView()
            }
        }
    }
}

struct JobsListView_Previews: PreviewProvider {
    static var previews: some View {
        JobsListView()
    }
}
