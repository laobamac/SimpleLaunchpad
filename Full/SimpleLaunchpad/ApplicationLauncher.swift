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
    @State private var isLaunching = false
    @State private var isHidden = false
    @StateObject private var hotKeyObserver = GlobalHotKeyObserver.shared
    @State private var resetViewID = UUID()
    @State private var shouldShowWindow = false
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        DockIconHandler.shared.setup()
    }
    
    var applicationsInCurrentCategory: [ApplicationItem] {
        currentCategory == "全部" ?
            allApplications :
            allApplications.filter { $0.group == currentCategory }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topTrailing) {
                FullScreenWindowModifier()
                .onAppear {
                    // 确保Dock点击时重置状态
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
                
                if isLaunching {
                    LaunchAnimationView()
                } else if !isHidden {
                    ContentWrapperView(
                        applications: applicationsInCurrentCategory,
                        onClose: { hideInsteadOfQuit() },
                        isShowingPreferences: $isShowingPreferences
                    )
                    .id(resetViewID)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("ShowLaunchpadNotification"))) { _ in
                showLaunchpad()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isLaunching = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLaunching = false
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
                
                // 添加重新显示启动台的菜单项
                Button("显示启动台") {
                    showLaunchpad()
                }
                .keyboardShortcut("L", modifiers: [.command, .shift])
            }
        }
    }
    
    // 隐藏而不是退出
    private func hideInsteadOfQuit() {
        withAnimation(.easeIn(duration: 0.3)) {
            isHidden = true
        }
        NSApp.hide(nil)
    }
    
    // 重新显示启动台
    private func showLaunchpad() {
        NSApp.unhide(nil)
        resetViewID = UUID() // 每次显示时生成新的ID
        withAnimation(.easeOut(duration: 0.3)) {
            isHidden = false
        }
    }
    
    struct ContentWrapperView: View {
        let applications: [ApplicationItem]
        let onClose: () -> Void
        @Binding var isShowingPreferences: Bool
        
        var body: some View {
            PaginatedApplicationGrid(
                applicationPages: applications.dividedIntoChunks(of: 35),
                onClose: onClose
            )
            .frame(minWidth: 800, minHeight: 600)
            .ignoresSafeArea()
            .sheet(isPresented: $isShowingPreferences) {
                PreferencesView {
                    isShowingPreferences = false
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 启动时不显示窗口
        NSApp.setActivationPolicy(.accessory)
        NSApp.hide(nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // 点击Dock图标时显示窗口
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        return true
    }
}
