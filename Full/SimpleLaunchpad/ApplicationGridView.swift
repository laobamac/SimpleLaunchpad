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
                        VStack(spacing: 10) {
                            Image(nsImage: app.applicationIcon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: layoutMetrics.iconSize, height: layoutMetrics.iconSize)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Text(app.title)
                                .font(.system(size: layoutMetrics.fontSize))
                                .multilineTextAlignment(.center)
                                .frame(width: layoutMetrics.cellSize)
                        }
                        .onTapGesture {
                            NSWorkspace.shared.open(URL(fileURLWithPath: app.location))
                            NSApp.terminate(nil)
                        }
                    }
                }
                .padding(.horizontal, layoutMetrics.horizontalPadding)
                .padding(.vertical, layoutMetrics.verticalPadding)
            }
        }
        .scaleEffect(isVisible ? 1 : 0.85)
        .opacity(isVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
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

private struct LayoutMetrics {
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let spacing: CGFloat
    let cellSize: CGFloat
    let iconSize: CGFloat
    let fontSize: CGFloat
}
