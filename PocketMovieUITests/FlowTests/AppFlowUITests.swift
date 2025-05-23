//
//  AppFlowUITests.swift
//  PocketMovieUITests
//
//  Created by 서준일 on 5/23/25.
//

import XCTest

final class AppFlowUITests: BaseUITestCase {
    
    // MARK: - 전체 사용자 플로우 테스트
    func testCompleteUserFlow() throws {
        // 1. 앱 시작 - 홈 화면 확인
        assertNavigationToTab("홈")
        assertTextExists("PocketMovie")
        
        // 2. 검색 화면으로 이동
        assertNavigationToTab("검색")
        let searchField = app.textFields["영화 제목 검색"]
        assertElementExists(searchField, message: "검색 필드가 표시되어야 합니다")
        
        // 3. 박스오피스 데이터 확인 (로딩 완료 대기)
        let dailyBoxOfficeTitle = app.staticTexts["일간 박스오피스"]
        assertElementExists(dailyBoxOfficeTitle, timeout: 15, message: "일간 박스오피스 섹션이 표시되어야 합니다")
        
        let weeklyBoxOfficeTitle = app.staticTexts["주간 박스오피스"]
        assertElementExists(weeklyBoxOfficeTitle, timeout: 15, message: "주간 박스오피스 섹션이 표시되어야 합니다")
        
        // 4. 영화 검색 수행
        searchField.tap()
        searchField.typeText("인터스텔라")
        
        let searchButton = app.buttons["검색"]
        if searchButton.exists {
            searchButton.tap()
        } else {
            // 키보드의 검색 버튼 사용
            let keyboards = app.keyboards
            if keyboards.count > 0 {
                let searchKeyboardButton = keyboards.buttons["Search"]
                if searchKeyboardButton.exists {
                    searchKeyboardButton.tap()
                }
            }
        }
        
        // 5. 검색 결과 확인 및 카드 생성 플로우
        self.performMovieCardCreationFlow()
        
        // 6. 홈 화면으로 돌아가서 추가된 영화 확인
        assertNavigationToTab("홈")
        
        // 빈 상태가 아닌지 확인 (영화가 추가되었다면)
        let emptyStateText = app.staticTexts["영화를 추가해보세요!"]
        if !emptyStateText.exists {
            let movieCards = app.getMovieCards()
            XCTAssertGreaterThan(movieCards.count, 0, "영화 카드가 추가되어야 합니다")
        }
        
        // 7. 설정 화면 확인
        assertNavigationToTab("설정")
        assertTextExists("설정")
        assertTextExists("데이터 관리")
        assertTextExists("서비스")
        assertTextExists("정보")
    }
    
    private func performMovieCardCreationFlow() {
        // 검색 결과 확인
        let searchResultsText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '검색 결과:'"))
        
        if searchResultsText.count > 0 {
            // 검색 결과가 있는 경우 첫 번째 영화 선택
            let moviePosters = app.scrollViews.otherElements.children(matching: .other).children(matching: .image)
            
            if moviePosters.count > 0 {
                let firstPoster = moviePosters.firstMatch
                if app.waitForElement(firstPoster, timeout: 10) {
                    firstPoster.tap()
                    
                    // 카드 생성 화면 확인
                    assertTextExists("카드 만들기", timeout: 10)
                    
                    // 평점 선택 (5점 선택)
                    self.selectRating(5)
                    
                    // 리뷰 입력
                    self.enterReview("정말 좋은 영화였습니다!")
                    
                    // 저장 버튼 탭
                    self.saveMovieCard()
                }
            }
        } else {
            print("검색 결과가 없어서 카드 생성 플로우를 건너뜁니다.")
        }
    }
    
    private func selectRating(_ rating: Int) {
        // 별점 선택 (1-5점)
        let stars = app.images.matching(NSPredicate(format: "identifier CONTAINS 'star'"))
        if stars.count >= rating {
            let targetStar = stars.element(boundBy: rating - 1)
            if app.waitForElement(targetStar, timeout: 5) {
                targetStar.tap()
            }
        }
    }
    
    private func enterReview(_ reviewText: String) {
        let reviewTextEditor = app.textViews.firstMatch
        if app.waitForElement(reviewTextEditor, timeout: 5) {
            reviewTextEditor.tap()
            reviewTextEditor.typeText(reviewText)
            app.hideKeyboard()
        }
    }
    
    private func saveMovieCard() {
        let saveButton = app.navigationBars.buttons["저장"]
        if app.waitForElement(saveButton, timeout: 5) && saveButton.isEnabled {
            saveButton.tap()
            
            // 저장 완료 알림 확인
            let saveAlert = app.alerts["저장 완료"]
            if app.waitForElement(saveAlert, timeout: 10) {
                let confirmButton = saveAlert.buttons["확인"]
                if confirmButton.exists {
                    confirmButton.tap()
                }
            }
        }
    }
    
    // MARK: - 에러 시나리오 테스트
    func testNetworkErrorScenario() throws {
        // Given: 검색 화면으로 이동
        assertNavigationToTab("검색")
        
        // When: 존재하지 않는 영화 검색
        let searchField = app.textFields["영화 제목 검색"]
        assertElementExists(searchField, message: "검색 필드가 표시되어야 합니다")
        
        searchField.tap()
        searchField.typeText("존재하지않는영화12345")
        
        let searchButton = app.buttons["검색"]
        if searchButton.exists {
            searchButton.tap()
        }
        
        // Then: 적절한 결과 메시지가 표시되어야 함
        let noResultsText = app.staticTexts["검색 결과가 없습니다."]
        assertElementExists(noResultsText, timeout: 10, message: "검색 결과 없음 메시지가 표시되어야 합니다")
    }
    
