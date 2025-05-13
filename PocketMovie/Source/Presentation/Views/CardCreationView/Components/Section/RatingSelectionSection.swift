//
//  RatingSelectionSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct RatingSelectionSection: View {
    @Binding var rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("평점")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(index <= rating ? .yellow : .gray)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                rating = index
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    //RatingSelectionSection()
}
