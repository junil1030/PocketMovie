//
//  YouTubePlayerSheet.swift
//  PocketMovie
//
//  Created by 서준일 on 6/2/25.
//

import SwiftUI

struct YouTubePlayerSheet: View {
    let video: Video
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                YouTubePlayerView(videoId: video.key)
            }
            .navigationTitle(video.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
        }
    }
}

#Preview {
    YouTubePlayerSheet(video: Video(
        id: "1",
        key: "dQw4w9WgXcQ",
        name: "테스트 영상",
        site: "YouTube",
        type: "Trailer",
        official: true
    ))
}
