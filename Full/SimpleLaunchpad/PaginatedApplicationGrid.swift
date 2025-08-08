//
//  PaginatedApplicationGrid.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/7.
//

import SwiftUI

struct PaginatedApplicationGrid: View {
    let applicationPages: [[ApplicationItem]]
    private let columnsPerPage = 7
    private let rowsPerPage = 5
    @State private var currentPageIndex = 0
    @GestureState private var dragTranslation: CGFloat = 0
    @State private var lastScrollTimestamp = Date.distantPast
    private let scrollCooldown: TimeInterval = 0.4
    @State private var filterText = ""
    @State private var eventObserver: Any?
    
    var body: some View {
        ZStack {
            GlassBackgroundEffect()
            
            VStack(spacing: 0) {
                SearchBarView(text: $filterText)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                if filterText.isEmpty {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ForEach(0..<applicationPages.count, id: \.self) { index in
                                ApplicationGridView(
                                    applications: applicationPages[index],
                                    columnCount: columnsPerPage
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                        .offset(x: -CGFloat(currentPageIndex) * geometry.size.width)
                        .offset(x: dragTranslation)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 100), value: currentPageIndex)
                    }
                    .gesture(
                        DragGesture()
                            .updating($dragTranslation) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                handleDragEnd(value: value)
                            }
                    )
                    .onAppear {
                        registerEventHandlers()
                    }
                    .onDisappear {
                        unregisterEventHandlers()
                    }
                    
                    PageIndicatorView(
                        pageCount: applicationPages.count,
                        currentPage: currentPageIndex
                    )
                    .padding(.top, 15)
                    .padding(.bottom, 90)
                } else {
                    FilteredResultsView(applications: filteredApplications())
                }
            }
        }
    }
    
    private func filteredApplications() -> [ApplicationItem] {
        applicationPages.flatMap { $0 }.filter {
            $0.title.localizedCaseInsensitiveContains(filterText)
        }
    }
    
    private func handleDragEnd(value: DragGesture.Value) {
        let threshold: CGFloat = 200 // 拖动阈值
        var newPage = currentPageIndex
        
        if -value.translation.width > threshold {
            newPage = min(currentPageIndex + 1, applicationPages.count - 1)
        } else if value.translation.width > threshold {
            newPage = max(currentPageIndex - 1, 0)
        }
        
        currentPageIndex = newPage
    }
    
    private func registerEventHandlers() {
        // 鼠标滚轮翻页
        eventObserver = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            let now = Date()
            if now.timeIntervalSince(lastScrollTimestamp) < scrollCooldown {
                return event
            }
            
            let scrollThreshold: CGFloat = 10
            if event.scrollingDeltaY < -scrollThreshold {
                currentPageIndex = min(currentPageIndex + 1, applicationPages.count - 1)
                lastScrollTimestamp = now
                return nil
            } else if event.scrollingDeltaY > scrollThreshold {
                currentPageIndex = max(currentPageIndex - 1, 0)
                lastScrollTimestamp = now
                return nil
            }
            
            return event
        }
        
        // ESC键退出
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // ESC键
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
    }
    
    private func unregisterEventHandlers() {
        if let observer = eventObserver {
            NSEvent.removeMonitor(observer)
        }
    }
}

// MARK: - Subviews

private struct GlassBackgroundEffect: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

private struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Spacer()
            SearchField(text: $text)
                .frame(width: 250, height: 30)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 2)
            Spacer()
        }
    }
}

private struct SearchField: NSViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.delegate = context.coordinator
        searchField.focusRingType = .none
        DispatchQueue.main.async {
            searchField.becomeFirstResponder()
        }
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        let parent: SearchField
        
        init(_ parent: SearchField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ notification: Notification) {
            if let field = notification.object as? NSSearchField {
                parent.text = field.stringValue
            }
        }
    }
}

private struct PageIndicatorView: View {
    let pageCount: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

private struct FilteredResultsView: View {
    let applications: [ApplicationItem]
    private let columns = 7
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 30),
                        count: columns
                    ),
                    spacing: 20
                ) {
                    ForEach(applications) { app in
                        ApplicationCellView(
                            application: app,
                            iconSize: 60,
                            fontSize: 12,
                            cellWidth: 100
                        )
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
            }
        }
    }
}

private struct ApplicationCellView: View {
    let application: ApplicationItem
    let iconSize: CGFloat
    let fontSize: CGFloat
    let cellWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: application.applicationIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(application.title)
                .font(.system(size: fontSize))
                .multilineTextAlignment(.center)
                .frame(maxWidth: cellWidth)
        }
        .onTapGesture {
            NSWorkspace.shared.open(URL(fileURLWithPath: application.location))
            NSApp.terminate(nil)
        }
    }
}
