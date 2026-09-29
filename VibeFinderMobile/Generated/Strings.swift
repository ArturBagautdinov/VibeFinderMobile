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
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// OK
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
    /// Retry
    internal static let retry = L10n.tr("Localizable", "common.retry", fallback: "Retry")
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
  internal enum Profile {
    /// Email not verified
    internal static let notVerified = L10n.tr("Localizable", "profile.notVerified", fallback: "Email not verified")
    /// Your vibe summary
    internal static let summaryTitle = L10n.tr("Localizable", "profile.summaryTitle", fallback: "Your vibe summary")
    /// Taste profile
    internal static let tasteTitle = L10n.tr("Localizable", "profile.tasteTitle", fallback: "Taste profile")
    /// Email verified
    internal static let verified = L10n.tr("Localizable", "profile.verified", fallback: "Email verified")
    internal enum Edit {
      /// Avatar
      internal static let avatar = L10n.tr("Localizable", "profile.edit.avatar", fallback: "Avatar")
      /// Choose a background
      internal static let chooseColor = L10n.tr("Localizable", "profile.edit.chooseColor", fallback: "Choose a background")
      /// Choose a symbol
      internal static let chooseSymbol = L10n.tr("Localizable", "profile.edit.chooseSymbol", fallback: "Choose a symbol")
      /// Color
      internal static let color = L10n.tr("Localizable", "profile.edit.color", fallback: "Color")
      /// Discard
      internal static let discardAction = L10n.tr("Localizable", "profile.edit.discardAction", fallback: "Discard")
      /// Your profile changes have not been saved.
      internal static let discardMessage = L10n.tr("Localizable", "profile.edit.discardMessage", fallback: "Your profile changes have not been saved.")
      /// Discard changes?
      internal static let discardTitle = L10n.tr("Localizable", "profile.edit.discardTitle", fallback: "Discard changes?")
      /// None
      internal static let `none` = L10n.tr("Localizable", "profile.edit.none", fallback: "None")
      /// Personal details
      internal static let personal = L10n.tr("Localizable", "profile.edit.personal", fallback: "Personal details")
      /// Save changes
      internal static let save = L10n.tr("Localizable", "profile.edit.save", fallback: "Save changes")
      /// Symbol
      internal static let symbol = L10n.tr("Localizable", "profile.edit.symbol", fallback: "Symbol")
      /// Edit profile
      internal static let title = L10n.tr("Localizable", "profile.edit.title", fallback: "Edit profile")
      /// First and last name must contain 2–80 characters.
      internal static let validationLength = L10n.tr("Localizable", "profile.edit.validationLength", fallback: "First and last name must contain 2–80 characters.")
      /// Enter your first and last name.
      internal static let validationRequired = L10n.tr("Localizable", "profile.edit.validationRequired", fallback: "Enter your first and last name.")
    }
    internal enum Logout {
      /// Log out
      internal static let action = L10n.tr("Localizable", "profile.logout.action", fallback: "Log out")
      /// You will need to sign in again to use VibeFinder.
      internal static let message = L10n.tr("Localizable", "profile.logout.message", fallback: "You will need to sign in again to use VibeFinder.")
      /// Log out?
      internal static let title = L10n.tr("Localizable", "profile.logout.title", fallback: "Log out?")
    }
    internal enum Section {
      /// Atmospheres
      internal static let atmospheres = L10n.tr("Localizable", "profile.section.atmospheres", fallback: "Atmospheres")
      /// Avoids
      internal static let disliked = L10n.tr("Localizable", "profile.section.disliked", fallback: "Avoids")
      /// Genres
      internal static let genres = L10n.tr("Localizable", "profile.section.genres", fallback: "Genres")
      /// Settings
      internal static let settings = L10n.tr("Localizable", "profile.section.settings", fallback: "Settings")
      /// Themes
      internal static let themes = L10n.tr("Localizable", "profile.section.themes", fallback: "Themes")
    }
    internal enum Stats {
      /// Completed
      internal static let completed = L10n.tr("Localizable", "profile.stats.completed", fallback: "Completed")
      /// Hidden
      internal static let hidden = L10n.tr("Localizable", "profile.stats.hidden", fallback: "Hidden")
      /// In progress
      internal static let inProgress = L10n.tr("Localizable", "profile.stats.inProgress", fallback: "In progress")
    }
  }
  internal enum Search {
    /// VibeFinder
    internal static let brand = L10n.tr("Localizable", "search.brand", fallback: "VibeFinder")
    /// What are you in the mood for?
    internal static let title = L10n.tr("Localizable", "search.title", fallback: "What are you in the mood for?")
    internal enum History {
      internal enum Clear {
        /// Clear
        internal static let button = L10n.tr("Localizable", "search.history.clear.button", fallback: "Clear")
        /// This will remove all search prompts from your history. You can delete search prompts one by one by swiping left.
        internal static let message = L10n.tr("Localizable", "search.history.clear.message", fallback: "This will remove all search prompts from your history. You can delete search prompts one by one by swiping left.")
        /// Clear search history?
        internal static let title = L10n.tr("Localizable", "search.history.clear.title", fallback: "Clear search history?")
      }
      internal enum Delete {
        /// Delete
        internal static let action = L10n.tr("Localizable", "search.history.delete.action", fallback: "Delete")
      }
    }
    internal enum Loading {
      /// Tuning the mood, genres and hidden signals.
      internal static let subtitle = L10n.tr("Localizable", "search.loading.subtitle", fallback: "Tuning the mood, genres and hidden signals.")
      /// Reading the shape of your mood.
      internal static let subtitleMood = L10n.tr("Localizable", "search.loading.subtitleMood", fallback: "Reading the shape of your mood.")
      /// Tuning into hidden genre signals.
      internal static let subtitleSignals = L10n.tr("Localizable", "search.loading.subtitleSignals", fallback: "Tuning into hidden genre signals.")
      /// Finding your vibe
      internal static let title = L10n.tr("Localizable", "search.loading.title", fallback: "Finding your vibe")
    }
    internal enum Prompt {
      /// Describe a movie, series, game, book or just a feeling...
      internal static let placeholder = L10n.tr("Localizable", "search.prompt.placeholder", fallback: "Describe a movie, series, game, book or just a feeling...")
      /// Search
      internal static let submit = L10n.tr("Localizable", "search.prompt.submit", fallback: "Search")
      /// Describe a feeling
      internal static let title = L10n.tr("Localizable", "search.prompt.title", fallback: "Describe a feeling")
    }
    internal enum Recent {
      /// 11 recommendations · 3 days ago
      internal static let detectiveSeriesSubtitle = L10n.tr("Localizable", "search.recent.detective_series_subtitle", fallback: "11 recommendations · 3 days ago")
      /// Dark detective series with smart writing
      internal static let detectiveSeriesTitle = L10n.tr("Localizable", "search.recent.detective_series_title", fallback: "Dark detective series with smart writing")
      /// Search for a mood, movie, game or book, and your successful vibes will appear here.
      internal static let emptySubtitle = L10n.tr("Localizable", "search.recent.empty_subtitle", fallback: "Search for a mood, movie, game or book, and your successful vibes will appear here.")
      /// No searches yet
      internal static let emptyTitle = L10n.tr("Localizable", "search.recent.empty_title", fallback: "No searches yet")
      /// Search history
      internal static let fullTitle = L10n.tr("Localizable", "search.recent.full_title", fallback: "Search history")
      /// %d items · %@
      internal static func itemSubtitle(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "search.recent.item_subtitle", p1, String(describing: p2), fallback: "%d items · %@")
      }
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
    internal enum Results {
      /// Your matches
      internal static let title = L10n.tr("Localizable", "search.results.title", fallback: "Your matches")
    }
    internal enum Suggestion {
      /// Beautiful sci-fi
      internal static let beautifulScifi = L10n.tr("Localizable", "search.suggestion.beautiful_scifi", fallback: "Beautiful sci-fi")
      /// Comfort book
      internal static let comfortBook = L10n.tr("Localizable", "search.suggestion.comfort_book", fallback: "Comfort book")
      /// Cosmic horror
      internal static let cosmicHorror = L10n.tr("Localizable", "search.suggestion.cosmic_horror", fallback: "Cosmic horror")
      /// Couch co-op game
      internal static let couchCoopGame = L10n.tr("Localizable", "search.suggestion.couch_coop_game", fallback: "Couch co-op game")
      /// Cozy evening
      internal static let cozyEvening = L10n.tr("Localizable", "search.suggestion.cozy_evening", fallback: "Cozy evening")
      /// Cozy game
      internal static let cozyGame = L10n.tr("Localizable", "search.suggestion.cozy_game", fallback: "Cozy game")
      /// Your vibe
      internal static let customPlaceholder = L10n.tr("Localizable", "search.suggestion.custom_placeholder", fallback: "Your vibe")
      /// Dark fantasy book
      internal static let darkFantasyBook = L10n.tr("Localizable", "search.suggestion.dark_fantasy_book", fallback: "Dark fantasy book")
      /// Dark mystery
      internal static let darkMystery = L10n.tr("Localizable", "search.suggestion.dark_mystery", fallback: "Dark mystery")
      /// Delete
      internal static let delete = L10n.tr("Localizable", "search.suggestion.delete", fallback: "Delete")
      /// Emotional sci-fi
      internal static let emotionalScifi = L10n.tr("Localizable", "search.suggestion.emotional_scifi", fallback: "Emotional sci-fi")
      /// Feel-good sitcom
      internal static let feelGoodSitcom = L10n.tr("Localizable", "search.suggestion.feel_good_sitcom", fallback: "Feel-good sitcom")
      /// Historical mystery
      internal static let historicalMystery = L10n.tr("Localizable", "search.suggestion.historical_mystery", fallback: "Historical mystery")
      /// Late-night thriller
      internal static let lateNightThriller = L10n.tr("Localizable", "search.suggestion.late_night_thriller", fallback: "Late-night thriller")
      /// Melancholic animation
      internal static let melancholicAnimation = L10n.tr("Localizable", "search.suggestion.melancholic_animation", fallback: "Melancholic animation")
      /// Mind-bending story
      internal static let mindBendingStory = L10n.tr("Localizable", "search.suggestion.mind_bending_story", fallback: "Mind-bending story")
      /// More
      internal static let more = L10n.tr("Localizable", "search.suggestion.more", fallback: "More")
      /// Mystical forest story
      internal static let mysticalForestStory = L10n.tr("Localizable", "search.suggestion.mystical_forest_story", fallback: "Mystical forest story")
      /// Post-apocalyptic drama
      internal static let postApocalypticDrama = L10n.tr("Localizable", "search.suggestion.post_apocalyptic_drama", fallback: "Post-apocalyptic drama")
      /// Rainy night movie
      internal static let rainyNightMovie = L10n.tr("Localizable", "search.suggestion.rainy_night_movie", fallback: "Rainy night movie")
      /// Restore default suggestions
      internal static let restoreDefaults = L10n.tr("Localizable", "search.suggestion.restore_defaults", fallback: "Restore default suggestions")
      /// Short indie game
      internal static let shortIndieGame = L10n.tr("Localizable", "search.suggestion.short_indie_game", fallback: "Short indie game")
      /// Slow Sunday
      internal static let slowSunday = L10n.tr("Localizable", "search.suggestion.slow_sunday", fallback: "Slow Sunday")
      /// Smart heist movie
      internal static let smartHeistMovie = L10n.tr("Localizable", "search.suggestion.smart_heist_movie", fallback: "Smart heist movie")
      /// Something weird
      internal static let somethingWeird = L10n.tr("Localizable", "search.suggestion.something_weird", fallback: "Something weird")
      /// Space opera night
      internal static let spaceOperaNight = L10n.tr("Localizable", "search.suggestion.space_opera_night", fallback: "Space opera night")
      /// Warm romance
      internal static let warmRomance = L10n.tr("Localizable", "search.suggestion.warm_romance", fallback: "Warm romance")
      /// Weekend adventure
      internal static let weekendAdventure = L10n.tr("Localizable", "search.suggestion.weekend_adventure", fallback: "Weekend adventure")
    }
    internal enum Suggestions {
      internal enum All {
        /// Choose a prompt to start searching.
        internal static let subtitle = L10n.tr("Localizable", "search.suggestions.all.subtitle", fallback: "Choose a prompt to start searching.")
        /// All vibes
        internal static let title = L10n.tr("Localizable", "search.suggestions.all.title", fallback: "All vibes")
      }
    }
    internal enum Validation {
      /// Describe what you are in the mood for.
      internal static let emptyQuery = L10n.tr("Localizable", "search.validation.empty_query", fallback: "Describe what you are in the mood for.")
    }
  }
  internal enum Tab {
    /// Profile
    internal static let profile = L10n.tr("Localizable", "tab.profile", fallback: "Profile")
    /// Search
    internal static let search = L10n.tr("Localizable", "tab.search", fallback: "Search")
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
