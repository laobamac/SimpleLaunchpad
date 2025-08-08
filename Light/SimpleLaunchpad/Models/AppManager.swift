//
//  AppManager.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI
import AppKit
import Darwin

class AppManager: ObservableObject {
    @Published var systemApps: [AppItem] = []
    @Published var userApps: [AppItem] = []
    @Published var mainApps: [AppItem] = []
    
    private var fileMonitorSources: [DispatchSourceFileSystemObject] = []
    
    // 定义应用目录路径
    private let systemAppDir = "/System/Applications"
    private let userAppDir = ("\(NSHomeDirectory())/Applications")
    private let mainAppDir = "/Applications"
    
    init() {
        loadApplications()
        setupObservers()
    }
    
    func loadApplications() {
        // 系统应用 (macOS内置应用)
        systemApps = scanApplications(at: systemAppDir)
        
        // 用户应用 (用户自己安装到用户目录的应用)
        userApps = scanApplications(at: userAppDir)
        
        // 主应用目录 (常规安装位置)
        mainApps = scanApplications(at: mainAppDir)
    }
    
    private func scanApplications(at path: String) -> [AppItem] {
        guard let url = URL(string: path) ?? URL(fileURLWithPath: path) as URL? else {
            return []
        }
        
        let fileManager = FileManager.default
        var apps: [AppItem] = []
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            )
            
            apps = contents
                .filter { $0.pathExtension == "app" }
                .compactMap { AppItem(from: $0) }
                .sorted { $0.name < $1.name }
            
        } catch {
            print("Error scanning applications at \(path): \(error)")
        }
        
        return apps
    }
    
    private func setupObservers() {
        // 应用启动后隐藏启动台
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: .main
        ) { _ in
            NSApp.hide(nil)
        }
        
        // 监视所有应用目录的变化
        [systemAppDir, userAppDir, mainAppDir].forEach { path in
            monitorDirectory(path: path)
        }
    }
    
    private func monitorDirectory(path: String) {
        let fileDescriptor = Darwin.open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            print("Failed to monitor directory: \(path)")
            return
        }
        
        let queue = DispatchQueue.global(qos: .utility)
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: queue
        )
        
        source.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.loadApplications()
            }
        }
        
        source.setCancelHandler {
            close(fileDescriptor)
        }
        
        source.resume()
        fileMonitorSources.append(source)
    }
    
    func open(app: AppItem) {
        NSWorkspace.shared.open(app.path)
    }
    
    deinit {
        fileMonitorSources.forEach { $0.cancel() }
        NotificationCenter.default.removeObserver(self)
    }
}
