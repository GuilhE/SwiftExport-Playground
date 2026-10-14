import XCTest

@MainActor final class DemoTourUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCoroutinesTab() {
        XCUIDevice.shared.press(.home)
        let app = XCUIApplication()
        app.launch()

        let cancelButtons = app.buttons.matching(identifier: "Cancel")

        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["Flow"]/*[[".otherElements.buttons[\"Flow\"]",".buttons[\"Flow\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app.buttons["Flow"].tap()
        sleep(1)
        app.buttons["Update"].tap()
        sleep(1)
        app.buttons["Update"].tap()
        sleep(1)
        app.buttons["Update"].tap()
        sleep(1)
        app.buttons["Update"].tap()
        sleep(1)
        app.buttons["Stop"].tap()

        sleep(1)
        app.navigationBars.buttons["trash"].tap()
        
        app.buttons["suspend fun (2s delay)"].tap()
        sleep(3)
        app.buttons["suspend fun (2s delay)"].tap()
        sleep(1)
        cancelButtons.element(boundBy: 0).tap()

        sleep(1)
        app.navigationBars.buttons["trash"].tap()
        
        app.buttons["Flow (restart-collect)"].tap()
        sleep(4)
        app.buttons["Flow (restart-collect)"].tap()
        sleep(1)
        app.buttons["Flow (restart-collect)"].tap()
        sleep(2)
        cancelButtons.element(boundBy: 1).tap()

        sleep(1)
        app.navigationBars.buttons["trash"].tap()
        
        app.buttons["Flow (infinite spawn)"].tap()
        sleep(1)
        app.buttons["Flow (infinite spawn)"].tap()
        app.buttons["Flow (infinite spawn)"].tap()
        
        sleep(4)
        app.navigationBars.buttons["trash"].tap()
        
        sleep(3)
    }

    func testSealedClassesTab() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Sealed classes"].tap()

        for _ in 0..<8 {
            app.buttons["Advance state"].tap()
            sleep(1)
        }
        
        sleep(1)
        app.buttons["Reset"].tap()
        
        sleep(3)
    }

    func testInheritanceTab() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Inheritance"].tap()

        let startButtons = app.buttons.matching(identifier: "Start")
        let stopButtons = app.buttons.matching(identifier: "Stop")

        startButtons.element(boundBy: 0).tap()
        sleep(4)
        stopButtons.element(boundBy: 0).tap()
        sleep(1)
        startButtons.element(boundBy: 0).tap()
        sleep(2)
        stopButtons.element(boundBy: 0).tap()
        
        sleep(1)
        app.navigationBars.buttons["trash"].tap()
        
        startButtons.element(boundBy: 1).tap()
        sleep(4)
        stopButtons.element(boundBy: 0).tap()
        
        sleep(1)
        app.navigationBars.buttons["trash"].tap()
        
        sleep(3)
    }
}
