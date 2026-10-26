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
try Igor1309Dev().publish(
    withTheme: .igor1309,
    plugins: [.splash(withClassPrefix: "")]
)
