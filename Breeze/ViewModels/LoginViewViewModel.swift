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
        guard validate() else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userID = result?.user.uid else {
                return
            }
            self?.insertUserRecord(id: userID)
            
        }
        
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
