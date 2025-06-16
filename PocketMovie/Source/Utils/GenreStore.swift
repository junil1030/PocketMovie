//
//  GenreStore.swift
//  PocketMovie
//
//  Created by 서준일 on 6/16/25.
//

import Foundation

class GenreStore: ObservableObject {
    @Published var genres: [Genre] = [Genre.all]
}
