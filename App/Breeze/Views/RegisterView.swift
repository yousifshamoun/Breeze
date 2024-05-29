//
//  RegisterView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewViewModel()
    var body: some View {
        // TODO: Improve the UI
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(Color.purple)
                    .opacity(0.5)
                    .rotationEffect(Angle(degrees: -5))
                VStack {
                    Text("Register Account")
                        .foregroundColor(Color.white)
                        .font(.system(size: 30))
                }
            }
            .frame(width: UIScreen.main.bounds.width * 3,
                   height: 300)
            .offset(y: -120)
            Form {
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                Button {
                    viewModel.register()
                }
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.green)
                    Text("Create Account")
                        .bold()
                        .foregroundColor(Color.white)
                }
            }
            .padding(5)
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
