// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Auth {
    internal enum Common {
      /// Password
      internal static let password = L10n.tr("Localizable", "auth.common.password", fallback: "Password")
    }
    internal enum Login {
      /// Create account
      internal static let createAccount = L10n.tr("Localizable", "auth.login.create_account", fallback: "Create account")
      /// Welcome back
      internal static let headline = L10n.tr("Localizable", "auth.login.headline", fallback: "Welcome back")
      /// Username or email
      internal static let identifier = L10n.tr("Localizable", "auth.login.identifier", fallback: "Username or email")
      /// Email
      internal static let identifierLabel = L10n.tr("Localizable", "auth.login.identifier_label", fallback: "Email")
      /// Log In
      internal static let submit = L10n.tr("Localizable", "auth.login.submit", fallback: "Log In")
      /// Sign in to continue collecting stories, games, books, movies, and series that match your vibe.
      internal static let subtitle = L10n.tr("Localizable", "auth.login.subtitle", fallback: "Sign in to continue collecting stories, games, books, movies, and series that match your vibe.")
      /// Log In
      internal static let title = L10n.tr("Localizable", "auth.login.title", fallback: "Log In")
    }
    internal enum Onboarding {
      /// Sign in
      internal static let signIn = L10n.tr("Localizable", "auth.onboarding.sign_in", fallback: "Sign in")
      /// Start exploring
      internal static let start = L10n.tr("Localizable", "auth.onboarding.start", fallback: "Start exploring")
      /// Describe what you feel like watching, reading or playing. VibeFinder will find something that fits.
      internal static let subtitle = L10n.tr("Localizable", "auth.onboarding.subtitle", fallback: "Describe what you feel like watching, reading or playing. VibeFinder will find something that fits.")
      /// Find something that matches your vibe.
      internal static let title = L10n.tr("Localizable", "auth.onboarding.title", fallback: "Find something that matches your vibe.")
      /// matches your vibe
      internal static let titleHighlight = L10n.tr("Localizable", "auth.onboarding.title_highlight", fallback: "matches your vibe")
    }
    internal enum Prompt {
      /// Cozy game
      internal static let cozyGame = L10n.tr("Localizable", "auth.prompt.cozy_game", fallback: "Cozy game")
      /// Dark detective series
      internal static let darkDetectiveSeries = L10n.tr("Localizable", "auth.prompt.dark_detective_series", fallback: "Dark detective series")
      /// Emotional sci-fi
      internal static let emotionalScifi = L10n.tr("Localizable", "auth.prompt.emotional_scifi", fallback: "Emotional sci-fi")
      /// Rainy night movie
      internal static let rainyNightMovie = L10n.tr("Localizable", "auth.prompt.rainy_night_movie", fallback: "Rainy night movie")
      /// Slow Sunday
      internal static let slowSunday = L10n.tr("Localizable", "auth.prompt.slow_sunday", fallback: "Slow Sunday")
      /// Something weird
      internal static let somethingWeird = L10n.tr("Localizable", "auth.prompt.something_weird", fallback: "Something weird")
    }
    internal enum Register {
      /// Confirm password
      internal static let confirmPassword = L10n.tr("Localizable", "auth.register.confirm_password", fallback: "Confirm password")
      /// Email
      internal static let email = L10n.tr("Localizable", "auth.register.email", fallback: "Email")
      /// First name
      internal static let firstName = L10n.tr("Localizable", "auth.register.first_name", fallback: "First name")
      /// I already have an account
      internal static let haveAccount = L10n.tr("Localizable", "auth.register.have_account", fallback: "I already have an account")
      /// Create your account
      internal static let headline = L10n.tr("Localizable", "auth.register.headline", fallback: "Create your account")
      /// Last name
      internal static let lastName = L10n.tr("Localizable", "auth.register.last_name", fallback: "Last name")
      /// Register
      internal static let submit = L10n.tr("Localizable", "auth.register.submit", fallback: "Register")
      /// Use the same details that will identify your VibeFinder profile.
      internal static let subtitle = L10n.tr("Localizable", "auth.register.subtitle", fallback: "Use the same details that will identify your VibeFinder profile.")
      /// Almost there
      internal static let successTitle = L10n.tr("Localizable", "auth.register.success_title", fallback: "Almost there")
      /// Registration
      internal static let title = L10n.tr("Localizable", "auth.register.title", fallback: "Registration")
      /// Username
      internal static let username = L10n.tr("Localizable", "auth.register.username", fallback: "Username")
    }
    internal enum Validation {
      /// Passwords do not match.
      internal static let passwordMismatch = L10n.tr("Localizable", "auth.validation.password_mismatch", fallback: "Passwords do not match.")
      /// Fill in all required fields.
      internal static let requiredFields = L10n.tr("Localizable", "auth.validation.required_fields", fallback: "Fill in all required fields.")
    }
  }
  internal enum Common {
    /// Back
    internal static let back = L10n.tr("Localizable", "common.back", fallback: "Back")
    /// OK
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
  }
  internal enum Error {
    /// We could not read the server response.
    internal static let decoding = L10n.tr("Localizable", "error.decoding", fallback: "We could not read the server response.")
    /// Request failed with status code %d.
    internal static func httpStatus(_ p1: Int) -> String {
      return L10n.tr("Localizable", "error.http_status", p1, fallback: "Request failed with status code %d.")
    }
    /// Check your connection and try again.
    internal static let network = L10n.tr("Localizable", "error.network", fallback: "Check your connection and try again.")
    /// Something went wrong. Please try again.
    internal static let unknown = L10n.tr("Localizable", "error.unknown", fallback: "Something went wrong. Please try again.")
  }
  internal enum Home {
    /// VibeFinder
    internal static let title = L10n.tr("Localizable", "home.title", fallback: "VibeFinder")
    /// Welcome, %@.
    internal static func welcome(_ p1: Any) -> String {
      return L10n.tr("Localizable", "home.welcome", String(describing: p1), fallback: "Welcome, %@.")
    }
  }
  internal enum Search {
    /// VibeFinder
    internal static let brand = L10n.tr("Localizable", "search.brand", fallback: "VibeFinder")
    /// What are you in the mood for?
    internal static let title = L10n.tr("Localizable", "search.title", fallback: "What are you in the mood for?")
    internal enum Prompt {
      /// Describe a movie, series, game, book or just a feeling...
      internal static let placeholder = L10n.tr("Localizable", "search.prompt.placeholder", fallback: "Describe a movie, series, game, book or just a feeling...")
      /// Describe a feeling
      internal static let title = L10n.tr("Localizable", "search.prompt.title", fallback: "Describe a feeling")
    }
    internal enum Recent {
      /// 11 recommendations · 3 days ago
      internal static let detectiveSeriesSubtitle = L10n.tr("Localizable", "search.recent.detective_series_subtitle", fallback: "11 recommendations · 3 days ago")
      /// Dark detective series with smart writing
      internal static let detectiveSeriesTitle = L10n.tr("Localizable", "search.recent.detective_series_title", fallback: "Dark detective series with smart writing")
      /// 12 recommendations · Today
      internal static let rainyEveningSubtitle = L10n.tr("Localizable", "search.recent.rainy_evening_subtitle", fallback: "12 recommendations · Today")
      /// Something atmospheric for a rainy evening
      internal static let rainyEveningTitle = L10n.tr("Localizable", "search.recent.rainy_evening_title", fallback: "Something atmospheric for a rainy evening")
      /// See all
      internal static let seeAll = L10n.tr("Localizable", "search.recent.see_all", fallback: "See all")
      /// Recent vibes
      internal static let title = L10n.tr("Localizable", "search.recent.title", fallback: "Recent vibes")
      /// 9 recommendations · Yesterday
      internal static let weekendGameSubtitle = L10n.tr("Localizable", "search.recent.weekend_game_subtitle", fallback: "9 recommendations · Yesterday")
      /// A game I can finish this weekend
      internal static let weekendGameTitle = L10n.tr("Localizable", "search.recent.weekend_game_title", fallback: "A game I can finish this weekend")
    }
    internal enum Suggestion {
      /// Beautiful sci-fi
      internal static let beautifulScifi = L10n.tr("Localizable", "search.suggestion.beautiful_scifi", fallback: "Beautiful sci-fi")
      /// Cozy evening
      internal static let cozyEvening = L10n.tr("Localizable", "search.suggestion.cozy_evening", fallback: "Cozy evening")
      /// Dark mystery
      internal static let darkMystery = L10n.tr("Localizable", "search.suggestion.dark_mystery", fallback: "Dark mystery")
      /// Slow Sunday
      internal static let slowSunday = L10n.tr("Localizable", "search.suggestion.slow_sunday", fallback: "Slow Sunday")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
