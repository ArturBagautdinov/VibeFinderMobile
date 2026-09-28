import Alamofire
import Foundation
import Swinject

final class AppAssembly: Assembly {
    private let environment: AppEnvironment
    private let authRepositoryOverride: AuthRepositoryProtocol?

    init(
        environment: AppEnvironment = .current,
        authRepositoryOverride: AuthRepositoryProtocol? = nil
    ) {
        self.environment = environment
        self.authRepositoryOverride = authRepositoryOverride
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
                session: resolver.resolve(Session.self)!,
                tokenStorage: resolver.resolve(TokenStorage.self)!
            )
        }
        .inObjectScope(.container)

        container.register(AuthRepositoryProtocol.self) { [authRepositoryOverride] resolver in
            if let authRepositoryOverride {
                return authRepositoryOverride
            }
            return AuthRepository(
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

        container.register(SearchRepositoryProtocol.self) { resolver in
            SearchRepository(apiClient: resolver.resolve(APIClientProtocol.self)!)
        }
        .inObjectScope(.container)

        container.register(CoreDataStack.self) { _ in
            CoreDataStack()
        }
        .inObjectScope(.container)

        container.register(SearchSuggestionsStoreProtocol.self) { resolver in
            CoreDataSearchSuggestionsStore(coreDataStack: resolver.resolve(CoreDataStack.self)!)
        }
        .inObjectScope(.container)

        container.register(SearchResultImageLoading.self) { _ in
            SearchResultImageLoader()
        }
        .inObjectScope(.container)

        container.register(SearchHistoryViewModel.self) { resolver in
            SearchHistoryViewModel(searchRepository: resolver.resolve(SearchRepositoryProtocol.self)!)
        }

        container.register(SearchViewModel.self) { resolver, username in
            SearchViewModel(
                username: username,
                searchRepository: resolver.resolve(SearchRepositoryProtocol.self)!,
                suggestionsStore: resolver.resolve(SearchSuggestionsStoreProtocol.self)!
            )
        }
        
        container.register(ProfileRepositoryProtocol.self) { resolver in
            ProfileRepository(apiClient: resolver.resolve(APIClientProtocol.self)!,
                              authRepository: resolver.resolve(AuthRepositoryProtocol.self)!
            )
            
        }
        .inObjectScope(.container)
        
        container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                profileRepository: resolver.resolve(ProfileRepositoryProtocol.self)!
            )
        }
        .inObjectScope(.container)

        container.register(EditProfileViewModel.self) { resolver, profile in
            EditProfileViewModel(
                profile: profile,
                repository: resolver.resolve(ProfileRepositoryProtocol.self)!
            )
        }
    }
}
