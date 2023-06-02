//
//  BreezeApp.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/13/23.
//
import FirebaseCore
import SwiftUI

@main
struct BreezeApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
