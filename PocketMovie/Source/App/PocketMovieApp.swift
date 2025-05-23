//
//  PocketMovieApp.swift
//  PocketMovie
//
//  Created by 서준일 on 4/30/25.
//

import SwiftUI

@main
struct PocketMovieApp: App {
    @State private var isReady = false
    
    var body: some Scene {
        WindowGroup {
            if isReady {
                MainTabView()
            } else {
                ProgressView()
                    .task {
                        await DIContainer.shared.registerMain()
                        isReady = true
                    }
            }
        }
    }
}
