import XCTest

@MainActor
final class VibeFinderMobileUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = makeApp()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testLaunchShowsLoginScreenWithoutNavigationTitleOrBackButton() {
        app.launch()

        XCTAssertTrue(app.otherElements["auth.onboarding.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["auth.onboarding.titleLabel"].exists)
        XCTAssertTrue(app.buttons["auth.onboarding.startButton"].exists)
        XCTAssertTrue(app.buttons["auth.onboarding.signInButton"].exists)

        app.buttons["auth.onboarding.signInButton"].tap()

        XCTAssertTrue(app.otherElements["auth.login.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["auth.login.titleLabel"].exists)
        XCTAssertTrue(app.textFields["auth.login.identifierTextField"].exists)
        XCTAssertTrue(app.secureTextFields["auth.login.passwordTextField"].exists)
        XCTAssertTrue(app.buttons["auth.login.submitButton"].exists)
        XCTAssertTrue(app.buttons["auth.login.switchToRegisterButton"].exists)
        XCTAssertFalse(app.navigationBars["Log In"].exists)
        XCTAssertFalse(app.navigationBars["Вход"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Back"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Назад"].exists)
    }

    func testSwitchesBetweenLoginAndRegistrationScreens() {
        app.launch()
        openLogin()

        app.buttons["auth.login.switchToRegisterButton"].tap()

        XCTAssertTrue(app.otherElements["auth.register.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.textFields["auth.register.emailTextField"].exists)
        XCTAssertTrue(app.textFields["auth.register.usernameTextField"].exists)
        XCTAssertTrue(app.textFields["auth.register.firstNameTextField"].exists)
        XCTAssertTrue(app.textFields["auth.register.lastNameTextField"].exists)
        XCTAssertTrue(app.secureTextFields["auth.register.passwordTextField"].exists)
        XCTAssertTrue(app.secureTextFields["auth.register.confirmPasswordTextField"].exists)
        XCTAssertTrue(app.buttons["auth.register.switchToLoginButton"].exists)
        XCTAssertFalse(app.navigationBars["Registration"].exists)
        XCTAssertFalse(app.navigationBars["Регистрация"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Back"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Назад"].exists)

        app.buttons["auth.register.switchToLoginButton"].tap()

        XCTAssertTrue(app.otherElements["auth.login.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.textFields["auth.login.identifierTextField"].exists)
        XCTAssertFalse(app.textFields["auth.register.emailTextField"].exists)
    }

    func testLoginValidationShowsRequiredFieldsError() {
        app.launch()
        openLogin()

        app.buttons["auth.login.submitButton"].tap()

        let errorLabel = errorElement
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 1))
        XCTAssertFalse(errorLabel.label.isEmpty)
        XCTAssertTrue(app.otherElements["auth.login.screen"].exists)
    }

    func testLoginFailureShowsServerErrorAndStaysOnLogin() {
        app = makeApp(extraArguments: ["-ui-testing-login-failure"])
        app.launch()
        openLogin()

        app.textFields["auth.login.identifierTextField"].tap()
        app.typeText("artur")
        app.secureTextFields["auth.login.passwordTextField"].tap()
        app.typeText("wrong-password")
        dismissKeyboardIfNeeded()
        app.buttons["auth.login.submitButton"].tap()

        let errorLabel = errorElement
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2))
        XCTAssertFalse(errorLabel.label.isEmpty)
        XCTAssertTrue(app.otherElements["auth.login.screen"].exists)
        XCTAssertFalse(app.otherElements["home.screen"].exists)
    }

    func testSuccessfulLoginOpensHomeScreen() {
        app.launch()
        openLogin()

        app.textFields["auth.login.identifierTextField"].tap()
        app.typeText("artur")
        app.secureTextFields["auth.login.passwordTextField"].tap()
        app.typeText("password123")
        dismissKeyboardIfNeeded()
        app.buttons["auth.login.submitButton"].tap()

        XCTAssertTrue(app.otherElements["home.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["home.welcomeLabel"].exists)
        XCTAssertTrue(app.images["home.logo.image"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Back"].exists)
        XCTAssertFalse(app.navigationBars.buttons["Назад"].exists)
    }

    func testRegistrationValidationShowsRequiredFieldsError() {
        app.launch()
        openRegistration()

        app.buttons["auth.register.submitButton"].tap()

        let errorLabel = errorElement
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 1))
        XCTAssertFalse(errorLabel.label.isEmpty)
        XCTAssertTrue(app.otherElements["auth.register.screen"].exists)
    }

    func testSuccessfulRegistrationReturnsToLoginAndShowsSuccessAlert() {
        app.launch()
        openRegistration()

        fillRegistration()
        dismissKeyboardIfNeeded()
        scrollToButtonIfNeeded("auth.register.submitButton")
        app.buttons["auth.register.submitButton"].tap()

        XCTAssertTrue(app.otherElements["auth.login.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 2))
        app.alerts.firstMatch.buttons.firstMatch.tap()
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    func testRegistrationFailureShowsServerErrorAndStaysOnRegistration() {
        app = makeApp(extraArguments: ["-ui-testing-register-failure"])
        app.launch()
        openRegistration()

        fillRegistration()
        dismissKeyboardIfNeeded()
        scrollToButtonIfNeeded("auth.register.submitButton")
        app.buttons["auth.register.submitButton"].tap()
        scrollToErrorIfNeeded()

        XCTAssertTrue(app.otherElements["auth.register.screen"].exists)
        XCTAssertFalse(app.otherElements["auth.login.screen"].exists)
        XCTAssertFalse(app.otherElements["home.screen"].exists)
    }

    func testKeyboardCanBeDismissedOnLoginWithReturnKey() {
        app.launch()
        openLogin()

        app.textFields["auth.login.identifierTextField"].tap()
        app.typeText("artur")
        app.secureTextFields["auth.login.passwordTextField"].tap()
        app.typeText("password123")

        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 2))
        dismissKeyboardIfNeeded()

        XCTAssertFalse(app.keyboards.firstMatch.waitForExistence(timeout: 1))
    }

    func testRussianLocalizationSmoke() {
        app = makeApp(extraArguments: ["-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"])
        app.launch()

        XCTAssertTrue(app.otherElements["auth.onboarding.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Начать подбор"].exists)
        XCTAssertTrue(app.buttons["Войти"].exists)

        app.buttons["auth.onboarding.signInButton"].tap()

        XCTAssertTrue(app.otherElements["auth.login.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Войти"].exists)
        XCTAssertTrue(app.buttons["Создать аккаунт"].exists)

        app.buttons["auth.login.switchToRegisterButton"].tap()

        XCTAssertTrue(app.otherElements["auth.register.screen"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Зарегистрироваться"].exists)
        XCTAssertTrue(app.buttons["У меня уже есть аккаунт"].exists)
    }

    private func makeApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"] + extraArguments
        return app
    }

    private func openLogin() {
        if app.otherElements["auth.login.screen"].exists {
            return
        }

        app.buttons["auth.onboarding.signInButton"].tap()
        XCTAssertTrue(app.otherElements["auth.login.screen"].waitForExistence(timeout: 2))
    }

    private func openRegistration() {
        if app.otherElements["auth.register.screen"].exists {
            return
        }

        if app.otherElements["auth.onboarding.screen"].exists {
            app.buttons["auth.onboarding.startButton"].tap()
        } else {
            app.buttons["auth.login.switchToRegisterButton"].tap()
        }
        XCTAssertTrue(app.otherElements["auth.register.screen"].waitForExistence(timeout: 2))
    }

    private var errorElement: XCUIElement {
        app.descendants(matching: .any)["auth.errorLabel"]
    }

    private func fillRegistration(
        password: String = "password123",
        confirmPassword: String = "password123"
    ) {
        app.textFields["auth.register.emailTextField"].tap()
        app.typeText("artur@example.com")
        app.textFields["auth.register.usernameTextField"].tap()
        app.typeText("artur")
        app.textFields["auth.register.firstNameTextField"].tap()
        app.typeText("Artur")
        app.textFields["auth.register.lastNameTextField"].tap()
        app.typeText("Bagautdinov")
        app.secureTextFields["auth.register.passwordTextField"].tap()
        app.typeText(password)
        app.secureTextFields["auth.register.confirmPasswordTextField"].tap()
        app.typeText(confirmPassword)
    }

    private func dismissKeyboardIfNeeded() {
        guard app.keyboards.firstMatch.waitForExistence(timeout: 1) else {
            return
        }

        app.typeText("\n")
        if !app.keyboards.firstMatch.waitForExistence(timeout: 1) {
            return
        }

        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
    }

    private func scrollToButtonIfNeeded(_ identifier: String) {
        let button = app.buttons[identifier]
        guard button.exists else {
            return
        }

        for _ in 0..<3 where !button.isHittable {
            app.scrollViews.firstMatch.swipeUp()
        }

        XCTAssertTrue(button.isHittable)
    }

    private func scrollToErrorIfNeeded() {
        for _ in 0..<3 where !errorElement.exists {
            app.scrollViews.firstMatch.swipeDown()
        }
    }
}
