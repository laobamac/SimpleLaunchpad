//
//  SimpleLaunchpadApp.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import SwiftUI

extension Array {
    func dividedIntoChunks(of size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

@main
struct ApplicationLauncher: App {
    @State private var allApplications: [ApplicationItem] = .loadSystemAndCustomApplications()
    @State private var currentCategory: String = "全部"
    @State private var isShowingPreferences = false

    var applicationsInCurrentCategory: [ApplicationItem] {
        currentCategory == "全部" ?
            allApplications :
            allApplications.filter { $0.group == currentCategory }
    }

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                FullScreenWindowModifier()
                PaginatedApplicationGrid(
                    applicationPages: applicationsInCurrentCategory.dividedIntoChunks(of: 35) // 修正参数
                )
                    .frame(minWidth: 800, minHeight: 600) // 添加frame修饰符
                    .ignoresSafeArea()
                    .sheet(isPresented: $isShowingPreferences) {
                        PreferencesView {
                            isShowingPreferences = false
                        }
                    }
            }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("偏好设置...") {
                    isShowingPreferences = true
                }
                .keyboardShortcut(",", modifiers: [.command])
            }
        }
    }
}
