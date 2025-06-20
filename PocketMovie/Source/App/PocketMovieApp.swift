//
//  PocketMovieApp.swift
//  PocketMovie
//
//  Created by 서준일 on 4/30/25.
//

import SwiftUI
import Combine

@main
struct PocketMovieApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            rootView
        }
    }
    
    @ViewBuilder
    private var rootView: some View {
        if isUITesting {
            TestingRootView()
                .environment(\.isUITesting, true)
        } else {
            if appState.isReady {
                MainTabView()
                    .environmentObject(appState.genreStore)
                    .background(Color("AppBackgroundColor"))
            } else {
                ProgressView()
                    .task {
                        await appState.setupApp()
                    }
                    .background(Color("AppBackgroundColor"))
            }
        }
    }
    
    // MARK: - UI 테스트
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting") ||
        ProcessInfo.processInfo.environment["UITEST_MODE"] == "true"
    }
    
    private var shouldResetData: Bool {
        ProcessInfo.processInfo.arguments.contains("--reset-data")
    }
    
    private var shouldPopulateTestData: Bool {
        ProcessInfo.processInfo.arguments.contains("--populate-test-data")
    }
}

//MARK: - App 상태 관리 클래스
@MainActor
class AppState: ObservableObject {
    @Published var isReady = false
    @Published var genreStore = GenreStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    func setupApp() async {
        await DIContainer.shared.registerMain()
        await loadGenres()
        isReady = true
    }
    
    private func loadGenres() async {
        let container = DIContainer.shared
        guard let movieAPIService = container.container.resolve(MovieAPIService.self) else {
            return
        }
        
        movieAPIService.getGenreList()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("장르 로딩 실패: \(error)")
                }
            } receiveValue: { [weak self] response in
                let genres = [Genre.all] + response.genres
                self?.genreStore.genres = genres
                print("장르 로딩 완료: \(genres.count)개")
            }
            .store(in: &cancellables)
    }
}

// MARK: - UI 테스트용 루트 뷰
private struct TestingRootView: View {
    @State private var isReady = false
    
    var body: some View {
        if isReady {
            MainTabView()
        } else {
            ProgressView("테스트 환경 준비 중...")
                .task {
                    await setupUITestEnvironment()
                    isReady = true
                }
        }
    }
    
    @MainActor
    private func setupUITestEnvironment() async {
        // DI 컨테이너 초기화
        await DIContainer.shared.registerMain()
        
        // 데이터 리셋이 필요한 경우
        if ProcessInfo.processInfo.arguments.contains("--reset-data") {
            await resetTestData()
        }
        
        // 테스트용 데이터 생성이 필요한 경우
        if ProcessInfo.processInfo.arguments.contains("--populate-test-data") {
            await populateTestData()
        }
        
        // 애니메이션 속도 조정
        if let animationSpeed = ProcessInfo.processInfo.environment["ANIMATION_SPEED"],
           let speed = Double(animationSpeed) {
            print("UI 테스트: 애니메이션 속도 설정 \(speed)")
        }
        
        print("UI 테스트 환경 설정 완료")
    }
    
    @MainActor
    private func resetTestData() async {
        do {
            let container = DIContainer.shared
            if let dataResetUseCase = container.container.resolve(DataResetUseCase.self) {
                try dataResetUseCase.resetAllData()
                print("UI 테스트: 데이터 초기화 완료")
            }
        } catch {
            print("UI 테스트: 데이터 초기화 실패 - \(error)")
        }
    }
    
    @MainActor
    private func populateTestData() async {
        do {
            let container = DIContainer.shared
            if let movieUseCase = container.container.resolve(MovieUseCase.self) {
                let testMovies = UITestDataProvider.createTestMovies()
                for movie in testMovies {
                    try movieUseCase.saveMovie(movie)
                }
                print("UI 테스트: 테스트 데이터 생성 완료 (\(testMovies.count)개 영화)")
            }
        } catch {
            print("UI 테스트: 테스트 데이터 생성 실패 - \(error)")
        }
    }
}

// MARK: - UI 테스트 환경 키
private struct UITestingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var isUITesting: Bool {
        get { self[UITestingKey.self] }
        set { self[UITestingKey.self] = newValue }
    }
}

// MARK: - 테스트용 Mock 데이터 제공자
struct UITestDataProvider {
    @MainActor
    static func createTestMovies() -> [Movie] {
        return [
            Movie(
                title: "UI 테스트 영화 1",
                releaseDate: "2034-01-01",
                posterURL: "https://via.placeholder.com/300x450/FF6B6B/FFFFFF?text=Movie1",
                rating: 4.5,
                review: "테스트용 리뷰 1",
                watchedDate: Date(),
                genres: ["액션"]
            ),
            Movie(
                title: "UI 테스트 영화 2",
                releaseDate: "2123-02-06",
                posterURL: "https://via.placeholder.com/300x450/4ECDC4/FFFFFF?text=Movie2",
                rating: 5.0,
                review: "테스트용 리뷰 1",
                watchedDate: Date(),
                genres: ["스릴러"]
            ),
            Movie(
                title: "UI 테스트 영화 3",
                releaseDate: "1868-03-01",
                posterURL: "https://via.placeholder.com/300x450/45B7D1/FFFFFF?text=Movie3",
                rating: 3.5,
                review: "테스트용 리뷰 1",
                watchedDate: Date(),
                genres: ["모험"]
            )
        ]
    }
}

// MARK: - UI 테스트 유틸리티
enum UITestingUtility {
    static func isUITesting() -> Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting") ||
        ProcessInfo.processInfo.environment["UITEST_MODE"] == "true"
    }
    
    static func shouldUseTestData() -> Bool {
        ProcessInfo.processInfo.arguments.contains("--populate-test-data")
    }
    
    static func getTestAnimationDuration() -> Double {
        if let animationSpeed = ProcessInfo.processInfo.environment["ANIMATION_SPEED"],
           let speed = Double(animationSpeed) {
            return speed
        }
        return isUITesting() ? 0.1 : 0.3
    }
}

// MARK: - View 확장 (UI 테스트용)
extension View {
    func configureForUITesting() -> some View {
        self
            .animation(.easeInOut(duration: UITestingUtility.getTestAnimationDuration()), value: UUID())
            .accessibilityAddTraits(.isButton)
    }
}
