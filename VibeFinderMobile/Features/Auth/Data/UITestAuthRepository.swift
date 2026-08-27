//
//  UITestAuthRepository.swift
//  VibeFinderMobile
//
//  Created by Artur Bagautdinov on 25.08.2026.
//

import Foundation

final class UITestAuthRepository: AuthRepositoryProtocol {
    private var arguments: [String] {
        ProcessInfo.processInfo.arguments
    }

    func login(
        login: String,
        password: String,
        completion: @escaping (Result<AuthSession, APIError>) -> Void
    ) {
        if arguments.contains("-ui-testing-login-failure") {
            completion(.failure(.statusCode(401)))
            return
        }

        completion(.success(AuthSession(username: login, displayName: "UI Test User")))
    }

    func register(
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        password: String,
        confirmPassword: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    ) {
        if arguments.contains("-ui-testing-register-failure") {
            completion(.failure(.statusCode(409)))
            return
        }

        completion(.success(FormSubmission(message: "Verification email has been sent.")))
    }

    func refreshSession(completion: @escaping (Result<AuthSession, APIError>) -> Void) {
        guard arguments.contains("-ui-testing-restored-session") else {
            completion(.failure(.statusCode(401)))
            return
        }

        completion(.success(AuthSession(username: "ui-test", displayName: "UI Test User")))
    }

    func logout(completion: @escaping (Result<Void, APIError>) -> Void) {
        completion(.success(()))
    }

    func resendEmailVerification(
        email: String,
        completion: @escaping (Result<FormSubmission, APIError>) -> Void
    ) {
        completion(.success(FormSubmission(message: "Verification email has been sent.")))
    }

    func confirmEmailVerification(
        token: String,
        completion: @escaping (Result<EmailVerification, APIError>) -> Void
    ) {
        completion(
            .success(
                EmailVerification(
                    success: true,
                    status: "CONFIRMED",
                    type: "REGISTRATION",
                    email: "ui-test@example.com",
                    userId: 1,
                    message: "Email has been verified successfully."
                )
            )
        )
    }
}
