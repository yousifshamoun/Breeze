//
//  ContentView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/13/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserID.isEmpty {
            TabView {
                JobsListView(userID: viewModel.currentUserID)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                MessagesView(uId: viewModel.currentUserID)
                    .tabItem {
                        Label("Messages" ,systemImage: "envelope.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
            }
        } else {
            LoginView()
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
