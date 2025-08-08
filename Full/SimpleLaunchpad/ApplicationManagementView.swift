//
//  ApplicationManagementView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import SwiftUI

struct ApplicationManagementView: View {
    @State private var applicationOrder: [String] = loadInitialOrder()
    @State private var allApplications: [ApplicationItem] = .loadSystemAndCustomApplications()
    @State private var selectedApplicationPath: String?
    @FocusState private var isListActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("应用排序")
                .font(.headline)
            
            if ApplicationSettings.main.currentSettings.sortingMethod == .customOrder {
                // Application List View (内联实现)
                List(selection: $selectedApplicationPath) {
                    ForEach(applicationOrder, id: \.self) { path in
                        if let app = allApplications.first(where: { $0.location == path }) {
                            HStack {
                                Image(nsImage: app.applicationIcon)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                Text(app.title)
                            }
                            .tag(app.location)
                        }
                    }
                }
                .frame(minHeight: 300)
                .overlay(
                    selectedApplicationPath == nil ?
                        Text("点击选择应用，使用⌘↑和⌘↓移动项目")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    : nil,
                    alignment: .top
                )
                .focused($isListActive)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isListActive = true
                    }
                }
                .background(
                    KeyDownHandlingView { event in
                        guard isListActive else { return }
                        
                        if event.modifierFlags.contains(.command) {
                            switch event.keyCode {
                            case 126: // ⌘↑
                                moveApplication(up: true)
                            case 125: // ⌘↓
                                moveApplication(up: false)
                            default:
                                break
                            }
                        }
                    }
                )
                
                // Reorder Buttons (内联实现)
                HStack {
                    Button("上移") {
                        moveApplication(up: true)
                    }
                    .disabled(selectedApplicationPath == nil || isFirstItem)
                    
                    Button("下移") {
                        moveApplication(up: false)
                    }
                    .disabled(selectedApplicationPath == nil || isLastItem)
                }
            } else {
                Text("请在通用设置中切换到手动排序模式")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Custom Directory Management View (内联实现)
            VStack(alignment: .leading, spacing: 16) {
                Text("自定义应用目录")
                    .font(.headline)
                
                List {
                    ForEach(ApplicationSettings.main.currentSettings.customApplicationLocations, id: \.self) { path in
                        Text(path)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .onDelete(perform: removeCustomDirectory)
                }
                .frame(height: 120)
                
                HStack(spacing: 12) {
                    Button("＋ 添加文件夹") {
                        addCustomDirectory()
                    }
                    Button("－ 移除全部") {
                        removeAllCustomDirectories()
                    }
                    .disabled(ApplicationSettings.main.currentSettings.customApplicationLocations.isEmpty)
                }
            }
            
            Divider()
            
            Text("文件夹功能 (即将推出)")
                .font(.headline)
            Text("您将能够像'创意'、'工作'等那样将应用分组到文件夹中")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - 排序逻辑
    
    private var isFirstItem: Bool {
        guard let selected = selectedApplicationPath,
              let index = applicationOrder.firstIndex(of: selected) else { return true }
        return index == 0
    }
    
    private var isLastItem: Bool {
        guard let selected = selectedApplicationPath,
              let index = applicationOrder.firstIndex(of: selected) else { return true }
        return index == applicationOrder.count - 1
    }
    
    private func moveApplication(up: Bool) {
        guard let selected = selectedApplicationPath,
              let currentIndex = applicationOrder.firstIndex(of: selected) else { return }
        
        let newIndex = up ? currentIndex - 1 : currentIndex + 1
        guard newIndex >= 0 && newIndex < applicationOrder.count else { return }
        
        withAnimation {
            applicationOrder.swapAt(currentIndex, newIndex)
            ApplicationSettings.main.updateApplicationSequence(applicationOrder)
            selectedApplicationPath = applicationOrder[newIndex]
        }
    }
    
    private static func loadInitialOrder() -> [String] {
        let currentOrder = ApplicationSettings.main.currentSettings.applicationSequence
        if currentOrder.isEmpty {
            let allApps = Array.loadSystemAndCustomApplications()
            let paths = allApps.map { $0.location }
            ApplicationSettings.main.updateApplicationSequence(paths)
            return paths
        }
        return currentOrder
    }
    
    // MARK: - 目录管理
    
    private func addCustomDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "选择"
        
        if panel.runModal() == .OK, let url = panel.url {
            let path = url.path
            var dirs = ApplicationSettings.main.currentSettings.customApplicationLocations
            if !dirs.contains(path) {
                dirs.append(path)
                ApplicationSettings.main.updateCustomLocations(dirs)
                reloadApplicationList()
            }
        }
    }
    
    private func removeCustomDirectory(at offsets: IndexSet) {
        var dirs = ApplicationSettings.main.currentSettings.customApplicationLocations
        dirs.remove(atOffsets: offsets)
        ApplicationSettings.main.updateCustomLocations(dirs)
        reloadApplicationList()
    }
    
    private func removeAllCustomDirectories() {
        ApplicationSettings.main.updateCustomLocations([])
        reloadApplicationList()
    }
    
    private func reloadApplicationList() {
        allApplications = .loadSystemAndCustomApplications()
        if ApplicationSettings.main.currentSettings.sortingMethod == .customOrder {
            applicationOrder = allApplications.map { $0.location }
            ApplicationSettings.main.updateApplicationSequence(applicationOrder)
        }
    }
}

// MARK: - 键盘事件处理

struct KeyDownHandlingView: NSViewRepresentable {
    var onKeyDown: (NSEvent) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        context.coordinator.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            onKeyDown(event)
            return event
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        var parent: KeyDownHandlingView
        var monitor: Any?
        
        init(_ parent: KeyDownHandlingView) {
            self.parent = parent
        }
    }
    
    func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        if let monitor = coordinator.monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
