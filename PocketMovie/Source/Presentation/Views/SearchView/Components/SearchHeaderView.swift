//
//  SearchViewHeader.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct SearchHeaderView: View {
    @Binding var searchKeyword: String
    var isFocused: FocusState<Bool>.Binding
    let progress: CGFloat
    let onSubmit: () -> Void
    let onClear: () -> Void
    
    var body: some View {
        let currentFocus = isFocused.wrappedValue
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("영화 검색")
                        .font(.title.bold())
                        .foregroundColor(Color("AppTextColor"))
                }
                Spacer(minLength: 0)
            }
            .frame(height: 60 - (60 * progress), alignment: .bottom)
            .padding(.horizontal, 15)
            .padding(.top, 15)
            .padding(.bottom, 15 - (15 * progress))
            .opacity(1 - progress)
            .offset(y: -10 * progress)
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                
                TextField("영화 제목 검색", text: $searchKeyword)
                    .focused(isFocused)
                    .onSubmit {
                        onSubmit()
                    }
                
                if !searchKeyword.isEmpty {
                    Button {
                        onClear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background {
                RoundedRectangle(cornerRadius: currentFocus ? 0 : 30)
                    .fill(Color("AppBackgroundColor")
                        .shadow(.drop(color: .black.opacity(0.08), radius: 5, x: 5, y: 5))
                        .shadow(.drop(color: .black.opacity(0.05), radius: 5, x: -5, y: -5))
                    )
                    .padding(.top, currentFocus ? -100 : 0)
            }
            .padding(.horizontal, currentFocus ? 0 : 15)
            .padding(.bottom, 10)
            .padding(.top, 5)
        }
        .background {
            ProgressiveBlurView()
                .blur(radius: currentFocus ? 0 : 10)
                .padding(.horizontal, -15)
                .padding(.bottom, -10)
                .padding(.top, -100)
        }
        .visualEffect { content, proxy in
            content
                .offset(y: offsetY(proxy, isFocused: currentFocus))
        }
    }
    
    // 스크롤 오프셋 계산 함수
    nonisolated private
    func offsetY(_ proxy: GeometryProxy, isFocused: Bool) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        return minY > 0 ? (isFocused ? -minY : 0) : -minY
    }
}

#Preview {
    //SearchHeaderView()
}
