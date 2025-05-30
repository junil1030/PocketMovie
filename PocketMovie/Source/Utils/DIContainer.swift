//
//  DIContainer.swift
//  PocketMovie
//
//  Created by 서준일 on 5/1/25.
//

import Foundation
import Swinject

final class DIContainer {
    static let shared = DIContainer()
    let container = Container()
    
    private init() {
        registerDependencies()
    }
    
    func registerMain() async {
        await registerMainActorDependencies()
    }

    private func registerDependencies() {
        registerDataSources()
    }
    
    @MainActor
    private func registerMainActorDependencies() {
        registerRepositories()
        registerUseCases()
        registerViewModels()
    }
    
    //MARK: - DataSources
    private func registerDataSources() {
        container.register(NetworkClient.self) { _ in
            AFNetworkClient()
        }.inObjectScope(.container)
        
        // MovieAPIService 등록
        container.register(MovieAPIService.self) { resolver in
            let networkClient = resolver.resolve(NetworkClient.self)!
            return DefaultMovieAPIService(networkClient: networkClient)
        }.inObjectScope(.container)
    }
    
    //MARK: - Repositories
    @MainActor
    private func registerRepositories() {
        container.register(MovieRepository.self) { _ in
            do {
                return try SwiftDataMovieRepository()
            } catch {
                fatalError("영화 레포지토리 초기화 실패: \(error)")
            }
        }.inObjectScope(.container)
    }
    
    //MARK: - UseCases
    @MainActor
    private func registerUseCases() {
        container.register(MovieUseCase.self) { resolver in
            let repository = resolver.resolve(MovieRepository.self)!
            return DefaultMovieUseCase(repository: repository)
        }.inObjectScope(.container)
        
        container.register(DataResetUseCase.self) { resolver in
            let repository = resolver.resolve(MovieRepository.self)!
            return DefaultDataResetUseCase(repository: repository)
        }.inObjectScope(.container)
    }
    
    //MARK: - ViewModels
    @MainActor
    private func registerViewModels() {
        container.register(HomeViewModel.self) { resolver in
            let useCase = resolver.resolve(MovieUseCase.self)!
            return HomeViewModel(movieUseCase: useCase)
        }.inObjectScope(.container)
        
        container.register(SearchViewModel.self) { _ in
            return SearchViewModel()
        }.inObjectScope(.container)
        
        container.register(SettingsViewModel.self) { resolver in
            let useCase = resolver.resolve(DataResetUseCase.self)!
            return SettingsViewModel(dataResetUseCase: useCase)
        }.inObjectScope(.container)
        
        container.register(CardCreationViewModel.self) { (resolver, movie: TMDBMovie) in
            let useCase = resolver.resolve(MovieUseCase.self)!
            return CardCreationViewModel(movie: movie, movieUseCase: useCase)
        }.inObjectScope(.container)
        
        container.register(DetailViewModel.self) { (resolver, movieId: Int) in
            return DetailViewModel(movieId: movieId)
        }.inObjectScope(.container)
    }
}
