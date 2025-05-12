//
//  MainTabView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/8/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
            SearchView()
                .tabItem {
                    Label("검색", systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
}
