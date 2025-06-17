//
//  HomeSearchBar.swift
//  PocketMovie
//
//  Created by 서준일 on 6/17/25.
//

import SwiftUI

struct HomeSearchBar: View {
    @Binding var searchText: String
    let placeholder: String
    let onClear: () -> Void
    
    init(searchText: Binding<String>,
         placeholder: String = "영화 제목 검색",
         onClear: @escaping () -> Void = {}
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self.onClear = onClear
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .font(.system(size: 16))
            
            TextField(placeholder, text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onClear()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color("AppBackgroundColor"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 20) {
        HomeSearchBar(
            searchText: .constant(""),
            onClear: {}
        )
    }
}
