//
//  Language.swift
//
//  The site is English with a Russian version under /ru/.
//
//  URL scheme:
//  - English lives at the root: /, /articles, /portfolio, /about.
//  - Russian lives under /ru: /ru, /ru/articles, /ru/portfolio, /ru/about.
//    These are Publish pages from Content/ru.md and Content/ru/*.md.
//  - A Russian post is an item in Content/articles with `lang: ru` in its
//    front matter, and `translation: <path of the English post>` when it
//    translates one. It keeps the /articles/... URL, renders with lang="ru"
//    and the Russian chrome, and is listed only on /ru/articles and in
//    /ru/feed.rss. English lists and /feed.rss leave Russian posts out.
//
//  The language switch goes to the same page in the other language, or to
//  that language's home when there is no translation. hreflang alternates
//  are written only for pages that do have a translation.
//

import Foundation
import Plot

enum SiteLanguage: String, CaseIterable {
    case en
    case ru

    var plot: Language {
        switch self {
        case .en: return .english
        case .ru: return .russian
        }
    }

    var other: SiteLanguage { self == .en ? .ru : .en }

    /// The path of this language's home, without a leading slash.
    var homePath: String { self == .en ? "" : "ru" }

    var feedPath: String { self == .en ? "/feed.rss" : "/ru/feed.rss" }

    /// The language of a Publish page, from its path.
    static func of(pagePath path: String) -> SiteLanguage {
        let path = trimmed(path)
        return path == "ru" || path.hasPrefix("ru/") ? .ru : .en
    }

    /// The language of an item, from its `lang` front matter.
    static func of(itemLang lang: String?) -> SiteLanguage {
        lang?.lowercased() == "ru" ? .ru : .en
    }

    /// The URL of a path in this site, with a leading slash.
    static func url(_ path: String) -> String {
        "/" + trimmed(path)
    }

    static func trimmed(_ path: String) -> String {
        path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }
}

/// Pairs each page with its translation.
struct Translations {
    /// English path → Russian path, without leading slashes.
    private(set) var pairs: [String: String]

    /// The pages every language has: home and the three sections.
    static let fixed: [String: String] = [
        "": "ru",
        "articles": "ru/articles",
        "portfolio": "ru/portfolio",
        "about": "ru/about",
    ]

    /// - Parameter items: Russian posts as (path, translated English path).
    init(posts: [(path: String, translationOf: String?)] = []) {
        pairs = Self.fixed
        for post in posts {
            guard let english = post.translationOf else { continue }
            pairs[SiteLanguage.trimmed(english)] = SiteLanguage.trimmed(post.path)
        }
    }

    /// The same page in the other language, if there is one.
    func translation(of path: String, in language: SiteLanguage) -> String? {
        let path = SiteLanguage.trimmed(path)
        switch language {
        case .en: return pairs[path]
        case .ru: return pairs.first { $0.value == path }?.key
        }
    }

    /// Where the language switch on `path` goes: the translation, or the
    /// other language's home.
    func switchURL(from path: String, in language: SiteLanguage) -> String {
        SiteLanguage.url(translation(of: path, in: language) ?? language.other.homePath)
    }

    /// hreflang alternates for `path`: both languages and x-default, or
    /// nothing when the page has no translation.
    func alternates(for path: String, in language: SiteLanguage, siteURL: URL) -> [(hreflang: String, href: String)] {
        guard let other = translation(of: path, in: language) else { return [] }
        let here = SiteLanguage.trimmed(path)
        let english = language == .en ? here : other
        let russian = language == .ru ? here : other
        func absolute(_ path: String) -> String {
            siteURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + SiteLanguage.url(path)
        }
        return [
            ("en", absolute(english)),
            ("ru", absolute(russian)),
            ("x-default", absolute(english)),
        ]
    }
}

/// The words of the site chrome, home and lists, per language.
struct SiteStrings {
    var language: SiteLanguage

    private func pick(_ en: String, _ ru: String) -> String {
        language == .en ? en : ru
    }

    func sectionTitle(_ id: String) -> String {
        switch id {
        case "articles": return pick("Articles", "Статьи")
        case "portfolio": return pick("Portfolio", "Портфолио")
        case "about": return pick("About", "Обо мне")
        default: return id
        }
    }

    func sectionPath(_ id: String) -> String {
        SiteLanguage.url(language == .en ? id : "ru/\(id)")
    }

    var siteName: String { pick("Igor Malyarov", "Игорь Маляров") }
    var siteDescription: String {
        pick("Notes from building software: products and architecture.",
             "Заметки о разработке: продукты и архитектура.")
    }
    var eyebrow: String { pick("iOS tech lead · building products", "iOS-техлид · делаю продукты") }
    var readLatest: String { pick("Read the latest", "Читать свежее") }
    var seePortfolio: String { pick("See the portfolio", "Смотреть портфолио") }
    var productsHeading: String { pick("Products", "Продукты") }
    var portfolioMore: String { pick("Portfolio →", "Портфолио →") }
    var latestWriting: String { pick("Latest writing", "Свежие статьи") }
    var allArticles: String { pick("All articles · Tags →", "Все статьи · Теги →") }
    var allArticlesShort: String { pick("All articles →", "Все статьи →") }
    var browseAllTags: String { pick("Browse all tags", "Все теги") }
    var taggedWith: String { pick("Tagged with ", "С тегом ") }
    var rssFeed: String { pick("RSS feed", "RSS-лента") }
    var minRead: String { pick("min read", "мин чтения") }
    var reading: String { pick("Reading", "Читаете") }
    var previous: String { pick("← Previous", "← Назад") }
    var next: String { pick("Next →", "Далее →") }
    var languageSwitch: String { pick("Language", "Язык") }
    var switchLabel: String { pick("Читать по-русски", "Read in English") }
    var builtWith: String { pick("Built with ", "Сделано на ") }
    var inSwift: String { pick(", in Swift", ", на Swift") }
    var noRussianPosts: String {
        "Статьи пока выходят на английском. Переводы появятся здесь."
    }
    var englishArticles: String { "Статьи на английском →" }

    func part(_ index: Int, of count: Int, in project: String) -> String {
        pick("Part \(index) of \(count) in \(project)", "Часть \(index) из \(count) · \(project)")
    }

    func series(_ project: String) -> String {
        pick("The \(project) series", "Серия \(project)")
    }

    var dateLocale: Locale { Locale(identifier: language == .en ? "en_US_POSIX" : "ru_RU") }
}
