//
//  SearchBarView.swift
//  SimpleLaunchpad
//
//  Created by laobamac on 2025/8/6.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("搜索", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .padding(.horizontal, 25)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.white)
                                    .padding(.trailing, 10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
                .animation(.default, value: searchText)
        }
        .padding(.horizontal, 10)
    }
}
