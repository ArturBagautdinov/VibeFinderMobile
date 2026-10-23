import Foundation
import Testing
import UIKit
@testable import VibeFinderMobile

@Suite
@MainActor
struct FavoritesPresentationTests {
    @Test
    func itemMappingUsesLocalizedTypeAndMatchingSymbol() {
        let expected: [(MediaType, String, String)] = [
            (.movie, L10n.Media.Details.movie, "film.fill"),
            (.series, L10n.Media.Details.series, "tv.fill"),
            (.book, L10n.Media.Details.book, "book.closed.fill"),
            (.game, L10n.Media.Details.game, "gamecontroller.fill")
        ]

        for (mediaType, expectedType, expectedSymbol) in expected {
            let model = FavoriteItemDisplayModel(item: makeItem(mediaType: mediaType))
            #expect(model.mediaType == expectedType)
            #expect(model.fallbackSymbol == expectedSymbol)
            #expect(model.releaseYear == "2016")
            #expect(model.description == "A quiet story")
        }
    }

    @Test
    func viewRendersEmptyErrorAndItemsWithoutLosingScreen() {
        let view = FavoritesView(imageLoader: FavoritesImageLoaderSpy())
        #expect(view.accessibilityIdentifier == "favorites.screen")

        view.render(.init(content: .empty, isLoading: false, errorMessage: nil))
        #expect(view.findView("favorites.empty")?.isHidden == false)
        #expect(view.findView("favorites.error")?.isHidden == true)

        view.render(.init(content: .notLoaded, isLoading: false, errorMessage: "Offline"))
        #expect(view.findView("favorites.empty")?.isHidden == true)
        #expect(view.findView("favorites.error")?.isHidden == false)

        view.render(.init(content: .items([makeItem(mediaType: .game)]), isLoading: true, errorMessage: nil))
        #expect(view.findView("favorites.empty")?.isHidden == true)
        #expect(view.findView("favorites.error")?.isHidden == true)
    }

    private func makeItem(mediaType: MediaType) -> FavoriteItem {
        FavoriteItem(
            mediaId: 5,
            title: "Arrival",
            mediaType: mediaType,
            releaseYear: 2016,
            imageUrl: nil,
            shortDescription: "  A quiet story  "
        )
    }
}

private extension UIView {
    func findView(_ identifier: String) -> UIView? {
        if accessibilityIdentifier == identifier { return self }
        for subview in subviews {
            if let found = subview.findView(identifier) { return found }
        }
        return nil
    }
}

private final class FavoritesImageLoaderSpy: RemoteImageLoading {
    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
        completion(nil)
        return nil
    }
}
