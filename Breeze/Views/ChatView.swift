//
//  ChatView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel = ChatViewViewModel()
    var body: some View {
        TextField("Write a Message: ", text: $viewModel.message)
        Button("Send") {
            viewModel.send()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
