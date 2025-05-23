//
//  HomeUITests.swift
//  PocketMovieUITests
//
//  Created by 서준일 on 5/23/25.
//

import XCTest

final class HomeUITests: BaseUITestCase {
    
    // MARK: - 초기 상태 테스트
    func testHomeScreenInitialState() throws {
        assertNavigationToTab("홈")
        
        assertTextExists("PocketMovie")
        
        // 영화가 없는 경우 빈 상태 화면이 표시되어야 함
        if app.isEmptyStateDisplayed() {
            assertTextExists("영화를 추가해보세요!")
            
            let emptyStateImage = app.images["film"]
            assertElementExists(emptyStateImage, message: "빈 상태 이미지가 표시되어야 합니다")
        }
    }
    
    func testNavigationBarElements() throws {
        assertNavigationToTab("홈")
        
        let navigationBar = app.navigationBars.firstMatch
        assertElementExists(navigationBar, message: "네비게이션 바가 존재해야 합니다")
        
        assertTextExists("PocketMovie")
        
        // 더보기 버튼 확인
        let moreButton = app.navigationBars.buttons.matching(identifier: "ellipsis").firstMatch
        assertElementExists(moreButton, message: "더보기 버튼이 존재해야 합니다")
    }
    
    // MARK: - 빈 상태 화면 테스트
    func testEmptyStateDisplay() throws {
        assertNavigationToTab("홈")
        
        if app.isEmptyStateDisplayed() {
            let emptyStateImage = app.images["film"]
            let emptyStateText = app.staticTexts["영화를 추가해보세요!"]
            
            assertElementExists(emptyStateImage, message: "빈 상태 이미지가 표시되어야 합니다")
            assertElementExists(emptyStateText, message: "빈 상태 텍스트가 표시되어야 합니다")
            
            // 빈 상태에서는 선택 모드 버튼이 작동하지 않아야 함
            let moreButton = app.navigationBars.buttons.matching(identifier: "ellipsis").firstMatch
            if moreButton.exists {
                moreButton.tap()
                // 여전히 빈 상태여야 함
                assertElementExists(emptyStateImage, message: "빈 상태에서는 선택 모드가 의미가 없습니다")
            }
        }
    }
    
    // MARK: - 탭 네비게이션 테스트
    func testTabNavigation() throws {
        assertNavigationToTab("홈")
        assertTextExists("PocketMovie")
        
        assertNavigationToTab("검색")
        let searchField = app.textFields["영화 제목 검색"]
        assertElementExists(searchField, message: "검색 화면의 검색 필드가 표시되어야 합니다")
        
        assertNavigationToTab("설정")
        assertTextExists("설정")
        
        assertNavigationToTab("홈")
        assertTextExists("PocketMovie")
    }
    
    // MARK: - 영화 카드 상호작용 테스트 (영화가 있는 경우)
    func testMovieCardInteractionWhenMoviesExist() throws {
        assertNavigationToTab("홈")
        
        let movieCards = app.getMovieCards()
        
        if movieCards.count > 0 {
            let success = app.tapMovieCard(at: 0)
            XCTAssertTrue(success, "영화 카드를 탭할 수 있어야 합니다")
            
            app.tapMovieCard(at: 0)
        } else {
            print("테스트를 위한 영화 카드가 없습니다.")
        }
    }
    
    // MARK: - 선택 모드 테스트
    func testSelectionModeToggle() throws {
        assertNavigationToTab("홈")
        
        let enterSuccess = app.enterSelectionMode()
        if enterSuccess {
            let checkmarkButton = app.navigationBars.buttons.matching(identifier: "checkmark.circle.fill").firstMatch
            assertElementExists(checkmarkButton, timeout: 5, message: "선택 모드에서 체크마크 버튼이 표시되어야 합니다")
            
            let exitSuccess = app.exitSelectionMode()
            XCTAssertTrue(exitSuccess, "선택 모드를 종료할 수 있어야 합니다")
            
            let moreButton = app.navigationBars.buttons.matching(identifier: "ellipsis").firstMatch
            assertElementExists(moreButton, timeout: 5, message: "선택 모드 종료 후 더보기 버튼이 다시 표시되어야 합니다")
        }
    }
    
    func testSelectionModeWithMovieCards() throws {
        assertNavigationToTab("홈")
        
        let movieCards = app.getMovieCards()
        
        if movieCards.count > 0 {
            let enterSuccess = app.enterSelectionMode()
            XCTAssertTrue(enterSuccess, "선택 모드에 진입할 수 있어야 합니다")
            
            app.tapMovieCard(at: 0)
            
            let deleteButton = app.buttons.matching(identifier: "trash.fill").firstMatch
            assertElementExists(deleteButton, timeout: 5, message: "영화 선택 후 삭제 버튼이 표시되어야 합니다")
            
            app.exitSelectionMode()
            
            assertElementNotExists(deleteButton, timeout: 5, message: "선택 모드 종료 후 삭제 버튼이 사라져야 합니다")
        } else {
            print("영화 카드 선택 테스트를 위한 영화가 없습니다.")
        }
    }
    
    // MARK: - 검색 화면에서 영화 추가 후 홈 화면 테스트
    func testNavigateToSearchAndBack() throws {
        assertNavigationToTab("홈")
        
        assertNavigationToTab("검색")
        
        let searchField = app.textFields["영화 제목 검색"]
        assertElementExists(searchField, message: "검색 화면의 검색 필드가 표시되어야 합니다")
        
        assertNavigationToTab("홈")
        
        assertTextExists("PocketMovie")
    }
    
    // MARK: - 접근성 테스트
    func testAccessibility() throws {
        assertNavigationToTab("홈")
        
        let navigationBar = app.navigationBars.firstMatch
        XCTAssertTrue(navigationBar.isAccessibilityElement || navigationBar.children(matching: .any).count > 0)
        
        let moreButton = app.navigationBars.buttons.matching(identifier: "ellipsis").firstMatch
        if moreButton.exists {
            XCTAssertTrue(moreButton.isAccessibilityElement)
        }
        
        let homeTab = app.tabBars.buttons["홈"]
        XCTAssertTrue(homeTab.isAccessibilityElement)
        
        let searchTab = app.tabBars.buttons["검색"]
        XCTAssertTrue(searchTab.isAccessibilityElement)
        
        let settingsTab = app.tabBars.buttons["설정"]
        XCTAssertTrue(settingsTab.isAccessibilityElement)
    }
    
    // MARK: - 화면 회전 테스트
    func testOrientationChanges() throws {
        assertNavigationToTab("홈")
        
        XCUIDevice.shared.orientation = .landscapeLeft
        
        assertTextExists("PocketMovie", timeout: 5)
        
        XCUIDevice.shared.orientation = .portrait
        
        assertTextExists("PocketMovie", timeout: 5)
    }
    
    // MARK: - 성능 테스트
    func testHomeScreenLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let testApp = XCUIApplication()
            testApp.launchForUITests()
            
            let navigationBar = testApp.navigationBars.firstMatch
            _ = testApp.waitForElement(navigationBar, timeout: 10)
            
            testApp.terminate()
        }
    }
    
    // MARK: - 디버깅 테스트 (개발 중에만 사용)
    func testDebugAppHierarchy() throws {
        assertNavigationToTab("홈")
        
        printAppHierarchy()
        
        printElementsContaining("ellipsis")
        printElementsContaining("PocketMovie")
        
        XCTAssertTrue(true)
    }
}
