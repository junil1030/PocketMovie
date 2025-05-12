//
//  LicenseSection.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

import SwiftUI

struct LicenseSection: View {
    
    struct License: Identifiable {
        var id = UUID()
        var name: String
        var url: String
    }
    
    let licenses: [License] = [
        License(name: "Alamofire", url: "https://github.com/Alamofire/Alamofire"),
        License(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher"),
        License(name: "Swinject", url: "https://github.com/Swinject/Swinject"),
    ]
    
    
    var body: some View {
        NavigationLink {
            List(licenses) { library in
                VStack(alignment: .leading, spacing: 8) {
                    Text(library.name)
                        .font(.headline)
                    
                    Link(library.url, destination: URL(string: library.url)!)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("오픈소스 라이선스")
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack {
                Image(systemName: "doc.text")
                Text("오픈소스 라이선스")
            }
        }
    }
}

#Preview {
    LicenseSection()
}
