//
//  AppIconView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI

struct AppIconView: View {
    let app: AppItem
    var onOpen: (() -> Void)?
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .scaleEffect(isHovering ? 1.1 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isHovering)
                    .shadow(color: Color.black.opacity(0.2), radius: isHovering ? 10 : 5, x: 0, y: isHovering ? 5 : 2)
            }
            
            Text(app.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 80)
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 1)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovering ? 0.2 : 0.1))
                .animation(.easeInOut, value: isHovering)
        )
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button("打开") {
                openApp()
            }
            
            Button("在 Finder 中显示") {
                showInFinder()
            }
            
            Divider()
            
            Button("删除") {
                moveToTrash()
            }
        }
        .onTapGesture {
            openApp()
        }
    }
    
    private func openApp() {
        NSWorkspace.shared.open(app.path)
        onOpen?()
    }
    
    private func showInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([app.path])
        onOpen?()
    }
    
    private func moveToTrash() {
        do {
            try FileManager.default.trashItem(at: app.path, resultingItemURL: nil)
            onOpen?()
        } catch {
            print("删除失败: \(error)")
        }
    }
}
