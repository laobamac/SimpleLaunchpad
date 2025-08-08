//
//  AppItem.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI

struct AppItem: Identifiable {
    let id = UUID()
    let name: String
    let path: URL
    let icon: NSImage?
    
    init?(from url: URL) {
        self.path = url
        self.name = url.deletingPathExtension().lastPathComponent
        
        guard let resources = try? url.resourceValues(forKeys: [.effectiveIconKey]),
              let icon = resources.effectiveIcon as? NSImage else {
            return nil
        }
        
        self.icon = icon
    }
}
