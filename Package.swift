// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "EncryptedCoreData",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "EncryptedCoreData",
            targets: ["EncryptedCoreData"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", from: "4.10.0"),
    ],
    targets: [
        .target(
            name: "EncryptedCoreData",
            dependencies: [.product(name: "SQLCipher", package: "SQLCipher.swift")],
            path: "Sources/EncryptedCoreData",
            exclude: [],
            publicHeadersPath: ".",
            cSettings: [
                .define("SQLITE_HAS_CODEC"),
                .define("SQLCIPHER_CRYPTO_CC"),
            ],
            linkerSettings: [
                .linkedFramework("CoreData"),
                .linkedFramework("Security"),
            ]
        ),
    ]
)
