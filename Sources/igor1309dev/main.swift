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
        // Add any site-specific metadata that you want to use here.
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "https://igor1309.dev")!
    var name = "Igor Malyarov"
    var description = "Notes from building software with AI agents, and the Swift years before them."
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

try Igor1309Dev().publish(
    withTheme: .igor1309,
    additionalSteps: includeFuturePosts ? [] : [
        .removeAllItems(in: .articles, matching: Predicate { $0.date > buildDate })
    ],
    plugins: [.splash(withClassPrefix: "")]
)
