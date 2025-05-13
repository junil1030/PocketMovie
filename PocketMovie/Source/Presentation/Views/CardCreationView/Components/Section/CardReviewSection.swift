//
//  CardReviewSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct CardReviewSection: View {
    @Binding var review: String
    var isReviewFocused: FocusState<Bool>.Binding
    
    // 글자수 제한
    private let maxCharacterLimit = 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한줄평")
                .font(.headline)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { review },
                    set: { newValue in
                        if newValue.count <= maxCharacterLimit {
                            review = newValue
                        } else {
                            review = String(newValue.prefix(maxCharacterLimit))
                        }
                    }
                ))
                .frame(height: 100)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .focused(isReviewFocused)
                
                if review.isEmpty {
                    Text("이 영화에 대한 감상을 남겨보세요")
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(8)
                        .allowsHitTesting(false)
                }
            }
            
            Text("\(review.count)/\(maxCharacterLimit)자")
                .font(.caption)
                .foregroundColor(review.count > maxCharacterLimit ? .red : .gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal)
    }
}

#Preview {
    //CardReviewSection()
}
