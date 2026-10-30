import Foundation
import Testing
@testable import VibeFinderMobile

@Suite
struct DeepLinkParserTests {
    private let parser = DeepLinkParser(allowedHost: "links.example.com")

    @Test
    func parsesMediaDetailsLink() throws {
        let url = try #require(URL(string: "https://links.example.com/media/123?source=share"))

        #expect(parser.parse(url) == .mediaDetails(mediaId: 123))
    }

    @Test(arguments: [
        "http://links.example.com/media/123",
        "vibefinder://links.example.com/media/123",
        "https://other.example.com/media/123",
        "https://links.example.com.evil.org/media/123",
        "https://user@links.example.com/media/123",
        "https://links.example.com:8443/media/123",
        "https://links.example.com/search/123",
        "https://links.example.com/media/123/extra",
        "https://links.example.com/media/%31%32%33",
        "https://links.example.com/media/0",
        "https://links.example.com/media/-1",
        "https://links.example.com/media/abc",
        "https://links.example.com/media/999999999999999999999999999999999999"
    ])
    func rejectsUnsupportedOrInvalidLinks(address: String) throws {
        let url = try #require(URL(string: address))

        #expect(parser.parse(url) == nil)
    }
}
