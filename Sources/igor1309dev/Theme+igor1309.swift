//
//  Theme+igor1309.swift
//
//
//  Created by Igor Malyarov on 25.12.2021.
//

import Foundation
import Plot
import Publish

public extension Theme {
    static var igor1309: Self {
        Theme(
            htmlFactory: Igor1309DevHTMLFactory(),
            resourcePaths: [
                "Resources/Igor1309DevTheme/styles.css"
            ]
        )
    }
}

private struct Igor1309DevHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        // The index's H1 is the hero headline, not a page title.
        var head = index
        head.title = ""

        let posts = context.allItems(sortedBy: \.date, order: .descending)

        return HTML(
            .lang(context.site.language),
            .head(for: head, on: context.site),
            .body {
                SiteHeader(context: context, selected: nil)
                Main {
                    Div {
                        Paragraph("iOS tech lead · building with AI agents")
                            .class("eyebrow")
                        Div(index.body).class("hero-copy")
                        Div {
                            Link(url: "/articles") {
                                Text("Read the latest")
                                Icon.arrowRight
                            }
                            .class("button")
                            Link("See the portfolio", url: "/portfolio")
                                .class("text-link")
                        }
                        .class("hero-links")
                    }
                    .class("wrapper hero")

                    Div {
                        SectionHead(title: "Built with agents",
                                    link: ("Portfolio →", "/portfolio"))
                        List(ShowcaseProject.all) { project in
                            ProjectTile(project: project,
                                        firstPost: firstPost(of: project, in: posts))
                        }
                        .class("projects")
                    }
                    .class("wrapper")

                    Div {
                        SectionHead(title: "Latest writing",
                                    link: ("All articles · Tags →", "/articles"))
                        PostList(items: Array(posts.prefix(8)), site: context.site)
                    }
                    .class("wrapper")
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selected: section.id)
                Main {
                    // Portfolio and About are sections with a body and no posts.
                    if section.items.isEmpty {
                        Div(section.body).class("column content page")
                    } else {
                        Div {
                            H1(section.title).class("page-title")
                            Link("Browse all tags", url: context.site.tagListPath.absoluteString)
                                .class("text-link browse-all")
                            PostList(
                                items: section.items.sorted { $0.date > $1.date },
                                site: context.site
                            )
                        }
                        .class("wrapper")
                    }
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        let tags = item.tags.map(\.string)
        let series = ShowcaseProject.series(
            tags: tags,
            isCurrent: { $0.path == item.path },
            in: context.allItems(sortedBy: \.date),
            tagsOf: { $0.tags.map(\.string) },
            dateOf: \.date
        )
        let body = item.body.html
        var meta = [
            DateFormats.long.string(from: item.date),
            "\(readingMinutes(html: body)) min read",
        ]
        if let series {
            meta.append("Part \(series.index + 1) of \(series.entries.count) in \(series.project.name)")
        }

        return HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body {
                SiteHeader(context: context, selected: item.sectionID)
                Main {
                    Article {
                        Link("← \(context.sections[item.sectionID].title)",
                             url: context.sections[item.sectionID].path.absoluteString)
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
                            SeriesBox(series: series)
                        }
                    }
                    .class("column")
                }
                SiteFooter()
            }
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(
                    context: context,
                    selected: Site.SectionID(rawValue: page.path.string)
                )
                Main {
                    Div(page.body).class("column content page")
                }
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selected: nil)
                Main {
                    Div {
                        H1("Browse all tags").class("page-title")
                        TagChips(tags: page.tags.sorted(), site: context.site)
                            .class("all-tags")
                    }
                    .class("wrapper")
                }
                SiteFooter()
            }
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selected: nil)
                Main {
                    Div {
                        H1 {
                            Text("Tagged with ")
                            Span(page.tag.string).class("accent")
                        }
                        .class("page-title")
                        Link("Browse all tags", url: context.site.tagListPath.absoluteString)
                            .class("text-link browse-all")
                        PostList(
                            items: context.items(taggedWith: page.tag,
                                                 sortedBy: \.date,
                                                 order: .descending),
                            site: context.site
                        )
                    }
                    .class("wrapper")
                }
                SiteFooter()
            }
        )
    }

    private func firstPost(of project: ShowcaseProject, in posts: [Item<Site>]) -> Item<Site>? {
        posts
            .filter { item in
                let tags = item.tags.map(\.string)
                return tags.contains(project.tag) && tags.contains(ShowcaseProject.seriesTag)
            }
            .min { $0.date < $1.date }
    }
}

