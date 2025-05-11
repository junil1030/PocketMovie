//
//  SettingsView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/8/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @State private var showDeleteConfirmation = false
    @State private var showFeedbackForm = false
    @State private var showContactForm = false
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SettingsView()
}
