//
//  Theme+igor1309.swift
//
//
//  Created by Igor Malyarov on 25.12.2021.
//

import Foundation
import Plot
import Publish

extension Theme where Site == Igor1309Dev {
    static var igor1309: Self {
        Theme(
            htmlFactory: Igor1309DevHTMLFactory(),
            resourcePaths: [
                "Resources/Igor1309DevTheme/styles.css"
            ]
        )
    }
}

typealias SiteItem = Item<Igor1309Dev>

extension Item where Site == Igor1309Dev {
    var language: SiteLanguage { SiteLanguage.of(itemLang: metadata.lang) }
}

private struct Igor1309DevHTMLFactory: HTMLFactory {
    typealias Site = Igor1309Dev

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        // The index's H1 is the hero headline, not a page title.
        var head = index
        head.title = ""
        return try page(.en, path: "", location: head, context: context, selected: nil) {
            HomePage(language: .en, hero: index.body, context: context)
        }
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        try page(.en, path: section.path.string, location: section, context: context, selected: section.id) {
            // Portfolio and About are sections with a body and no posts.
            if section.id == .about {
                AboutPage(text: section.body, language: .en)
            } else if section.items.isEmpty {
                Div(section.body).class("column content page")
            } else {
                ArticleIndex(language: .en, context: context)
            }
        }
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        let language = item.language
        let strings = SiteStrings(language: language)
        let tags = item.tags.map(\.string)
        let series = ShowcaseProject.series(
            tags: tags,
            isCurrent: { $0.path == item.path },
            in: posts(in: language, context: context).reversed(),
            tagsOf: { $0.tags.map(\.string) },
            dateOf: \.date
        )
        let body = item.body.html
        var meta = [
            DateFormats.long(language).string(from: item.date),
            "\(readingMinutes(html: body)) \(strings.minRead)",
        ]
        if let series {
            meta.append(strings.part(series.index + 1, of: series.entries.count, in: series.project.name))
        }

        return try page(language, path: item.path.string, location: item, context: context, selected: item.sectionID) {
            Article {
                Link("← \(strings.sectionTitle(item.sectionID.rawValue))",
                     url: strings.sectionPath(item.sectionID.rawValue))
                    .class("back")
                TagChips(tags: item.tags.filter { $0.string != ShowcaseProject.seriesTag },
                         site: context.site)
                H1(item.title).class("article-title")
                Paragraph(meta.joined(separator: "  ·  ")).class("meta")
                if !item.description.isEmpty {
                    Paragraph(item.description).class("lede")
                }
                Div().class("rule")
                Div(Node<HTML.BodyContext>.raw(droppingLeadingTitle(body)))
                    .class("content")
                if let series {
                    SeriesBox(series: series, strings: strings)
                }
            }
            .class("column")
        }
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        let path = SiteLanguage.trimmed(page.path.string)
        let language = SiteLanguage.of(pagePath: path)
        // The section a page stands for: "about" or "ru/about" → .about.
        let sectionName = language == .ru ? String(path.dropFirst(3)) : path
        let selected = Site.SectionID(rawValue: sectionName)
        var location = page
        if path == language.homePath {
            location.title = ""
        }

