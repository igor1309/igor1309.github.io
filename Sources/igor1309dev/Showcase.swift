//
//  Showcase.swift
//
//  The public projects the home page leads with. Each one's posts carry its
//  tag and the `Showcase` tag, and read as a series in date order.
//

import Foundation

struct ShowcaseProject {
    enum Media {
        case picture(light: String, dark: String)
        case image(String)
        case terminal([String])
    }

    let name: String
    let tag: String
    let summary: String
    let stack: String
    let repo: String
    let media: Media
}

extension ShowcaseProject {
    static let seriesTag = "Showcase"

    static let all: [ShowcaseProject] = [
        .init(
            name: "RexLab",
            tag: "RexLab",
            summary: "A dinosaur learning game for children aged 4 to 7.",
            stack: "React · TypeScript",
            repo: "https://github.com/igor1309/rexlab",
            media: .picture(
                light: "/images/portfolio/rexlab/home-light.webp",
                dark: "/images/portfolio/rexlab/home-dark.webp"
            )
        ),
        .init(
            name: "FolioTell",
            tag: "FolioTell",
            summary: "An offline iPhone app that reads your notes aloud.",
            stack: "SwiftUI · Swift Testing",
            repo: "https://github.com/igor1309/foliotell",
            media: .image("/images/portfolio/foliotell/reader.webp")
        ),
        .init(
            name: "Agister",
            tag: "Agister",
            summary: "A runner for AI-agent work defined in settings files.",
            stack: "Go",
            repo: "https://github.com/igor1309/agister",
            media: .terminal([
                "$ agister run review",
                "resolve  ✓ 3 definitions",
                "admit    ✓ budget 1.20 USD",
                "record   runs/7f2c/",
            ])
        ),
        .init(
            name: "Agonara",
            tag: "Agonara",
            summary: "Learning programs your own agent can work on.",
            stack: "Node.js · SQLite",
            repo: "https://github.com/igor1309/agonara",
            media: .image("/images/portfolio/agonara/learn-quick-check.webp")
        ),
    ]
}

/// A post's place in its project's series.
struct SeriesPosition<Entry> {
    let project: ShowcaseProject
    let entries: [Entry]
    let index: Int
}

extension ShowcaseProject {
    /// The series `tags` belong to, if any: the posts in `all` that share
    /// the project tag and the series tag, oldest first.
    static func series<Entry>(
        tags: [String],
        isCurrent: (Entry) -> Bool,
        in all: [Entry],
        tagsOf: (Entry) -> [String],
        dateOf: (Entry) -> Date
    ) -> SeriesPosition<Entry>? {
        guard tags.contains(seriesTag),
              let project = Self.all.first(where: { tags.contains($0.tag) })
        else { return nil }

        let entries = all
            .filter { tagsOf($0).contains(seriesTag) && tagsOf($0).contains(project.tag) }
            .sorted { dateOf($0) < dateOf($1) }

        guard entries.count > 1,
              let index = entries.firstIndex(where: isCurrent)
        else { return nil }

        return .init(project: project, entries: entries, index: index)
    }
}

/// Minutes to read `html` at 220 words a minute, at least one.
func readingMinutes(html: String) -> Int {
    let text = html.replacingOccurrences(
        of: "<[^>]+>", with: " ", options: .regularExpression
    )
    let words = text.split(whereSeparator: { $0.isWhitespace }).count
    return max(1, Int((Double(words) / 220).rounded(.up)))
}

/// `html` without its leading `<h1>`, which the theme renders itself.
func droppingLeadingTitle(_ html: String) -> String {
    let trimmed = html.drop(while: { $0.isWhitespace })
    guard trimmed.hasPrefix("<h1"),
          let end = trimmed.range(of: "</h1>")
    else { return html }
    return String(trimmed[end.upperBound...])
}
