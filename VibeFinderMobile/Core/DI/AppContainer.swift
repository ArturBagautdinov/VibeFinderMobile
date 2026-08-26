import Foundation
import Swinject

enum AppContainer {
    static func make() -> Container {
        let container = Container()
        _ = Assembler([AppAssembly(authRepositoryOverride: authRepositoryOverride)], container: container)
        return container
    }

    private static var authRepositoryOverride: AuthRepositoryProtocol? {
        ProcessInfo.processInfo.arguments.contains("-ui-testing") ? UITestAuthRepository() : nil
    }
}