    // MARK: - 데이터 지속성 테스트
    func testDataPersistence() throws {
        // Given: 홈 화면에 있음
        assertNavigationToTab("홈")
        let initialMovieCount = app.getMovieCards().count
        
        // When: 다른 탭으로 이동했다가 다시 돌아옴
        assertNavigationToTab("검색")
        assertNavigationToTab("설정")
        assertNavigationToTab("홈")
        
        // Then: 영화 데이터가 유지되어야 함
        let finalMovieCount = app.getMovieCards().count
        XCTAssertEqual(initialMovieCount, finalMovieCount, "데이터가 유지되어야 합니다")
    }
    
    // MARK: - 빠른 상호작용 테스트
    func testRapidUserInteractions() throws {
        // Given: 홈 화면에서 시작
        assertNavigationToTab("홈")
        
        // When: 빠르게 여러 상호작용 수행
        for i in 0..<3 {
            print("빠른 상호작용 테스트 반복: \(i + 1)")
            assertNavigationToTab("검색")
            assertNavigationToTab("홈")
            assertNavigationToTab("설정")
            assertNavigationToTab("홈")
        }
        
        // Then: 앱이 크래시되지 않고 정상 작동해야 함
        assertTextExists("PocketMovie")
        
        // 모든 탭이 여전히 작동하는지 확인
        assertNavigationToTab("검색")
        let searchField = app.textFields["영화 제목 검색"]
        assertElementExists(searchField, message: "검색 필드가 정상적으로 표시되어야 합니다")
        
        assertNavigationToTab("설정")
        assertTextExists("설정")
        
        assertNavigationToTab("홈")
        assertTextExists("PocketMovie")
    }
    
    // MARK: - 메모리 부족 시나리오 테스트
    func testMemoryPressureScenario() throws {
        // Given: 검색 화면으로 이동
        assertNavigationToTab("검색")
        
        // When: 많은 검색을 연속으로 수행 (메모리 압박 시뮬레이션)
        let searchField = app.textFields["영화 제목 검색"]
        assertElementExists(searchField, message: "검색 필드가 표시되어야 합니다")
        
        let searchTerms = ["액션", "드라마", "코미디", "로맨스", "스릴러"]
        
        for term in searchTerms {
            searchField.tap()
            searchField.clearAndEnterText(text: term)
            
            let searchButton = app.buttons["검색"]
            if searchButton.exists {
                searchButton.tap()
            }
            
            // 검색 결과 로딩 대기
            Thread.sleep(forTimeInterval: 1)
            
            // 검색 필드 클리어
            searchField.tap()
            searchField.clearAndEnterText(text: "")
        }
        
        // Then: 앱이 안정적으로 작동해야 함
        assertNavigationToTab("홈")
        assertTextExists("PocketMovie")
    }
    
    // MARK: - 전체 앱 안정성 테스트
    func testOverallAppStability() throws {
        // Given: 앱이 시작됨
        
        // When: 복합적인 사용자 시나리오 수행
        // 1. 홈 화면에서 빈 상태 확인
        assertNavigationToTab("홈")
        let isEmptyState = app.isEmptyStateDisplayed()
        
        // 2. 검색 화면에서 박스오피스 확인
        assertNavigationToTab("검색")
        let dailyBoxOffice = app.staticTexts["일간 박스오피스"]
        if app.waitForElement(dailyBoxOffice, timeout: 15) {
            print("박스오피스 데이터 로딩 완료")
        }
        
        // 3. 설정 화면에서 앱 정보 확인
        assertNavigationToTab("설정")
        assertTextExists("정보")
        
        // 4. 다시 홈으로 돌아가서 상태 확인
        assertNavigationToTab("홈")
        let finalEmptyState = app.isEmptyStateDisplayed()
        
        // Then: 상태가 일관성 있게 유지되어야 함
        XCTAssertEqual(isEmptyState, finalEmptyState, "홈 화면의 상태가 일관성 있게 유지되어야 합니다")
        
        // 앱이 정상적으로 작동하고 있음을 확인
        assertTextExists("PocketMovie")
    }
    
    // MARK: - 선택 모드 전체 플로우 테스트
    func testSelectionModeCompleteFlow() throws {
        // Given: 홈 화면에 있고 영화가 있다고 가정
        assertNavigationToTab("홈")
        
        let movieCards = app.getMovieCards()
        
        if movieCards.count > 0 {
            // When: 선택 모드 진입
            XCTAssertTrue(app.enterSelectionMode(), "선택 모드에 진입할 수 있어야 합니다")
            
            // 여러 영화 선택
            for i in 0..<min(movieCards.count, 2) {
                app.tapMovieCard(at: i)
            }
            
            // 삭제 버튼 확인
            let deleteButton = app.buttons.matching(identifier: "trash.fill").firstMatch
            if app.waitForElement(deleteButton, timeout: 5) {
                // 삭제 확인 (실제로는 삭제하지 않고 취소)
                deleteButton.tap()
                
                // 삭제 확인 알림이 있다면 취소 선택
                let cancelButton = app.alerts.buttons["취소"]
                if app.waitForElement(cancelButton, timeout: 5) {
                    cancelButton.tap()
                }
            }
            
            // 선택 모드 종료
            XCTAssertTrue(app.exitSelectionMode(), "선택 모드를 종료할 수 있어야 합니다")
            
            // Then: 원래 상태로 돌아가야 함
            let moreButton = app.navigationBars.buttons.matching(identifier: "ellipsis").firstMatch
            assertElementExists(moreButton, timeout: 5, message: "선택 모드 종료 후 더보기 버튼이 표시되어야 합니다")
        } else {
            print("선택 모드 테스트를 위한 영화 카드가 없습니다.")
        }
    }
}
