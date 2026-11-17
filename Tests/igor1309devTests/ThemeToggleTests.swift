//
//  ThemeToggleTests.swift
//  igor1309devTests
//

@testable import igor1309dev
import Plot
import XCTest

final class ThemeToggleTests: XCTestCase {
    // The stored theme must be applied before first paint, so the script
    // sits in <head> and runs blocking, ahead of <body>.
    func test_everyPageAppliesTheStoredThemeFromHead() throws {
        for (name, html) in try renderedPages() {
            let head = try XCTUnwrap(html.range(of: "</head>"), name)
            let script = try XCTUnwrap(html.range(of: "localStorage.getItem(\"theme\")"), "\(name) has no theme script")
            XCTAssertLessThan(script.lowerBound, head.lowerBound, "\(name): theme script must be in <head>")
        }
    }

    // Without JavaScript the button cannot work, so it ships hidden.
    func test_everyPageHasAHiddenThemeButtonInTheHeader() throws {
        for (name, html) in try renderedPages() {
            XCTAssertTrue(html.contains(#"<button class="theme-toggle" type="button" hidden"#), "\(name) has no theme toggle")
            let label = name.hasPrefix("ru/") ? "Тема: системная. Переключить на светлую" : "Theme: system. Switch to light"
            XCTAssertTrue(html.contains(#"aria-label=""# + label + #"""#), name)
        }
    }

    func test_darkTokensFollowAnExplicitChoiceBeforeTheSystem() throws {
        let css = try String(contentsOf: repo.appendingPathComponent("Resources/Igor1309DevTheme/styles.css"), encoding: .utf8)
        XCTAssertTrue(css.contains(#":root[data-theme="dark"] {"#))
        XCTAssertTrue(css.contains(":root:not([data-theme]) {"))
    }

    private var repo: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func renderedPages() throws -> [(String, String)] {
        _ = try Igor1309Dev().publish(withTheme: .igor1309, plugins: [.splash(withClassPrefix: "")])
        let output = repo.appendingPathComponent("Output")
        return try ["index.html", "about/index.html", "portfolio/index.html", "articles/index.html", "tags/index.html", "ru/index.html", "ru/about/index.html"].map {
            ($0, try String(contentsOf: output.appendingPathComponent($0), encoding: .utf8))
        }
    }
}
