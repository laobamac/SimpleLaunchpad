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
        var icon: String {
            switch self {
            case .general: return "gear"
            case .apps: return "app.badge"
            case .advanced: return "command"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // 侧边栏
            VStack(alignment: .leading, spacing: 8) {
                ForEach(PreferenceTab.allCases) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Label(tab.rawValue, systemImage: tab.icon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(selectedTab == tab ? Color.accentColor.opacity(0.2) : Color.clear)
                    .cornerRadius(6)
                }
                Spacer()
            }
            .frame(width: 180)
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // 主内容区
            VStack(spacing: 0) {
                switch selectedTab {
                case .general:
                    GeneralPreferencesView()
                case .apps:
                    ApplicationManagementView()
                case .advanced:
                    AdvancedPreferencesView()
                }
                
                Divider()
                
                HStack {
                    Spacer()
                    Button("完成") {
                        onCloseAction()
                    }
                    .keyboardShortcut(.escape)
                }
                .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct GeneralPreferencesView: View {
    @State private var sortingMode = ApplicationSettings.main.currentSettings.sortingMethod
    @State private var launchOnLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
