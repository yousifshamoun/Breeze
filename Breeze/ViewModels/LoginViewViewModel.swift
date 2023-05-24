//
//  LoginViewViewModel.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//
import FirebaseAuth
import Foundation

class LoginViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    init() {}
    private func insertUserRecord(id: String) {}
    func login() {
        guard validate() else {return}
        Auth.auth().signIn(withEmail: email, password: password)
    }
    func validate() -> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            return false
        }
        guard password.count >= 6 else {
            return false
        }
        return true
    }
}
