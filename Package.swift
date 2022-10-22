// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CollectionViewShelfLayout",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "CollectionViewShelfLayout",
            targets: ["CollectionViewShelfLayout"]
        )
    ],
    targets: [
        .target(
            name: "CollectionViewShelfLayout",
            path: "CollectionViewShelfLayout",
            exclude: ["Info.plist"]
        )
    ]
)
