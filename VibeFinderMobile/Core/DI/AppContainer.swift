import Swinject

enum AppContainer {
    static func make() -> Container {
        let container = Container()
        Assembler([AppAssembly()], container: container)
        return container
    }
}
