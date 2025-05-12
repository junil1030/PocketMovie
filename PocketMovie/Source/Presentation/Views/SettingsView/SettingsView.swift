//
//  SettingsView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/8/25.
//

import SwiftUI
import SwiftData
import MessageUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                // 데이터 관리 섹션
                Section(header: Text("데이터 관리")) {
                    DataInitializationSection()
                }
                
                // 앱 피드백 섹션
                Section(header: Text("서비스")) {
                    ReviewSection()
                    
                    EmailSection()
                }
                
                // 정보 섹션
                Section(header: Text("정보")) {
                    LicenseSection()
                    
                    AppVersionSection()
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