private enum DateFormats {
    static let short = make("d MMM yyyy")
    static let long = make("d MMMM yyyy")

    private static func make(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = format
        return formatter
    }
}

private enum Icon {
    static let arrowRight = svg(#"<path d="M5 12h14"/><path d="m12 5 7 7-7 7"/>"#)
    static let arrowUpRight = svg(#"<path d="M7 7h10v10"/><path d="M7 17 17 7"/>"#)
    static let rss = svg(#"<path d="M4 11a9 9 0 0 1 9 9"/><path d="M4 4a16 16 0 0 1 16 16"/><circle cx="5" cy="19" r="1"/>"#)

    private static func svg(_ paths: String) -> Node<HTML.BodyContext> {
        .raw(#"<svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">"# + paths + "</svg>")
    }
}

private struct Main: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Element(name: "main", content: content)
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selected: Site.SectionID?

    var body: Component {
        Header {
            Div {
                Link(url: "/") {
                    Span().class("dot")
                    Text(context.site.name)
                }
                .class("brand")

                Navigation {
                    List(Site.SectionID.allCases) { sectionID in
                        let section = context.sections[sectionID]
                        return Link(section.title, url: section.path.absoluteString)
                            .class(sectionID == selected ? "selected" : "")
                    }
                    Link(url: "/feed.rss") { Icon.rss }
                        .class("rss")
                        .attribute(named: "aria-label", value: "RSS feed")
                }
            }
            .class("wrapper bar")
        }
        .class("site-header")
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

private struct ProjectTile<Site: Website>: Component {
    var project: ShowcaseProject
    var firstPost: Item<Site>?

    var body: Component {
        Link(url: firstPost?.path.absoluteString ?? project.repo) {
            Div { media }.class("media")
            H3(project.name)
            Paragraph(project.summary).class("summary")
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

private struct PostList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            Link(url: item.path.absoluteString) {
                Div {
                    Paragraph(DateFormats.short.string(from: item.date)).class("date")
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

private struct SeriesBox<Site: Website>: Component {
    var series: SeriesPosition<Item<Site>>

    var body: Component {
        Element(name: "aside") {
            Div {
                Paragraph("The \(series.project.name) series").class("kicker")
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
    private func title(of entry: Item<Site>) -> String {
        let prefix = series.project.name + ": "
        guard entry.title.hasPrefix(prefix) else { return entry.title }
        let rest = entry.title.dropFirst(prefix.count)
        return rest.prefix(1).uppercased() + rest.dropFirst()
    }

    private func state(at offset: Int) -> String {
        switch offset {
        case series.index: return "Reading"
        case series.index - 1: return "← Previous"
        case series.index + 1: return "Next →"
        default: return ""
        }
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Div {
                Div {
                    Paragraph("© 2026 Igor Malyarov")
                    Paragraph {
                        Text("Built with ")
                        Link("Publish", url: "https://github.com/johnsundell/publish")
                        Text(", in Swift")
                    }
                }
                .class("footer-left")
                Div {
                    Link("GitHub", url: "https://github.com/igor1309")
                    Link("LinkedIn", url: "https://www.linkedin.com/in/igor1309/")
                    Link("Telegram", url: "https://t.me/igor1309")
                    Link("RSS", url: "/feed.rss")
                }
                .class("footer-links")
            }
            .class("wrapper bar")
        }
        .class("site-footer")
    }
}
