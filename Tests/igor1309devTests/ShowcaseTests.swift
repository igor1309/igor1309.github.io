//
//  ShowcaseTests.swift
//  igor1309devTests
//

@testable import igor1309dev
import XCTest

final class ShowcaseTests: XCTestCase {
    private struct Post {
        let id: String
        let tags: [String]
        let date: Date
    }

    private func post(_ id: String, _ tags: [String], day: Double) -> Post {
        Post(id: id, tags: tags, date: Date(timeIntervalSince1970: day * 86_400))
    }

    private func series(for current: Post, in posts: [Post]) -> SeriesPosition<Post>? {
        ShowcaseProject.series(
            tags: current.tags,
            isCurrent: { $0.id == current.id },
            in: posts,
            tagsOf: \.tags,
            dateOf: \.date
        )
    }

    func test_series_ordersTheProjectsShowcasePostsByDate() throws {
        let third = post("c", ["FolioTell", "Showcase"], day: 3)
        let first = post("a", ["FolioTell", "Showcase"], day: 1)
        let second = post("b", ["Swift", "FolioTell", "Showcase"], day: 2)
        let other = post("x", ["RexLab", "Showcase"], day: 2)
        let untagged = post("y", ["FolioTell"], day: 2)

        let position = try XCTUnwrap(
            series(for: second, in: [third, other, first, untagged, second])
        )

        XCTAssertEqual(position.project.name, "FolioTell")
        XCTAssertEqual(position.entries.map(\.id), ["a", "b", "c"])
        XCTAssertEqual(position.index, 1)
    }

    func test_series_isNilWithoutTheShowcaseTag() {
        let a = post("a", ["FolioTell"], day: 1)
        let b = post("b", ["FolioTell", "Showcase"], day: 2)

        XCTAssertNil(series(for: a, in: [a, b]))
    }

    func test_series_isNilForAPostWithoutAProject() {
        let a = post("a", ["Swift", "Showcase"], day: 1)
        let b = post("b", ["Swift", "Showcase"], day: 2)

        XCTAssertNil(series(for: a, in: [a, b]))
    }

    func test_series_isNilForASinglePost() {
        let a = post("a", ["Agister", "Showcase"], day: 1)

        XCTAssertNil(series(for: a, in: [a]))
    }

    func test_readingMinutes_countsWordsOutsideTagsAt220AMinute() {
        let words = Array(repeating: "word", count: 221).joined(separator: " ")

        XCTAssertEqual(readingMinutes(html: "<p>\(words)</p>"), 2)
        XCTAssertEqual(readingMinutes(html: #"<p class="a-very-long-attribute">one</p>"#), 1)
        XCTAssertEqual(readingMinutes(html: ""), 1)
    }

    func test_droppingLeadingTitle_removesOnlyALeadingH1() {
        XCTAssertEqual(droppingLeadingTitle("<h1>Title</h1><p>Body</p>"), "<p>Body</p>")
        XCTAssertEqual(droppingLeadingTitle("\n<h1 id=\"t\">Title</h1><p>Body</p>"), "<p>Body</p>")
        XCTAssertEqual(droppingLeadingTitle("<p>Intro</p><h1>Later</h1>"), "<p>Intro</p><h1>Later</h1>")
    }
}