        return try self.page(language, path: path, location: location, context: context, selected: selected) {
            if path == language.homePath {
                HomePage(language: language, hero: page.body, context: context)
            } else if selected == .about {
                AboutPage(text: page.body, language: language)
            } else if selected == .articles {
                ArticleIndex(language: language, context: context)
            } else {
                Div(page.body).class("column content page")
            }
        }
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        let strings = SiteStrings(language: .en)
        return try self.page(.en, path: page.path.string, location: page, context: context, selected: nil) {
            Div {
                H1(strings.browseAllTags).class("page-title")
                TagChips(tags: page.tags.sorted(), site: context.site)
                    .class("all-tags")
            }
            .class("wrapper")
        }
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        let strings = SiteStrings(language: .en)
        return try self.page(.en, path: page.path.string, location: page, context: context, selected: nil) {
            Div {
                H1 {
                    Text(strings.taggedWith)
                    Span(page.tag.string).class("accent")
                }
                .class("page-title")
                Link(strings.browseAllTags, url: context.site.tagListPath.absoluteString)
                    .class("text-link browse-all")
                PostList(
                    items: context.items(taggedWith: page.tag, sortedBy: \.date, order: .descending)
                        .filter { $0.language == .en },
                    language: .en
                )
            }
            .class("wrapper")
        }
    }

    /// A whole page: head with hreflang alternates, header with the
    /// language switch, `content` in <main>, footer.
    private func page(_ language: SiteLanguage,
                      path: String,
                      location: Location,
                      context: PublishingContext<Site>,
                      selected: Site.SectionID?,
                      @ComponentBuilder content: @escaping () -> ComponentGroup) throws -> HTML {
        let translations = translations(context)
        let strings = SiteStrings(language: language)
        return HTML(
            .lang(language.plot),
            .siteHead(
                for: location,
                on: context.site,
                strings: strings,
                stylesheet: try stylesheetPath(context),
                alternates: translations.alternates(for: path, in: language, siteURL: context.site.url)
            ),
            .body {
                SiteHeader(strings: strings,
                           selected: selected,
                           switchURL: translations.switchURL(from: path, in: language))
                Main(content: content)
                SiteFooter(strings: strings)
            }
        )
    }

    private func translations(_ context: PublishingContext<Site>) -> Translations {
        Translations(posts: posts(in: .ru, context: context).map {
            (path: $0.path.string, translationOf: $0.metadata.translation)
        })
    }

    /// The stylesheet's URL, versioned by its contents so a browser holding
    /// an older copy fetches the new one.
    private func stylesheetPath(_ context: PublishingContext<Site>) throws -> Path {
        let css = try context.file(at: "Resources/Igor1309DevTheme/styles.css").readAsString()
        return Path("/styles.css?v=\(contentVersion(of: css))")
    }
}

/// Posts in `language`, newest first.
private func posts(in language: SiteLanguage, context: PublishingContext<Igor1309Dev>) -> [SiteItem] {
    context.allItems(sortedBy: \.date, order: .descending).filter { $0.language == language }
}

extension Node where Context == HTML.DocumentContext {
    /// Publish's `.head(for:on:)`, in the page's language, with hreflang
    /// alternates and the page language's RSS feed.
    static func siteHead(for location: Location,
                         on site: Igor1309Dev,
                         strings: SiteStrings,
                         stylesheet: Path,
                         alternates: [(hreflang: String, href: String)]) -> Node {
        let name = strings.siteName
        let title = location.title.isEmpty ? name : location.title + " | " + name
        let description = location.description.isEmpty ? strings.siteDescription : location.description
        return .head(
            .encoding(.utf8),
            .siteName(name),
            .url(site.url(for: location)),
            .title(title),
            .description(description),
            .twitterCardType(.summary),
            .stylesheet(stylesheet),
            .viewport(.accordingToDevice),
            .unwrap(site.favicon, { .favicon($0) }),
            .rssFeedLink(strings.language.feedPath, title: "Subscribe to \(name)"),
            .forEach(alternates) { alternate in
                .link(
                    .rel(.alternate),
                    .attribute(named: "hreflang", value: alternate.hreflang),
                    .href(alternate.href)
                )
            },
            .script(.raw(ThemeScript.source))
        )
    }
}

private enum DateFormats {
    static func short(_ language: SiteLanguage) -> DateFormatter {
        language == .en ? enShort : ruShort
    }

    static func long(_ language: SiteLanguage) -> DateFormatter {
        language == .en ? enLong : ruLong
    }

    private static let enShort = make("d MMM yyyy", .en)
    private static let enLong = make("d MMMM yyyy", .en)
    private static let ruShort = make("d MMM yyyy", .ru)
    private static let ruLong = make("d MMMM yyyy", .ru)

    private static func make(_ format: String, _ language: SiteLanguage) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = SiteStrings(language: language).dateLocale
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = format
        return formatter
    }
}

