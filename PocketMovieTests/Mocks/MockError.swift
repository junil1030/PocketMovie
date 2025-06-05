//
//  MockError.swift
//  PocketMovie
//
//  Created by 서준일 on 6/4/25.
//
import Foundation

enum MockError: Error, LocalizedError {
    case networkError
    case parsingError
    case saveError
    case deleteError
    case updateError
    case fetchError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "네트워크 연결 오류"
        case .parsingError:
            return "데이터 파싱 오류"
        case .saveError:
            return "저장 실패"
        case .deleteError:
            return "삭제 실패"
        case .updateError:
            return "업데이트 실패"
        case .fetchError:
            return "조회 실패"
        case .unknownError:
            return "알 수 없는 오류"
        }
    }
}
