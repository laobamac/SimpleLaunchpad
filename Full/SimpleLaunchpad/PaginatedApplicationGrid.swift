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
    @State private var isClosing = false
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    closeApp()
                }
                .background(GlassBackgroundEffect())
            
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
                                    columnCount: columnsPerPage,
                                    onClose: onClose
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
                    FilteredResultsView(
                        applications: filteredApplications(),
                        onClose: onClose
                    )
                }
            }
            .scaleEffect(isClosing ? 0.9 : 1)
            .opacity(isClosing ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: isClosing)
            .onAppear {
                currentPageIndex = 0 // 每次出现时重置到第一页
                filterText = "" // 清空搜索框
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
        eventObserver = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
            let now = Date()
            if now.timeIntervalSince(lastScrollTimestamp) < scrollCooldown {
                return event
            }
            
            let scrollThreshold: CGFloat = 3
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
    
    private func closeApp() {
        withAnimation(.easeIn(duration: 0.3)) {
            isClosing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onClose() // 调用回调而不是直接退出
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
            TextField("搜索应用...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                    )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .frame(width: 300)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
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
    @State private var launchingAppID: UUID?
    @State private var isClosing = false
    let onClose: () -> Void
    
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
                        AppIconView(
                            app: app,
                            layoutMetrics: LayoutMetrics(
                                horizontalPadding: 0,
                                verticalPadding: 0,
                                spacing: 20,
                                cellSize: 100,
                                iconSize: 60,
                                fontSize: 12
                            ),
                            isLaunching: launchingAppID == app.id,
                            onTap: {
                                launchApp(app)
                            }
                        )
                    }
                }
                .padding(.horizontal, 50)
                .padding(.vertical, 40)
            }
            .scaleEffect(isClosing ? 0.9 : 1)
            .opacity(isClosing ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: isClosing)
        }
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
