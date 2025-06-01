//
//  MovieOverviewSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI

struct MovieOverviewSection: View {
    let movie: TMDBMovie
    @State private var isOverviewExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("줄거리")
                .font(.headline)
                .foregroundStyle(Color("AppTextColor"))
            
            VStack(alignment: .leading, spacing: 8) {
                if movie.overview.isEmpty {
                    Text("줄거리 정보가 없습니다.")
                        .foregroundStyle(Color("AppTextColor"))
                        .font(.subheadline)
                } else {
                    Text(movie.overview)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextColor"))
                        .lineLimit(isOverviewExpanded ? nil : 2)
                        .animation(.easeInOut(duration: 0.3), value: isOverviewExpanded)
                    
                    if shouldShowExpandButton {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isOverviewExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: isOverviewExpanded ? "chevron.compact.up" : "chevron.compact.down")
                                .foregroundStyle(Color("AppTextColor"))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    // 줄거리가 2줄을 넘는지
    private var shouldShowExpandButton: Bool {
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        let screenWidth = UIScreen.main.bounds.width - 60 // 양쪽 패딩 고려해서
        
        let textSize = movie.overview.boundingRect(
            with: CGSize(width: screenWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        let lineHeight = font.lineHeight
        let numberOfLines = Int(ceil(textSize.height / lineHeight))
        
        return numberOfLines > 2
    }
}

#Preview {
    let sampleMovie = TMDBMovie(
        id: 87359,
        title: "미션 임파서블: 파이널 레코닝",
        originalTitle: "미션 임파서블: 파이널 레코닝",
        posterPath: "/jPrAjeK4APOhPSrHrLqSmXF2Z8a.jpg",
        backdropPath: "/mroWh717g0Ah2c0rrPGW6f3EWMM.jpg",
        releaseDate: "2025-05-17",
        overview: "디지털상의 모든 정보를 통제할 수 있는 사상 초유의 무기로 인해 전 세계 국가와 조직의 기능이 마비되고, 인류 전체가 위협받는 절체절명의 위기가 찾아온다. 이를 막을 수 있는 건 오직 존재 자체가 기밀인 에단 헌트와 그가 소속된 IMF뿐이다. 무기를 무력화하는 데 반드시 필요한 키를 손에 쥔 에단 헌트. 오랜 동료 루터와 벤지, 그리고 새로운 팀원이 된 그레이스, 파리, 드가와 함께 지금껏 경험했던 그 어떤 상대보다도 강력한 적에 맞서 모두의 운명을 건 불가능한 미션에 뛰어든다.",
        voteAverage: 7.1,
        voteCount: 413
    )
    
    MovieOverviewSection(movie: sampleMovie)
}
