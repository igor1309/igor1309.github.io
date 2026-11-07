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
}
