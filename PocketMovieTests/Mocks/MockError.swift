//
//  MockError.swift
//  PocketMovie
//
//  Created by 서준일 on 6/4/25.
//
import Foundation

enum MockError: Error, LocalizedError {
    case saveError
    case deleteError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .saveError:
            return "저장 실패"
        case .deleteError:
            return "삭제 실패"
        case .unknown:
            return "알 수 없는 오류"
        }
    }
}
