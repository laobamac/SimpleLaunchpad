//
//  PreferencesView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import SwiftUI

struct PreferencesView: View {
    var onCloseAction: () -> Void
    @State private var selectedTab: PreferenceTab = .general
    
    enum PreferenceTab: String, CaseIterable, Identifiable {
        case general = "通用"
        case apps = "应用管理"
        case advanced = "高级"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header View
            HStack {
                Spacer()
                Button("完成") {
                    onCloseAction()
                }
                .keyboardShortcut(.cancelAction)
                .padding(.trailing, 10)
            }
            .padding(.top, 10)
            
            Divider()
            
            // Tab Selection View
            Picker("设置标签页", selection: $selectedTab) {
                ForEach(PreferenceTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Divider()
            
            // Tab Content View
            Group {
                switch selectedTab {
                case .general:
                    GeneralPreferencesView()
                case .apps:
                    ApplicationManagementView()
                case .advanced:
                    AdvancedPreferencesView()
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            // Footer Relaunch Button
            HStack {
                Spacer()
                Button("重新启动应用") {
                    relaunchApplication()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .frame(minWidth: 400, minHeight: 300)
    }
    
    private func relaunchApplication() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-n", Bundle.main.bundlePath]
        try? task.run()
        NSApp.terminate(nil)
    }
}

struct GeneralPreferencesView: View {
    @State private var sortingMode = ApplicationSettings.main.currentSettings.sortingMethod
    @State private var launchOnLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用排序方式")
                .font(.headline)
            
            Picker("排序模式", selection: $sortingMode) {
                Text("按名称排序").tag(ApplicationPreferences.SortingMethod.alphabetical)
                Text("手动排序").tag(ApplicationPreferences.SortingMethod.customOrder)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: sortingMode) { newMode in
                ApplicationSettings.main.updateSortingMethod(newMode)
            }
            
            Divider()
            
            Toggle("登录时自动启动", isOn: $launchOnLogin)
        }
    }
}

struct AdvancedPreferencesView: View {
    @State private var showingResetConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("高级选项")
                .font(.headline)
            
            Button(role: .destructive) {
                showingResetConfirmation = true
            } label: {
                Text("恢复默认设置")
            }
            .alert("确认恢复默认设置?", isPresented: $showingResetConfirmation) {
                Button("取消", role: .cancel) {}
                Button("恢复", role: .destructive) {
                    resetAllSettings()
                }
            } message: {
                Text("这将重置所有设置到初始状态")
            }
        }
    }
    
    private func resetAllSettings() {
        ApplicationSettings.main.updateApplicationSequence([])
        ApplicationSettings.main.updateCustomLocations([])
        ApplicationSettings.main.updateApplicationGroups([])
        ApplicationSettings.main.updateSortingMethod(.alphabetical)
    }
}
