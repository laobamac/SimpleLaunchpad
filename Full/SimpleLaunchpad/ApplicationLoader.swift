//
//  ApplicationLoader.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import Foundation

extension Array where Element == ApplicationItem {
    static func loadSystemAndCustomApplications() -> [ApplicationItem] {
        var searchPaths = ["/Applications", "/System/Applications", "/System/Applications/Utilities"]
        searchPaths.append(contentsOf: ApplicationSettings.main.currentSettings.customApplicationLocations)
        
        var discoveredApplications: [ApplicationItem] = []
        
        for directoryPath in searchPaths {
            guard let directoryContents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath) else {
                continue
            }
            
            for item in directoryContents where item.hasSuffix(".app") {
                let fullPath = directoryPath + "/" + item
                let appBundle = Bundle(path: fullPath)
                let appDisplayName = appBundle?.localizedInfoDictionary?["CFBundleDisplayName"] as? String
                    ?? appBundle?.infoDictionary?["CFBundleDisplayName"] as? String
                    ?? item.replacingOccurrences(of: ".app", with: "")
                
                let category = determineApplicationCategory(applicationName: appDisplayName)
                discoveredApplications.append(
                    ApplicationItem(
                        title: appDisplayName,
                        location: fullPath,
                        group: category
                    )
                )
            }
        }
        
        switch ApplicationSettings.main.currentSettings.sortingMethod {
        case .alphabetical:
            return discoveredApplications.sorted {
                localizedCaseInsensitiveCompare($0.title, $1.title)
            }
            
        case .customOrder:
            let orderedPaths = ApplicationSettings.main.currentSettings.applicationSequence
            var orderedApps: [ApplicationItem] = []
            var remainingApps = discoveredApplications
            
            for path in orderedPaths {
                if let matchingApp = remainingApps.first(where: { $0.location == path }) {
                    orderedApps.append(matchingApp)
                    remainingApps.removeAll { $0.location == path }
                }
            }
            
            return orderedApps + remainingApps.sorted {
                localizedCaseInsensitiveCompare($0.title, $1.title)
            }
        }
    }
    
    private static func localizedCaseInsensitiveCompare(_ s1: String, _ s2: String) -> Bool {
        return s1.localizedCaseInsensitiveCompare(s2) == .orderedAscending
    }
}
