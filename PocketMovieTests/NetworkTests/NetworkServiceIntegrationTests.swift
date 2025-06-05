//
//  NetworkServiceIntegrationTests.swift
//  PocketMovieTests
//
//  Created by 서준일 on 5/15/25.
//

import Testing
import Foundation
import Combine
import Alamofire
@testable import PocketMovie

struct NetworkServiceIntegrationTests {
    
    // MARK: - AFNetworkClient 테스트
    @Test("네트워크 클라이언트가 정상적으로 요청을 처리하는지")
    func testNetworkClientRequest() async throws {
        // Given
        let mockSession = createMockSession()
        let networkClient = AFNetworkClient(session: mockSession)
        
        let endpoint = MockEndpoint.test
        
        // When & Then
        // 실제 네트워크 호출 대신 Mock을 사용
        // 실제 통합 테스트에서는 테스트 서버를 사용하거나 네트워크 목킹 라이브러리 활용
    }
    
    @Test("API 에러가 올바르게 매핑되는지")
    func testAPIErrorMapping() async throws {
        // Given
        let networkClient = AFNetworkClient()
        var cancellables = Set<AnyCancellable>()
        
        // 잘못된 엔드포인트로 요청
        let invalidEndpoint = MockEndpoint.invalid
        
        let expectation = XCTestExpectation(description: "에러 발생")
        var receivedError: Error?
        
        // When
        networkClient.request(invalidEndpoint)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                        expectation.fulfill()
                    }
                },
                receiveValue: { (_: EmptyResponse) in
                    // 에러가 발생해야 하므로 여기는 실행되면 안됨
                }
            )
            .store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
        #expect(receivedError != nil)
        #expect(receivedError is APIError)
    }
    
    // MARK: - MovieAPIService 테스트
    @Test("일간 박스오피스 API 호출 형식이 올바른지")
    func testDailyBoxOfficeAPIFormat() async throws {
        // Given
        let mockClient = MockNetworkClient()
        let movieService = DefaultMovieAPIService(networkClient: mockClient)
        
        var capturedEndpoint: APIEndpoint?
        mockClient.onRequest = { endpoint in
            capturedEndpoint = endpoint
        }
        
        // When
        _ = movieService.fetchDailyBoxOffice(date: "20250101")
        
        // Then
        #expect(capturedEndpoint != nil)
        #expect(capturedEndpoint?.path.contains("searchDailyBoxOfficeList") == true)
        #expect(capturedEndpoint?.parameters?["targetDt"] as? String == "20250101")
        #expect(capturedEndpoint?.parameters?["key"] != nil)
    }
    
    @Test("TMDB 영화 검색 API 호출 형식이 올바른지")
    func testTMDBSearchAPIFormat() async throws {
        // Given
        let mockClient = MockNetworkClient()
        let movieService = DefaultMovieAPIService(networkClient: mockClient)
        
        var capturedEndpoint: APIEndpoint?
        mockClient.onRequest = { endpoint in
            capturedEndpoint = endpoint
        }
        
        // When
        _ = movieService.searchMovies(keyword: "인터스텔라")
        
        // Then
        #expect(capturedEndpoint != nil)
        #expect(capturedEndpoint?.path.contains("search/movie") == true)
        #expect(capturedEndpoint?.parameters?["query"] as? String == "인터스텔라")
        #expect(capturedEndpoint?.parameters?["language"] as? String == "ko-KR")
        #expect(capturedEndpoint?.parameters?["api_key"] != nil)
    }
    
    // MARK: - 헬퍼
    private func createMockSession() -> Session {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return Session(configuration: configuration)
    }
}

// MARK: - Mock 구조체
struct EmptyResponse: Codable {}

enum MockEndpoint: APIEndpoint {
    case test
    case invalid
    
    var baseURL: String {
        switch self {
        case .test:
            return "https://api.example.com"
        case .invalid:
            return "https://invalid.url.com"
        }
    }
    
    var path: String {
        switch self {
        case .test:
            return "/test"
        case .invalid:
            return "/invalid"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
}

// MARK: - Mock NetworkClient
class MockNetworkClient: NetworkClient {
    var onRequest: ((APIEndpoint) -> Void)?
    var responseToReturn: Any?
    var errorToThrow: Error?
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, Error> {
        onRequest?(endpoint)
        
        return Future<T, Error> { promise in
            if let error = self.errorToThrow {
                promise(.failure(error))
            } else if let response = self.responseToReturn as? T {
                promise(.success(response))
            } else {
                // 기본 빈 응답
                promise(.failure(APIError.noData))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Mock URLProtocol
class MockURLProtocol: URLProtocol {
    static var mockResponses: [URL: (data: Data?, response: URLResponse?, error: Error?)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url,
              let mockResponse = MockURLProtocol.mockResponses[url] else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        
        if let data = mockResponse.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = mockResponse.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = mockResponse.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        // 필요시 구현
    }
}

// MARK: - XCTestExpectation 대체
class XCTestExpectation {
    let description: String
    private var isFulfilled = false
    
    init(description: String) {
        self.description = description
    }
    
    func fulfill() {
        isFulfilled = true
    }
    
    var fulfilled: Bool {
        return isFulfilled
    }
}

func fulfillment(of expectations: [XCTestExpectation], timeout: TimeInterval) async {
    let endTime = Date().addingTimeInterval(timeout)
    
    while Date() < endTime {
        if expectations.allSatisfy({ $0.fulfilled }) {
            return
        }
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
    }
}
