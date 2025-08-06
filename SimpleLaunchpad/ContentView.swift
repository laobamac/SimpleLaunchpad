//
//  ContentView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var searchText = ""
    @State private var window: NSWindow?
    @State private var isShowing = false
    
    var body: some View {
        ZStack {
            // 点击外部关闭
            if isShowing {
                ClickOutsideHandler {
                    closeWindow()
                }
            }
            
            BackgroundEffectView()
            
            VStack(spacing: 20) {
                SearchBarView(searchText: $searchText)
                    .padding(.top, 20)
                    .padding(.horizontal, 30)
                    .opacity(isShowing ? 1 : 0)
                    .offset(y: isShowing ? 0 : -20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // 主应用
                        if !filteredMainApps.isEmpty {
                            LazyVGrid(columns: gridColumns, spacing: 30) {
                                ForEach(filteredMainApps) { app in
                                    AppIconView(app: app, onOpen: closeWindow)
                                        .scaleEffect(isShowing ? 1 : 0.8)
                                        .opacity(isShowing ? 1 : 0)
                                        .animation(.interpolatingSpring(stiffness: 200, damping: 15)
                                            .delay(Double(filteredMainApps.firstIndex(where: { $0.id == app.id }) ?? 0) * 0.03),
                                                   value: isShowing)
                                }
                            }
                            .padding(.bottom, 30)
                        }
                        
                        // 系统应用
                        if !filteredSystemApps.isEmpty {
                            AppSectionView(title: "系统应用", apps: filteredSystemApps, isShowing: isShowing, onOpen: closeWindow)
                        }
                        
                        // 用户应用
                        if !filteredUserApps.isEmpty {
                            AppSectionView(title: "用户应用", apps: filteredUserApps, isShowing: isShowing, onOpen: closeWindow)
                        }
                    }
                    .padding(30)
                    .opacity(isShowing ? 1 : 0)
                }
            }
        }
        .background(WindowAccessor { window in
            self.window = window
            configureWindow(window)
        })
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isShowing = true
            }
        }
    }
    
    // 计算属性
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 20), count: 6)
    }
    
    private var filteredMainApps: [AppItem] {
        filterApps(appManager.mainApps)
    }
    
    private var filteredSystemApps: [AppItem] {
        filterApps(appManager.systemApps)
    }
    
    private var filteredUserApps: [AppItem] {
        filterApps(appManager.userApps)
    }
    
    private func filterApps(_ apps: [AppItem]) -> [AppItem] {
        searchText.isEmpty ? apps : apps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func configureWindow(_ window: NSWindow?) {
        window?.standardWindowButton(.closeButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
        window?.backgroundColor = .clear
        window?.level = .floating
    }
    
    private func closeWindow() {
        withAnimation(.easeIn(duration: 0.2)) {
            isShowing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.hide(nil)
        }
    }
}

struct AppSectionView: View {
    let title: String
    let apps: [AppItem]
    let isShowing: Bool
    var onOpen: (() -> Void)?
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 20), count: 6)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
                .opacity(isShowing ? 1 : 0)
                .offset(y: isShowing ? 0 : -10)
            
            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(apps) { app in
                    AppIconView(app: app, onOpen: onOpen)
                        .scaleEffect(isShowing ? 1 : 0.8)
                        .opacity(isShowing ? 1 : 0)
                        .animation(
                            .interpolatingSpring(stiffness: 200, damping: 15)
                                .delay(Double(apps.firstIndex(where: { $0.id == app.id }) ?? 0) * 0.03),
                            value: isShowing
                        )
                }
            }
        }
    }
}
