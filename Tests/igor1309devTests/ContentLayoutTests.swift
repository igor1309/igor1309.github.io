//
//  ContentLayoutTests.swift
//  igor1309devTests
//

@testable import igor1309dev
import XCTest

final class ContentLayoutTests: XCTestCase {
    // Publish writes sections and pages concurrently. A page named like a
    // section goes to the same path as that section, and whichever is
    // written last is what gets published, so a section's text belongs in
    // Content/<section>/index.md.
    func test_noPageSharesASectionPath() {
        let content = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content")

        for section in Igor1309Dev.SectionID.allCases {
            let page = content.appendingPathComponent("\(section.rawValue).md")
            XCTAssertFalse(FileManager.default.fileExists(atPath: page.path),
                           "Content/\(section.rawValue).md races the \(section.rawValue) section; move it to Content/\(section.rawValue)/index.md")
        }
    }

    // Ink, the Markdown parser behind Publish, treats an unclosed <img>
    // as an HTML block that never ends: every heading, link and paragraph
    // after it is published as raw Markdown text. Close it: <img ... />.
    func test_everyImgTagIsSelfClosed() throws {
        let content = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Content")
        let unclosed = try NSRegularExpression(pattern: "<img\\b[^>]*[^/]>")
        let files = FileManager.default.enumerator(at: content, includingPropertiesForKeys: nil)!
        for case let file as URL in files where file.pathExtension == "md" {
            let text = try String(contentsOf: file, encoding: .utf8)
            let range = NSRange(text.startIndex..., in: text)
            XCTAssertNil(unclosed.firstMatch(in: text, range: range),
                         "\(file.lastPathComponent) has an <img> without />; Ink leaves everything after it unparsed")
        }
    }

    // Portfolio screenshots come in pairs, <name>-light.webp and
    // <name>-dark.webp, so the page can show the one matching the theme.
    func test_portfolioScreenshotPairsAreComplete() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let images = root.appendingPathComponent("Resources/images/portfolio")
        let files = FileManager.default.enumerator(at: images, includingPropertiesForKeys: nil)!
        var pairs = 0
        for case let file as URL in files {
            let name = file.lastPathComponent
            for (mine, other) in [("-light.", "-dark.")] where name.contains(mine) {
                let twin = file.deletingLastPathComponent()
                    .appendingPathComponent(name.replacingOccurrences(of: mine, with: other))
                XCTAssertTrue(FileManager.default.fileExists(atPath: twin.path),
                              "\(name) has no \(twin.lastPathComponent)")
                pairs += 1
            }
        }
        XCTAssertGreaterThan(pairs, 0)

        // Every <picture> on a Portfolio page names a dark source that exists.
        let source = try NSRegularExpression(pattern: #"srcset="(/images/portfolio/[^"]+)""#)
        for page in ["Content/portfolio/index.md", "Content/ru/portfolio.md"] {
            let text = try String(contentsOf: root.appendingPathComponent(page), encoding: .utf8)
            for match in source.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                let path = String(text[Range(match.range(at: 1), in: text)!])
                XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("Resources" + path).path),
                              "\(page) points at missing \(path)")
            }
        }
    }
}
