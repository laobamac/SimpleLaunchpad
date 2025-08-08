//
//  GlobalHotKeyObserver.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/9.
//

import Cocoa
import SwiftUI
import Combine

class GlobalHotKeyObserver: ObservableObject {
    static let shared = GlobalHotKeyObserver()
    private var eventMonitor: Any?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showLaunchpad = PassthroughSubject<Void, Never>()
    
    private init() {
        setupHotKeyObserver()
    }
    
    private func setupHotKeyObserver() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 37 { // Cmd+Shift+L
                self.showLaunchpad.send()
            }
        }
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
