//
//  LaunchAnimationView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/8.
//

import SwiftUI

struct LaunchAnimationView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            VStack(spacing: 20) {
                Image(systemName: "app.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))
                
                Text("Simple Launchpad")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.2
                opacity = 1
            }
            
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: true)) {
                rotation = 10
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    scale = 1.0
                }
            }
        }
    }
}
