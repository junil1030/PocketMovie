//
//  UITestHelpers.swift
//  PocketMovieUITests
//
//  Created by 서준일 on 5/23/25.
//

import XCTest

// MARK: - XCUIApplication 확장
extension XCUIApplication {
    
    // MARK: - 앱 실행 헬퍼
    func launchForUITests() {
        launchArguments.append("--uitesting")
        launchEnvironment["UITEST_MODE"] = "true"
        launchEnvironment["ANIMATION_SPEED"] = "0.1"
        launch()
    }
    
    // MARK: - 대기 헬퍼
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            if element.exists && element.isHittable {
                return true
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        return false
    }
    
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 10) -> Bool {
        let endTime = Date().addingTimeInterval(timeout)
        
        while Date() < endTime {
            if !element.exists {
                return true
            }
            Thread.sleep(forTimeInterval: 0.5)
        }
        return false
    }
    
    func waitForText(_ text: String, timeout: TimeInterval = 10) -> Bool {
        let element = staticTexts[text]
        return waitForElement(element, timeout: timeout)
    }
    
    // MARK: - 네비게이션 헬퍼
    func navigateToTab(_ tabName: String, timeout: TimeInterval = 5) -> Bool {
        let tabButton = tabBars.buttons[tabName]
        if waitForElement(tabButton, timeout: timeout) {
            tabButton.tap()
            return true
        }
        return false
    }
    
    // MARK: - 홈 화면 전용 헬퍼
    func isEmptyStateDisplayed() -> Bool {
        let emptyStateImage = images["film"]
        let emptyStateText = staticTexts["영화를 추가해보세요!"]
        return emptyStateImage.exists && emptyStateText.exists
    }
    
    func getMovieCards() -> [XCUIElement] {
        let scrollView = scrollViews.firstMatch
        if scrollView.exists {
            return scrollView.otherElements.allElementsBoundByAccessibilityElement
        }
        return []
    }
    
    func tapMovieCard(at index: Int = 0) -> Bool {
        let cards = getMovieCards()
        if cards.count > index {
            let card = cards[index]
            if waitForElement(card) {
                card.tap()
                return true
            }
        }
        return false
    }
    
    // MARK: - 선택 모드 헬퍼
    func enterSelectionMode() -> Bool {
        let moreButton = navigationBars.buttons.matching(identifier: "ellipsis").firstMatch
        if waitForElement(moreButton) {
            moreButton.tap()
            return true
        }
        return false
    }
    
    func exitSelectionMode() -> Bool {
        let checkmarkButton = navigationBars.buttons.matching(identifier: "checkmark.circle.fill").firstMatch
        if waitForElement(checkmarkButton) {
            checkmarkButton.tap()
            return true
        }
        return false
    }
    
    func deleteSelectedMovies() -> Bool {
        let deleteButton = buttons.matching(identifier: "trash.fill").firstMatch
        if waitForElement(deleteButton) {
            deleteButton.tap()
            return true
        }
        return false
    }
    
    // MARK: - 유틸리티 헬퍼
    func hideKeyboard() {
        if keyboards.count > 0 {
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        }
    }
    
    func takeScreenshot(name: String) -> XCTAttachment {
        let screenshot = screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        return attachment
    }
}

// MARK: - XCUIElement 확장
extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard self.value != nil else {
            return
        }
        
        self.tap()
        
        let selectAllMenuItem = XCUIApplication().menuItems["Select All"]
        if selectAllMenuItem.exists {
            selectAllMenuItem.tap()
        } else {
            self.doubleTap()
        }
        
        self.typeText(text)
    }
}

// MARK: - 기본 UI 테스트 클래스
class BaseUITestCase: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchForUITests()
        
        // 앱이 완전히 로드될 때까지 대기
        XCTAssertTrue(app.waitForText("PocketMovie", timeout: 15), "앱이 정상적으로 로드되지 않았습니다")
    }
    
    override func tearDownWithError() throws {
        // 테스트 실패 시 스크린샷 첨부
        if let testRun = testRun, testRun.hasSucceeded == false {
            let screenshot = app.takeScreenshot(name: "실패_스크린샷_\(name)")
            add(screenshot)
        }
        
        app.terminate()
        app = nil
    }
    
    // MARK: - 어설션 헬퍼
    func assertElementExists(_ element: XCUIElement,
                           timeout: TimeInterval = 10,
                           message: String = "",
                           file: StaticString = #file,
                           line: UInt = #line) {
        let exists = app.waitForElement(element, timeout: timeout)
        let errorMessage = message.isEmpty ? "Element should exist: \(element)" : message
        XCTAssertTrue(exists, errorMessage, file: file, line: line)
    }
    
    func assertElementNotExists(_ element: XCUIElement,
                              timeout: TimeInterval = 10,
                              message: String = "",
                              file: StaticString = #file,
                              line: UInt = #line) {
        let notExists = app.waitForElementToDisappear(element, timeout: timeout)
        let errorMessage = message.isEmpty ? "Element should not exist: \(element)" : message
        XCTAssertTrue(notExists, errorMessage, file: file, line: line)
    }
    
    func assertTextExists(_ text: String,
                         timeout: TimeInterval = 10,
                         file: StaticString = #file,
                         line: UInt = #line) {
        XCTAssertTrue(
            app.waitForText(text, timeout: timeout),
            "Text should exist: '\(text)'",
            file: file,
            line: line
        )
    }
    
    func assertNavigationToTab(_ tabName: String,
                              file: StaticString = #file,
                              line: UInt = #line) {
        XCTAssertTrue(
            app.navigateToTab(tabName),
            "Should be able to navigate to tab: \(tabName)",
            file: file,
            line: line
        )
    }
    
    // MARK: - 디버깅 헬퍼
    func printAppHierarchy() {
        print("=== App Hierarchy ===")
        print(app.debugDescription)
        print("====================")
    }
    
    func printElementsContaining(_ text: String) {
        print("=== Elements containing '\(text)' ===")
        let elements = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", text))
        for i in 0..<elements.count {
            let element = elements.element(boundBy: i)
            print("[\(i)] \(element.elementType): '\(element.label)' - exists: \(element.exists)")
        }
        print("=====================================")
    }
}
