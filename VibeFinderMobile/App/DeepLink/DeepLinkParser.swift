import Foundation

nonisolated struct DeepLinkParser: Sendable {
    let allowedHost: String

    func parse(_ url: URL) -> DeepLinkRoute? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "https",
              components.host?.lowercased() == allowedHost.lowercased(),
              components.port == nil,
              components.user == nil,
              components.password == nil else {
            return nil
        }

        let prefix = "/media/"
        guard components.percentEncodedPath.hasPrefix(prefix) else { return nil }

        let identifier = components.percentEncodedPath.dropFirst(prefix.count)
        guard !identifier.isEmpty,
              identifier.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
              let mediaId = Int(identifier),
              mediaId > 0 else {
            return nil
        }

        return .mediaDetails(mediaId: mediaId)
    }
}
