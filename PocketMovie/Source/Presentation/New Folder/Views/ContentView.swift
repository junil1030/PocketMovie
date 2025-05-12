//
//  ContentView.swift
//  PocketMovie
//
//  Created by 서준일 on 4/30/25.
//

import SwiftUI

// Sample Iamge
struct ImageModel: Identifiable {
    var id: String = UUID().uuidString
    var altText: String
    var image: String
}

struct Item: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var image: UIImage?
}

let images: [ImageModel] = [
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(altText:"Mo Eid", image: "Pic 1"),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(altText:"Codioful", image: "Pic 2"),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(altText:"Cottonbro", image: "Pic 3"),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(altText:"Anni", image: "Pic 4")
]

let imageItems: [Item] = [
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(title:"Mo Eid", image: UIImage(named:"Pic 1")),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(title:"Codioful", image: UIImage(named:"Pic 2")),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(title:"Cottonbro", image: UIImage(named:"Pic 3")),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(title:"Anni", image: UIImage(named:"Pic 4")),
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(title:"Mo Eid", image: UIImage(named:"Pic 1")),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(title:"Codioful", image: UIImage(named:"Pic 2")),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(title:"Cottonbro", image: UIImage(named:"Pic 3")),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(title:"Anni", image: UIImage(named:"Pic 4")),
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(title:"Mo Eid", image: UIImage(named:"Pic 1")),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(title:"Codioful", image: UIImage(named:"Pic 2")),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(title:"Cottonbro", image: UIImage(named:"Pic 3")),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(title:"Anni", image: UIImage(named:"Pic 4")),
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(title:"Mo Eid", image: UIImage(named:"Pic 1")),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(title:"Codioful", image: UIImage(named:"Pic 2")),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(title:"Cottonbro", image: UIImage(named:"Pic 3")),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(title:"Anni", image: UIImage(named:"Pic 4")),
    /// https://www.pexels.com/photo/green-palm-tree-near-white-and-black-dome-building-under-blue-sky-9002742/
    .init(title:"Mo Eid", image: UIImage(named:"Pic 1")),
    /// https://www.pexels.com/photo/a-gradient-wallpaper-7135121/
    .init(title:"Codioful", image: UIImage(named:"Pic 2")),
    /// https://www.pexels.com/photo/high-speed-photography-of-colorful-ink-diffusion-in-water-9669094/
    .init(title:"Cottonbro", image: UIImage(named:"Pic 3")),
    /// https://www.pexels.com/photo/multicolored-abstract-painting-2868948/
    .init(title:"Anni", image: UIImage(named:"Pic 4"))
]

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // If you want to stop over-dragging, you can actually follow the upcoming step to avoid it
                GeometryReader {
                    let width = $0.size.width
                    
                    LoopingStack(maxTranslationWidth: width) {
                        ForEach(images) { image in
                            Image(image.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 250, height: 400)
                                .clipShape(.rect(cornerRadius: 30))
                                .padding(5)
                                .background {
                                    RoundedRectangle(cornerRadius: 35)
                                        .fill(.background)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 420)
            }
            .navigationTitle("Pocket Movie")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.2))
        }
    }
}

#Preview {
    ContentView()
}
