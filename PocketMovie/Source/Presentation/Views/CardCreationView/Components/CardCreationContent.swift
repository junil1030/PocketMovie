//
//  CardCreationView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/13/25.
//

import SwiftUI

struct CardCreationContent: View {
    let movie: KMDBMovie
    
    @Binding var rating: Int
    @Binding var review: String
    @Binding var isFlipped: Bool
    
    var isReviewFocused: FocusState<Bool>.Binding
    let isSaveEnabled: Bool
    
    @Binding var showSavedAlert: Bool
    @Binding var showErrorAlert: Bool
    let errorMessage: String
    
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    let dismiss: DismissAction
    let saveCard: () -> Void
    
    var body: some View {
        ZStack {
            // 배경색
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 영화 정보 섹션
                MovieInfoSection(movie: movie)
                
                // 영화 평점 섹션
                RatingSelectionSection(rating: $rating)
                
                // 리뷰 섹션
                CardReviewSection(
                    review: $review,
                    isReviewFocused: isReviewFocused
                )
                
                // 카드 미리보기 섹션
                CardPreviewSection(
                    movie: movie,
                    rating: rating,
                    review: review,
                    isFlipped: $isFlipped,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight
                )
                
                Spacer()
            }
            .padding(.top)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("저장") {
                    saveCard()
                }
                .disabled(!isSaveEnabled)
                .opacity(isSaveEnabled ? 1.0 : 0.5)
                .fontWeight(.bold)
            }
        }
        .alert("저장 완료", isPresented: $showSavedAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("영화 카드가 성공적으로 저장되었습니다.")
        }
        .alert("오류", isPresented: $showErrorAlert) {
            Button("확인") {}
        } message: {
            Text(errorMessage)
        }
        .onTapGesture {
            isReviewFocused.wrappedValue = false
        }
    }
}

#Preview {
    //CardCreationView()
}
