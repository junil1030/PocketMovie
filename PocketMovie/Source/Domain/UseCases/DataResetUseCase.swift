//
//  DataResetUseCase.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//

@MainActor
protocol DataResetUseCase {
    func resetAllData() throws
}

@MainActor
final class DefaultDataResetUseCase: DataResetUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func resetAllData() throws {
        try repository.deleteAllMovies()
    }
}
