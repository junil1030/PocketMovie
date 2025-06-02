//
//  CardCreationView.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct CardCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CardCreationViewModel
    
    @State private var rating: Int = 0
    @State private var review: String = ""
    @State private var isFlipped = false
    @FocusState private var isReviewFocused: Bool
    
    init(movie: TMDBMovie) {
        _viewModel = StateObject(wrappedValue: DIContainer.shared.container.resolve(CardCreationViewModel.self, argument: movie)!)
    }
    
    var body: some View {
        CardCreationContent(
            movie: viewModel.movie,
            rating: $rating,
            review: $review,
            isFlipped: $isFlipped,
            isReviewFocused: $isReviewFocused,
            isSaveEnabled: isSaveEnabled,
            showSavedAlert: $viewModel.showSavedAlert,
            showErrorAlert: $viewModel.showErrorAlert,
            errorMessage: viewModel.errorMessage,
            dismiss: dismiss,
            saveCard: saveCard
        )
        .navigationTitle("카드 만들기")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isSaveEnabled: Bool {
        rating > 0 && !review.isEmpty && review.count <= 100
    }
    
    private func saveCard() {
        viewModel.saveCard(rating: Double(rating), review: review)
    }
}

#Preview {
    //CardCreationView()
}
