//
//  ApplicationDataModels.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import AppKit

struct ApplicationItem: Identifiable, Codable {
    let uniqueID = UUID()
    var id = UUID()
    let title: String
    let location: String
    let group: String
    
    enum SerializationKeys: String, CodingKey {
        case title = "name"
        case location = "path"
        case group = "category"
    }
    
    var applicationIcon: NSImage {
        let image = NSWorkspace.shared.icon(forFile: location)
        image.size = NSSize(width: 64, height: 64)
        return image
    }
}

struct ApplicationCollection: Codable, Identifiable {
    var uniqueID = UUID()
    var id = UUID()
    var collectionName: String
    var containedApplications: [String]
}
