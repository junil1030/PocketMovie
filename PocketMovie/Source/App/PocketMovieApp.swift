//
//  PocketMovieApp.swift
//  PocketMovie
//
//  Created by 서준일 on 4/30/25.
//

import SwiftUI

@main
struct PocketMovieApp: App {
    init() {
        Task {
            await DIContainer.shared.registerMain()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
