//
//  CastSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/30/25.
//

import SwiftUI
import Kingfisher

struct CastSection: View {
    let cast: [CastMember]
    
    var body: some View {
        HorizontalScrollSection(title: "출연진") {
            ForEach(cast) { member in
                CastMemberView(member: member)
            }
        }
    }
}

struct CastMemberView: View {
    let member: CastMember
    
    var body: some View {
        VStack(spacing: 8) {
            // 프로필 사진
            if let profileURL = member.profileURL {
                KFImage(URL(string: profileURL))
                    .resizable()
                    .placeholder {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.gray)
                            )
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray)
                    )
            }
            
            VStack(spacing: 3) {
                Text(member.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(member.character)
                    .font(.caption2)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    CastSection(cast: [])
}
