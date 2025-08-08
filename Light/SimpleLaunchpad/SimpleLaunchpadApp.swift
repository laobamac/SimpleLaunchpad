//
//  SimpleLaunchpadApp.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI

@main
struct SimpleLaunchpadApp: App {
    @StateObject private var appManager = AppManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appManager)
                .frame(width: 800, height: 600)
                .background(WindowAccessor { window in
                    window?.standardWindowButton(.closeButton)?.isHidden = true
                    window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window?.standardWindowButton(.zoomButton)?.isHidden = true
                    window?.titleVisibility = .hidden
                    window?.titlebarAppearsTransparent = true
                    window?.isMovableByWindowBackground = true
                    window?.backgroundColor = .clear
                })
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
