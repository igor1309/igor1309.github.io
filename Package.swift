// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "igor1309dev",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "igor1309dev",
            targets: ["igor1309dev"]
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
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "igor1309dev",
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
        ),
        .testTarget(
            name: "igor1309devTests",
            dependencies: [
                "igor1309dev",
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing"
                ),
            ]
        )
    ]
)
