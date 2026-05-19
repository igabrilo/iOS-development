//
//  NewsAppApp.swift
//  NewsApp
//
//  Created by Ivan Gabrilo on 24.03.2026..
//

import SwiftUI

@main
struct NewsAppApp: App {
    @State private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth)
        }
    }
}
