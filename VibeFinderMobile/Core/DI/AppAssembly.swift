import Alamofire
import Foundation
import Swinject

final class AppAssembly: Assembly {
    private let environment: AppEnvironment

    init(environment: AppEnvironment = .current) {
        self.environment = environment
    }

    func assemble(container: Container) {
        container.register(AppEnvironment.self) { [environment] _ in
            environment
        }
        .inObjectScope(.container)

        container.register(KeychainStoring.self) { _ in
            KeychainStorage(service: Bundle.main.bundleIdentifier ?? "VibeFinderMobile")
        }
        .inObjectScope(.container)

        container.register(TokenStorage.self) { resolver in
            KeychainTokenStorage(keychainStorage: resolver.resolve(KeychainStoring.self)!)
        }
        .inObjectScope(.container)

        container.register(Session.self) { _ in
            .default
        }
        .inObjectScope(.container)

        container.register(APIClientProtocol.self) { resolver in
            APIClient(
                baseURL: resolver.resolve(AppEnvironment.self)!.baseURL,
                session: resolver.resolve(Session.self)!
            )
        }
        .inObjectScope(.container)

        container.register(AuthRepositoryProtocol.self) { resolver in
            AuthRepository(
                apiClient: resolver.resolve(APIClientProtocol.self)!,
                tokenStorage: resolver.resolve(TokenStorage.self)!
            )
        }
        .inObjectScope(.container)

        container.register(LoginViewModel.self) { resolver in
            LoginViewModel(authRepository: resolver.resolve(AuthRepositoryProtocol.self)!)
        }

        container.register(RegisterViewModel.self) { resolver in
            RegisterViewModel(authRepository: resolver.resolve(AuthRepositoryProtocol.self)!)
        }
    }
}
