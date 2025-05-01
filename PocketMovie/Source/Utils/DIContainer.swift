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
    
    let container: Container
    
    private init() {
        self.container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        registerDataSources()
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
    private func registerRepositories() {
        
    }
    
    //MARK: - UseCases
    private func registerUseCases() {
        
    }
    
    //MARK: - ViewModels
    private func registerViewModels() {
        
    }
}
