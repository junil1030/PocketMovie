//
//  SettingsViewModel.swift
//  PocketMovie
//
//  Created by 서준일 on 5/12/25.
//
import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    private let dataResetUseCase: DataResetUseCase
    
    @Published var isResetting = false
    @Published var resetError: Error?
    
    init(dataResetUseCase: DataResetUseCase) {
        self.dataResetUseCase = dataResetUseCase
    }
    
    func resetAllData() {
        isResetting = true
        resetError = nil
        
        do {
            try dataResetUseCase.resetAllData()
        } catch {
            resetError = error
            print("데이터 초기화 오류: \(error)")
        }
        
        isResetting = false
    }
}
