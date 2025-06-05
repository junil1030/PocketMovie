//
//  MockDataResetUseCase.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//
@testable import PocketMovie

@MainActor
final class MockDataResetUseCase: DataResetUseCase {
    var resetCallCount = 0
    var shouldThrowError = false
    var errorToThrow: Error = MockError.unknownError
    
    func resetAllData() throws {
        resetCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
    }
}
