//
//  igor1309devTests.swift
//  igor1309devTests
//
//  Created by Igor Malyarov on 01.09.2022.
//

@testable import igor1309dev
import SnapshotTesting
import WebKit
import XCTest

final class igor1309devTests: XCTestCase {
    func testIndex() throws {
        let website = try Igor1309Dev().publish(
            withTheme: .igor1309,
            plugins: [.splash(withClassPrefix: "")]
        )

        let indexHTML = website.index.body.html
        
        assertSnapshot(matching: indexHTML, as: .dump)
        // assertSnapshot(matching: indexHTML, as: .image)
        // assertSnapshot(matching: indexHTML, as: .html)
    }

    func testSections() throws {
        let website = try Igor1309Dev().publish(
            withTheme: .igor1309,
            plugins: [.splash(withClassPrefix: "")]
        )

        let sectionHTMLs = website.sections.map(\.content.body.html)
                
        assertSnapshots(matching: sectionHTMLs, as: [.dump])
        // assertSnapshots(matching: sectionHTMLs, as: [.image])
        // assertSnapshots(matching: sectionHTMLs, as: [.html])
    }

    func testPages() throws {
        let website = try Igor1309Dev().publish(
            withTheme: .igor1309,
            plugins: [.splash(withClassPrefix: "")]
        )

        let pageHTMLs = website.pages.map(\.value.content.body.html)
        
        assertSnapshots(matching: pageHTMLs, as: [.dump])
        // assertSnapshots(matching: pageHTMLs, as: [.image])
        // assertSnapshots(matching: pageHTMLs, as: [.html])
    }
    
    func test_PagesHtml() throws {
        let website = try Igor1309Dev().publish(
            withTheme: .igor1309,
            plugins: [.splash(withClassPrefix: "")]
        )

        let pageHTML = website.pages.map(\.value.content.body.html)[0]
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2000))
        webView.loadHTMLString(pageHTML, baseURL: nil)
        
        assertSnapshot(matching: webView, as: .wait(for: 1, on: .image))
    }
}
