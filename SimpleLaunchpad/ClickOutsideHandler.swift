//
//  ClickOutsideHandler.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI

struct ClickOutsideHandler: NSViewRepresentable {
    var onClick: () -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = ClickOutsideNSView()
        view.onClick = onClick
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class ClickOutsideNSView: NSView {
    var onClick: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        if !subviews.contains(where: { $0.hitTest(point) != nil }) {
            onClick?()
        }
    }
}
