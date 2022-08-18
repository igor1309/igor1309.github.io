// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "igor1309.dev",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "igor1309.dev",
            targets: ["igor1309.dev"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/publish.git",
            from: "0.9.0"
        ),
        .package(
            url: "https://github.com/johnsundell/splashpublishplugin",
            from: "0.2.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "igor1309.dev",
            dependencies: [
                .product(
                    name: "Publish",
                    package: "publish"
                ),
                .product(
                    name: "SplashPublishPlugin",
                    package: "splashpublishplugin"
                )
            ]
        )
    ]
)
