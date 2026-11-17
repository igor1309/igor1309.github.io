//
//  LanguageTests.swift
//  igor1309devTests
//

@testable import igor1309dev
import Plot
import Publish
import XCTest

final class LanguageTests: XCTestCase {
    private let siteURL = URL(string: "https://igor1309.dev")!

    func test_pageLanguage_comesFromTheRuPrefix() {
        XCTAssertEqual(SiteLanguage.of(pagePath: "ru"), .ru)
        XCTAssertEqual(SiteLanguage.of(pagePath: "/ru/about"), .ru)
        XCTAssertEqual(SiteLanguage.of(pagePath: "about"), .en)
        XCTAssertEqual(SiteLanguage.of(pagePath: "rust-notes"), .en)
        XCTAssertEqual(SiteLanguage.of(pagePath: ""), .en)
    }

    func test_itemLanguage_isEnglishUnlessMarkedRu() {
        XCTAssertEqual(SiteLanguage.of(itemLang: nil), .en)
        XCTAssertEqual(SiteLanguage.of(itemLang: "ru"), .ru)
        XCTAssertEqual(SiteLanguage.of(itemLang: "RU"), .ru)
        XCTAssertEqual(SiteLanguage.of(itemLang: "en"), .en)
    }

    func test_htmlLang() {
        XCTAssertEqual(SiteLanguage.en.plot.rawValue, "en")
        XCTAssertEqual(SiteLanguage.ru.plot.rawValue, "ru")
    }

    func test_switch_landsOnTheSamePageInTheOtherLanguage() {
        let sut = Translations()
        XCTAssertEqual(sut.switchURL(from: "", in: .en), "/ru")
        XCTAssertEqual(sut.switchURL(from: "ru", in: .ru), "/")
        for section in ["about", "portfolio", "articles"] {
            XCTAssertEqual(sut.switchURL(from: section, in: .en), "/ru/\(section)")
            XCTAssertEqual(sut.switchURL(from: "/ru/\(section)/", in: .ru), "/\(section)")
        }
    }

    func test_switch_fallsBackToTheOtherHome_withoutATranslation() {
        let sut = Translations()
        XCTAssertEqual(sut.switchURL(from: "articles/2022/some-post", in: .en), "/ru")
        XCTAssertEqual(sut.switchURL(from: "tags/swift", in: .en), "/ru")
        XCTAssertEqual(sut.switchURL(from: "articles/2026/russian-only", in: .ru), "/")
    }

    func test_switch_followsATranslatedPost_bothWays() {
        let sut = Translations(posts: [
            (path: "/articles/2026/post-ru", translationOf: "articles/2026/post"),
            (path: "/articles/2026/russian-only", translationOf: nil),
        ])
        XCTAssertEqual(sut.switchURL(from: "/articles/2026/post", in: .en), "/articles/2026/post-ru")
        XCTAssertEqual(sut.switchURL(from: "/articles/2026/post-ru", in: .ru), "/articles/2026/post")
        XCTAssertEqual(sut.switchURL(from: "/articles/2026/russian-only", in: .ru), "/")
    }

    func test_hreflang_listsBothLanguagesAndXDefault() {
        let sut = Translations()
        let expected = [
            "en https://igor1309.dev/about",
            "ru https://igor1309.dev/ru/about",
            "x-default https://igor1309.dev/about",
        ]
        XCTAssertEqual(sut.alternates(for: "about", in: .en, siteURL: siteURL).map { "\($0.hreflang) \($0.href)" }, expected)
        XCTAssertEqual(sut.alternates(for: "ru/about", in: .ru, siteURL: siteURL).map { "\($0.hreflang) \($0.href)" }, expected)
    }

    func test_hreflang_isOmitted_withoutATranslation() {
        XCTAssertTrue(Translations().alternates(for: "articles/2022/some-post", in: .en, siteURL: siteURL).isEmpty)
    }

    func test_head_rendersHreflangLinksAndTheLanguagesFeed() {
        let head = Node<HTML.DocumentContext>.siteHead(
            for: Page(path: "ru/portfolio", content: Content(title: "Портфолио")),
            on: Igor1309Dev(),
            strings: SiteStrings(language: .ru),
            stylesheet: "/styles.css",
            alternates: Translations().alternates(for: "ru/portfolio", in: .ru, siteURL: siteURL)
        ).render()

        XCTAssertTrue(head.contains(#"<link rel="alternate" hreflang="en" href="https://igor1309.dev/portfolio"/>"#), head)
        XCTAssertTrue(head.contains(#"<link rel="alternate" hreflang="ru" href="https://igor1309.dev/ru/portfolio"/>"#), head)
        XCTAssertTrue(head.contains(#"<link rel="alternate" hreflang="x-default" href="https://igor1309.dev/portfolio"/>"#), head)
        XCTAssertTrue(head.contains(#"href="/ru/feed.rss""#), head)
        XCTAssertTrue(head.contains("<title>Портфолио | Игорь Маляров</title>"), head)
    }

    func test_languageSwitch_marksTheCurrentLanguageAndLinksTheOther() {
        let en = LanguageSwitch(strings: SiteStrings(language: .en), switchURL: "/ru/about").render()
        XCTAssertTrue(en.contains(#"<span aria-current="true" lang="en">EN</span>"#), en)
        XCTAssertTrue(en.contains(#"<a href="/ru/about" hreflang="ru" lang="ru""#), en)

        let ru = LanguageSwitch(strings: SiteStrings(language: .ru), switchURL: "/about").render()
        XCTAssertTrue(ru.contains(#"<a href="/about" hreflang="en" lang="en""#), ru)
        XCTAssertTrue(ru.contains(#"<span aria-current="true" lang="ru">RU</span>"#), ru)
    }
}
