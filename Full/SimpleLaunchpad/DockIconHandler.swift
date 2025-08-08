//
//  DockIconHandler.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/9.
//

import AppKit

class DockIconHandler {
    static let shared = DockIconHandler()
    private var observer: Any?
    
    func setup() {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            if NSApp.isActive {
                NotificationCenter.default.post(
                    name: .init("ShowLaunchpadNotification"),
                    object: nil
                )
            }
        }
    }
}
