//
//  DataInitializationSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct DataInitializationSection: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                Text("모든 데이터 초기화")
            }
        }
        .alert("데이터 초기화", isPresented: $showDeleteConfirmation) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("모든 영화 카드가 삭제됩니다.\n 이 작업은 되돌릴 수 없습니다.")
        }
    }
}

#Preview {
    DataInitializationSection()
}
