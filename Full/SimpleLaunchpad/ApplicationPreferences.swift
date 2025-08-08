//
//  ApplicationPreferences.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import Foundation

struct ApplicationPreferences: Codable {
    var applicationSequence: [String] = []
    var applicationGroups: [ApplicationCollection] = []
    var customApplicationLocations: [String] = []
    var sortingMethod: SortingMethod = .alphabetical
    
    enum SortingMethod: String, Codable {
        case alphabetical
        case customOrder
    }
}

func determineApplicationCategory(applicationName: String) -> String {
    let categoryMapping: [String: String] = [
        "Safari": "网络",
        "Mail": "网络",
        "FaceTime": "网络",
        "Terminal": "实用工具",
        "System Settings": "系统",
        "Preview": "实用工具",
        "Photos": "创意",
        "GarageBand": "创意",
        "Final Cut Pro": "创意",
        "微信": "社交",
        "QQ": "社交",
        "网易云音乐": "音乐",
        "腾讯会议": "办公"
    ]
    
    return categoryMapping[applicationName] ?? "其他"
}
