import ProjectDescription
import TemplateDescription

let nameArgument: Template.Attribute = .required("name")
let platformArgument: Template.Attribute = .optional("platform", default: "iOS")

let setupContent = """
import ProjectDescription

let setup = Setup([
    // .homebrew(packages: ["swiftlint", "carthage"]),
    // .carthage()
])
"""

let projectDescriptionHelpersContent = """
import ProjectDescription

extension Project {

    public static func app(name: String, platform: Platform, dependencies: [TargetDependency] = []) -> Project {
        return self.project(name: name, product: .app, platform: platform, dependencies: dependencies, infoPlist: [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1"
        ])
    }

    public static func framework(name: String, platform: Platform, dependencies: [TargetDependency] = []) -> Project {
        return self.project(name: name, product: .framework, platform: platform, dependencies: dependencies)
    }

    public static func project(name: String,
                               product: Product,
                               platform: Platform,
                               dependencies: [TargetDependency] = [],
                               infoPlist: [String: InfoPlist.Value] = [:]) -> Project {
        return Project(name: name,
                       targets: [
                        Target(name: name,
                                platform: platform,
                                product: product,
                                bundleId: "io.tuist.\\(name)",
                                infoPlist: .extendingDefault(with: infoPlist),
                                sources: ["Sources/**"],
                                resources: [],
                                dependencies: dependencies),
                        Target(name: "\\(name)Tests",
                                platform: platform,
                                product: .unitTests,
                                bundleId: "io.tuist.\\(name)Tests",
                                infoPlist: .default,
                                sources: "Tests/**",
                                dependencies: [
                                    .target(name: "\\(name)")
                                ])
                      ])
    }

}
"""

let projectsPath = "Projects"
let appPath = projectsPath + "/\(nameArgument)"
let kitFrameworkPath = projectsPath + "/\(nameArgument)Kit"
let supportFrameworkPath = projectsPath + "/\(nameArgument)Support"

func directories(for projectPath: String) -> [String] {
    [
        projectPath,
        projectPath + "/Sources",
        projectPath + "/Tests",
        projectPath + "/Playgrounds",
    ]
}

let appContent = """
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(name: "\(nameArgument)", platform: .\(platformArgument), dependencies: [
    .project(target: "\(nameArgument)Kit", path: .relativeToManifest("../\(nameArgument)Kit"))
])
"""
let kitFrameworkContent = """
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(name: "\(nameArgument)Kit", platform: .\(platformArgument), dependencies: [
    .project(target: "\(nameArgument)Support", path: .relativeToManifest("../\(nameArgument)Support"))
])
"""
let supportFrameworkContent = """
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(name: "\(nameArgument)Support", platform: .\(platformArgument), dependencies: [])
"""

let workspaceContent = """
import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(name: "\(nameArgument)", projects: [
    "Projects/\(nameArgument)",
    "Projects/\(nameArgument)Kit",
    "Projects/\(nameArgument)Support"
])
"""

let template = Template(
    description: "Custom \(nameArgument)",
    arguments: [
        nameArgument,
        platformArgument,
    ],
    files: [
        Template.File(path: "Setup.swift",
                      contents: .static(setupContent)),
        Template.File(path: "Workspace.swift",
                      contents: .static(workspaceContent)),
        Template.File(path: "Tuist/ProjectDescriptionHelpers/Project+Templates.swift",
                      contents: .static(projectDescriptionHelpersContent)),
        Template.File(path: appPath + "/Project.swift",
                      contents: .static(appContent)),
        Template.File(path: kitFrameworkPath + "/Project.swift",
                      contents: .static(kitFrameworkContent)),
        Template.File(path: supportFrameworkPath + "/Project.swift",
                      contents: .static(supportFrameworkContent)),
    ],
    directories: [
        "Tuist/ProjectDescriptionHelpers",
    ] + directories(for: appPath) + directories(for: kitFrameworkPath) + directories(for: supportFrameworkPath)
)
