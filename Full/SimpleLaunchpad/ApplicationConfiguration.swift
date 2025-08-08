//
//  ApplicationConfiguration.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import Foundation

class ApplicationSettings {
    static let main = ApplicationSettings()
    private let settingsFileURL: URL
    private(set) var currentSettings: ApplicationPreferences
    
    private init() {
        let appSupportDir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("AppLauncher")
        
        try? FileManager.default.createDirectory(
            at: appSupportDir,
            withIntermediateDirectories: true
        )
        
        settingsFileURL = appSupportDir.appendingPathComponent("user_preferences.json")
        
        if let savedData = try? Data(contentsOf: settingsFileURL),
           let decodedSettings = try? JSONDecoder().decode(
            ApplicationPreferences.self,
            from: savedData
           ) {
            currentSettings = decodedSettings
        } else {
            currentSettings = ApplicationPreferences()
            persistSettings()
        }
    }
    
    private func persistSettings() {
        if let encodedData = try? JSONEncoder().encode(currentSettings) {
            try? encodedData.write(to: settingsFileURL)
        }
    }
    
    func updateApplicationSequence(_ sequence: [String]) {
        currentSettings.applicationSequence = sequence
        persistSettings()
    }
    
    func updateSortingMethod(_ method: ApplicationPreferences.SortingMethod) {
        currentSettings.sortingMethod = method
        persistSettings()
    }
    
    func updateApplicationGroups(_ groups: [ApplicationCollection]) {
        currentSettings.applicationGroups = groups
        persistSettings()
    }
    
    func updateCustomLocations(_ locations: [String]) {
        currentSettings.customApplicationLocations = locations
        persistSettings()
    }
}