private enum Icon {
    static let arrowRight = svg(#"<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>"#)
    static let arrowUpRight = svg(#"<path d="M7 7h10v10"/><path d="M7 17 17 7"/>"#)
    static let monitor = svg(#"<rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/>"#, name: "monitor")
    static let sun = svg(#"<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>"#, name: "sun")
    static let moon = svg(#"<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>"#, name: "moon")
    static let rss = svg(#"<path d="M4 11a9 9 0 0 1 9 9"/><path d="M4 4a16 16 0 0 1 16 16"/><circle cx="5" cy="19" r="1"/>"#)

    private static func svg(_ paths: String, name: String? = nil) -> Node<HTML.BodyContext> {
        let classes = name.map { "icon icon-\($0)" } ?? "icon"
        return .raw(#"<svg class=""# + classes + #"" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">"# + paths + "</svg>")
    }
}

private struct Main: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Element(name: "main", content: content)
    }
}

private struct SiteHeader: Component {
    var strings: SiteStrings
    var selected: Igor1309Dev.SectionID?
    var switchURL: String

    var body: Component {
        Header {
            Div {
                Link(url: SiteLanguage.url(strings.language.homePath)) {
                    Span().class("dot")
                    Text(strings.siteName)
                }
                .class("brand")

                Navigation {
                    List(Igor1309Dev.SectionID.allCases) { sectionID in
                        Link(strings.sectionTitle(sectionID.rawValue),
                             url: strings.sectionPath(sectionID.rawValue))
                            .class(sectionID == selected ? "selected" : "")
                    }
                    Link(url: strings.language.feedPath) { Icon.rss }
                        .class("rss")
                        .attribute(named: "aria-label", value: strings.rssFeed)
                }

                Div {
                    LanguageSwitch(strings: strings, switchURL: switchURL)
                    ThemeToggle(language: strings.language)
                }
                .class("prefs")
            }
            .class("wrapper bar")
        }
        .class("site-header")
    }
}

/// `EN | RU`: the current language is a span, the other a link to the
/// same page in that language (LAB-1679).
struct LanguageSwitch: Component {
    var strings: SiteStrings
    var switchURL: String

    var body: Component {
        Div {
            for language in SiteLanguage.allCases {
                if language == strings.language {
                    Span(language.rawValue.uppercased())
                        .attribute(named: "aria-current", value: "true")
                        .attribute(named: "lang", value: language.rawValue)
                } else {
                    Link(language.rawValue.uppercased(), url: switchURL)
                        .attribute(named: "hreflang", value: language.rawValue)
                        .attribute(named: "lang", value: language.rawValue)
                        .attribute(named: "aria-label", value: strings.switchLabel)
                        .attribute(named: "title", value: strings.switchLabel)
                }
            }
        }
        .class("lang-switch")
        .attribute(named: "role", value: "group")
        .attribute(named: "aria-label", value: strings.languageSwitch)
    }
}

private struct HomePage: Component {
    var language: SiteLanguage
    var hero: Content.Body
    var context: PublishingContext<Igor1309Dev>

    var body: Component {
        let strings = SiteStrings(language: language)
        let localPosts = posts(in: language, context: context)
        let englishPosts = posts(in: .en, context: context)
        let articles = strings.sectionPath("articles")
        let portfolio = strings.sectionPath("portfolio")
        return ComponentGroup {
            Div {
                Paragraph(strings.eyebrow).class("eyebrow")
                Div(hero).class("hero-copy")
                Div {
                    Link(url: articles) {
                        Text(strings.readLatest)
                        Icon.arrowRight
                    }
                    .class("button")
                    Link(strings.seePortfolio, url: portfolio)
                        .class("text-link")
                }
                .class("hero-links")
            }
            .class("wrapper hero")

            Div {
                SectionHead(title: strings.builtWithAgents,
                            link: (strings.portfolioMore, portfolio))
                List(ShowcaseProject.all) { project in
                    ProjectTile(project: project,
                                firstPost: firstPost(of: project, in: englishPosts),
                                language: language)
                }
                .class("projects")
            }
            .class("wrapper")

            Div {
                SectionHead(title: strings.latestWriting,
                            link: (language == .en ? strings.allArticles : strings.allArticlesShort, articles))
                if localPosts.isEmpty {
                    NoPostsYet()
                } else {
                    PostList(items: Array(localPosts.prefix(8)), language: language)
                }
            }
            .class("wrapper")
        }
    }

    private func firstPost(of project: ShowcaseProject, in posts: [SiteItem]) -> SiteItem? {
        posts
            .filter { item in
                let tags = item.tags.map(\.string)
                return tags.contains(project.tag) && tags.contains(ShowcaseProject.seriesTag)
            }
            .min { $0.date < $1.date }
    }
}

/// The list of posts in one language; English posts that have no Russian
/// version are not listed on the Russian one.
private struct ArticleIndex: Component {
    var language: SiteLanguage
    var context: PublishingContext<Igor1309Dev>

    var body: Component {
        let strings = SiteStrings(language: language)
        let items = posts(in: language, context: context)
        return Div {
            H1(strings.sectionTitle("articles")).class("page-title")
            if language == .en {
                Link(strings.browseAllTags, url: context.site.tagListPath.absoluteString)
                    .class("text-link browse-all")
            }
            if items.isEmpty {
                NoPostsYet()
            } else {
                PostList(items: items, language: language)
            }
        }
        .class("wrapper")
    }
}

/// The Russian lists while there are no Russian posts.
private struct NoPostsYet: Component {
    var body: Component {
        let strings = SiteStrings(language: .ru)
        return Paragraph {
            Text(strings.noRussianPosts + " ")
            Link(strings.englishArticles, url: "/articles").class("text-link")
        }
        .class("empty-note")
    }
}

private struct SectionHead: Component {
    var title: String
    var link: (label: String, url: String)

    var body: Component {
        Div {
            H2(title)
            Link(link.label, url: link.url).class("more")
        }
        .class("section-head")
    }
}

private struct ProjectTile: Component {
    var project: ShowcaseProject
    var firstPost: SiteItem?
    var language: SiteLanguage

    var body: Component {
        Link(url: firstPost?.path.absoluteString ?? project.repo) {
            Div { media }.class("media")
            H3(project.name)
            Paragraph(project.summary(in: language)).class("summary")
            Paragraph(project.stack).class("stack")
        }
        .class("project")
    }

    private var media: Component {
        switch project.media {
        case let .picture(light, dark):
            return Node<HTML.BodyContext>.raw(
                #"<picture><source media="(prefers-color-scheme: dark)" srcset="\#(dark)"><img src="\#(light)" alt="\#(project.name)" loading="lazy"></picture>"#
            )
        case let .image(path):
            return Image(url: path, description: project.name)
        case let .terminal(lines):
            return Div {
                for line in lines {
                    Paragraph(line)
                }
            }
            .class("terminal")
        }
    }
}

private struct PostList: Component {
    var items: [SiteItem]
    var language: SiteLanguage

    var body: Component {
        List(items) { item in
            Link(url: item.path.absoluteString) {
                Div {
                    Paragraph(DateFormats.short(language).string(from: item.date)).class("date")
                    if let tag = item.tags.first {
                        Span(tag.string).class("chip")
                    }
                }
                .class("post-meta")
                Div {
                    H3(item.title)
                    Paragraph(item.description)
                }
                .class("post-body")
                Icon.arrowUpRight
            }
            .class("post")
        }
        .class("post-list")
    }
}

private struct TagChips<Site: Website>: Component {
    var tags: [Tag]
    var site: Site

    var body: Component {
        List(tags) { tag in
            Link(tag.string, url: site.path(for: tag).absoluteString)
                .class("chip")
        }
        .class("chips")
    }
}

private struct SeriesBox: Component {
    var series: SeriesPosition<SiteItem>
    var strings: SiteStrings

    var body: Component {
        Element(name: "aside") {
            Div {
                Paragraph(strings.series(series.project.name)).class("kicker")
                Link("\(series.project.repo.replacingOccurrences(of: "https://", with: "")) ↗",
                     url: series.project.repo)
                    .class("repo")
            }
            .class("series-head")
            List(Array(series.entries.enumerated())) { offset, entry in
                Link(url: entry.path.absoluteString) {
                    Span("\(offset + 1)").class("num")
                    Span(title(of: entry)).class("title")
                    Span(state(at: offset)).class("state")
                }
                .class(offset == series.index ? "part current" : "part")
            }
        }
        .class("series")
    }

    /// The post title without the project prefix the series box already names.
    private func title(of entry: SiteItem) -> String {
        let prefix = series.project.name + ": "
        guard entry.title.hasPrefix(prefix) else { return entry.title }
        let rest = entry.title.dropFirst(prefix.count)
        return rest.prefix(1).uppercased() + rest.dropFirst()
    }

    private func state(at offset: Int) -> String {
        switch offset {
        case series.index: return strings.reading
        case series.index - 1: return strings.previous
        case series.index + 1: return strings.next
        default: return ""
        }
    }
}

private struct AboutPage: Component {
    var text: Content.Body
    var language: SiteLanguage

    var body: Component {
        let strings = SiteStrings(language: language)
        return Div {
            Div {
                Image(url: "/images/about/igor.jpeg", description: strings.siteName)
                    .class("portrait")
                Link(url: "/articles/2022/2022-10-18-essential-blue-belt") {
                    Image(url: "/images/about/certificate-of-completion-for-ios-lead-essentials.png",
                          description: language == .en
                            ? "Certificate of completion for iOS Lead Essentials"
                            : "Сертификат об окончании курса iOS Lead Essentials")
                    Div {
                        Paragraph("iOS Lead Essentials").class("credential-title")
                        Paragraph("Essential Developer, 2022").class("credential-meta")
                    }
                }
                .class("credential")
            }
            .class("about-side")
            Div(text).class("content about-body")
        }
        .class("wrapper about")
    }
}

private struct SiteFooter: Component {
    var strings: SiteStrings

    var body: Component {
        Footer {
            Div {
                Div {
                    Paragraph("© 2026 \(strings.siteName)")
                    Paragraph {
                        Text(strings.builtWith)
                        Link("Publish", url: "https://github.com/johnsundell/publish")
                        Text(strings.inSwift)
                    }
                }
                .class("footer-left")
                Div {
                    Link("GitHub", url: "https://github.com/igor1309")
                    Link("LinkedIn", url: "https://www.linkedin.com/in/igor1309/")
                    Link("Telegram", url: "https://t.me/igor1309")
                    Link("RSS", url: strings.language.feedPath)
                }
                .class("footer-links")
            }
            .class("wrapper bar")
        }
        .class("site-footer")
    }
}

/// The light / dark / system theme button. It is hidden until `ThemeScript`
/// runs, so a page without JavaScript shows no control that does nothing.
private struct ThemeToggle: Component {
    var language: SiteLanguage

    private var label: String {
        language == .ru ? "Тема: системная. Переключить на светлую" : "Theme: system. Switch to light"
    }

    var body: Component {
        Button {
            Icon.monitor
            Icon.sun
            Icon.moon
        }
        .class("theme-toggle")
        .attribute(named: "type", value: "button")
        .attribute(named: "hidden", value: nil, ignoreValueIfEmpty: false)
        .attribute(named: "aria-label", value: label)
        .attribute(named: "title", value: label)
    }
}

/// Runs blocking in `<head>`: applies the stored theme before first paint,
/// then wires the header button once the DOM is ready.
/// `localStorage['theme']` is `light` or `dark`; no value means follow the system.
enum ThemeScript {
    static let source = #"""
(function () {
  var root = document.documentElement;
  var order = ["system", "light", "dark"];
  function stored() {
    try { var t = localStorage.getItem("theme"); return t === "light" || t === "dark" ? t : "system"; }
    catch (e) { return "system"; }
  }
  function apply(theme) {
    if (theme === "system") root.removeAttribute("data-theme");
    else root.setAttribute("data-theme", theme);
    pictures(theme);
  }
  // A <picture> dark source only knows the system setting; point it at the chosen theme.
  function pictures(theme) {
    var sources = document.querySelectorAll('picture source[media*="prefers-color-scheme: dark"], picture source[data-dark-media]');
    Array.prototype.forEach.call(sources, function (s) {
      if (!s.hasAttribute("data-dark-media")) s.setAttribute("data-dark-media", s.media);
      s.media = theme === "dark" ? "all" : theme === "light" ? "not all" : s.getAttribute("data-dark-media");
    });
  }
  apply(stored());
  var labels = {
    en: { name: { system: "system", light: "light", dark: "dark" }, text: function (c, n) { return "Theme: " + c + ". Switch to " + n; } },
    ru: { name: { system: "системная", light: "светлая", dark: "тёмная" }, next: { system: "системную", light: "светлую", dark: "тёмную" }, text: function (c, n) { return "Тема: " + c + ". Переключить на " + n; } }
  };
  function label(theme) {
    var l = (root.lang || "en").slice(0, 2) === "ru" ? labels.ru : labels.en;
    var next = order[(order.indexOf(theme) + 1) % order.length];
    return l.text(l.name[theme], (l.next || l.name)[next]);
  }
  function sync(button, theme) {
    button.setAttribute("data-choice", theme);
    button.setAttribute("aria-label", label(theme));
    button.setAttribute("title", label(theme));
  }
  document.addEventListener("DOMContentLoaded", function () {
    pictures(stored());
    var buttons = document.querySelectorAll(".theme-toggle");
    Array.prototype.forEach.call(buttons, function (button) {
      sync(button, stored());
      button.hidden = false;
      button.addEventListener("click", function () {
        var theme = order[(order.indexOf(stored()) + 1) % order.length];
        try {
          if (theme === "system") localStorage.removeItem("theme");
          else localStorage.setItem("theme", theme);
        } catch (e) {}
        apply(theme);
        Array.prototype.forEach.call(buttons, function (b) { sync(b, theme); });
      });
    });
  });
})();
"""#
}
