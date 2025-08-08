//
//  ApplicationGridView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import SwiftUI

struct ApplicationGridView: View {
    let applications: [ApplicationItem]
    let columnCount: Int
    @State private var isVisible = false
    @State private var launchingAppID: UUID?
    @State private var isClosing = false
    let onClose: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let layoutMetrics = calculateLayoutMetrics(geometry: geometry)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(
                            .fixed(layoutMetrics.cellSize),
                            spacing: layoutMetrics.spacing
                        ),
                        count: columnCount
                    ),
                    spacing: layoutMetrics.spacing
                ) {
                    ForEach(applications) { app in
                        AppIconView(
                            app: app,
                            layoutMetrics: layoutMetrics,
                            isLaunching: launchingAppID == app.id,
                            onTap: {
                                launchApp(app)
                            }
                        )
                    }
                }
                .padding(.horizontal, layoutMetrics.horizontalPadding)
                .padding(.vertical, layoutMetrics.verticalPadding)
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .scaleEffect(isClosing ? 0.9 : (isVisible ? 1 : 0.85))
        .opacity(isClosing ? 0 : (isVisible ? 1 : 0))
        .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6), value: isClosing)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
    
    private func launchApp(_ app: ApplicationItem) {
        withAnimation(.easeOut(duration: 0.2)) {
            launchingAppID = app.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSWorkspace.shared.open(URL(fileURLWithPath: app.location))
            
            withAnimation(.easeIn(duration: 0.3)) {
                isClosing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onClose() // 调用回调而不是直接退出
            }
        }
    }
    
    private func calculateLayoutMetrics(geometry: GeometryProxy) -> LayoutMetrics {
        let aspectRatio = geometry.size.width / geometry.size.height
        let horizontalPadding = geometry.size.width * 0.06
        let verticalPadding: CGFloat = {
            if aspectRatio > 2.0 { return 0 }
            if geometry.size.height < 800 { return geometry.size.height * 0.05 }
            return geometry.size.height * 0.08
        }()
        
        let spacing: CGFloat = {
            if aspectRatio > 2.0 { return geometry.size.height * 0.02 }
            if geometry.size.height < 800 { return geometry.size.height * 0.04 }
            return geometry.size.height * 0.03
        }()
        
        let totalSpacing = CGFloat(columnCount - 1) * spacing
        let cellSize = (geometry.size.width - (horizontalPadding * 2) - totalSpacing) / CGFloat(columnCount)
        let iconSize = cellSize * 0.5
        let fontSize = max(10, cellSize * 0.04)
        
        return LayoutMetrics(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            spacing: spacing,
            cellSize: cellSize,
            iconSize: iconSize,
            fontSize: fontSize
        )
    }
}

struct LayoutMetrics {
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let spacing: CGFloat
    let cellSize: CGFloat
    let iconSize: CGFloat
    let fontSize: CGFloat
}

struct AppIconView: View {
    let app: ApplicationItem
    let layoutMetrics: LayoutMetrics
    let isLaunching: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: app.applicationIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: layoutMetrics.iconSize, height: layoutMetrics.iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(isLaunching ? 1.3 : 1)
                .opacity(isLaunching ? 0 : 1)
                .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isLaunching)
                .overlay(
                    Group {
                        if isLaunching {
                            ProgressView()
                                .scaleEffect(1.5)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                )
            
            Text(app.title)
                .font(.system(size: layoutMetrics.fontSize))
                .multilineTextAlignment(.center)
                .frame(width: layoutMetrics.cellSize)
                .opacity(isLaunching ? 0.5 : 1)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
