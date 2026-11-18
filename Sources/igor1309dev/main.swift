import Foundation
import Plot
import Publish
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct Igor1309Dev: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case articles
        case portfolio
        case about
    }
    
    struct ItemMetadata: WebsiteItemMetadata {
        /// `ru` for a Russian post; English when absent. See Language.swift.
        var lang: String?
        /// The path of the English post this one translates, e.g.
        /// `articles/2026/2026-11-01-some-post`.
        var translation: String?
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "https://igor1309.dev")!
    var name = "Igor Malyarov"
    var description = "Notes from building software: products and architecture."
    var language: Language { .english }
    var imagePath: Path? { nil }
    var favicon: Favicon? { .init(path: Path("images/favicon_io/favicon.ico"), type: "image/x-icon")}
    
}

// This will generate your website using selected theme:
// There is no scheduler: a post dated in the future is left out of the build,
// and the hourly `Scheduled publish` workflow deploys it once its time passes.
// Dates are read in the build machine's time zone (UTC on GitHub runners).
// PR checks set PUBLISH_FUTURE_POSTS=1 so they render and check those posts too.
let includeFuturePosts = ProcessInfo.processInfo.environment["PUBLISH_FUTURE_POSTS"] == "1"
let buildDate = Date()

try Igor1309Dev().publish(using: Igor1309Dev.pipeline(
    excludingPostsAfter: includeFuturePosts ? nil : buildDate
))

extension Igor1309Dev {
    /// Publish's default pipeline, with one RSS feed per language:
    /// /feed.rss has the English posts, /ru/feed.rss the Russian ones.
    static func pipeline(excludingPostsAfter date: Date?) -> [PublishingStep<Igor1309Dev>] {
        [
            .installPlugin(.splash(withClassPrefix: "")),
            .optional(.copyResources()),
            .addMarkdownFiles(),
            .sortItems(by: \.date, order: .descending),
            .unwrap(date) { date in
                .removeAllItems(in: .articles, matching: Predicate { $0.date > date })
            },
            .generateHTML(withTheme: .igor1309),
            .generateRSSFeed(
                including: Set(SectionID.allCases),
                itemPredicate: Predicate { SiteLanguage.of(itemLang: $0.metadata.lang) == .en }
            ),
            .generateRSSFeed(
                including: Set(SectionID.allCases),
                itemPredicate: Predicate { SiteLanguage.of(itemLang: $0.metadata.lang) == .ru },
                config: .init(targetPath: "ru/feed.rss")
            ),
            .generateSiteMap(),
        ]
    }
}
