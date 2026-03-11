// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppForegronder",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "AppForegronder",
            path: "AppForegronder",
            exclude: ["Info.plist", "AppForegronder.entitlements"]
        )
    ]
)
