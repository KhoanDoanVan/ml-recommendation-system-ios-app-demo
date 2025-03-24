//
//  ContentView.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//

import SwiftUI

struct ContentView: View {
    
    
    @StateObject private var viewModel: MainViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: MainViewModel())
    }
    
    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    SectionTitleView(text: "Swipe to Like or Dislike")
                    
                    
                    if viewModel.shirts.isEmpty {
                        HStack {
                            
                            Spacer()
                            
                            VStack {
                                Text("All Done!")
                                    .multilineTextAlignment(.center)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                
                                Button("Try Again") {
                                    withAnimation {
                                        viewModel.resetUserChoices()
                                    }
                                }
                                .font(.headline)
                                .buttonStyle(.borderedProminent)
                            }
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 32)
                    } else {
                        
                        
                        CardsStackView(models: viewModel.shirts) { item, isLiked in
                            withAnimation(.spring()) {
                                viewModel.didRemove(item, isLiked: isLiked)
                            }
                        }
                        .zIndex(1)
                        
                    }
                    
                    RecommendationsView(recommendations: viewModel.recommendations)
                    
                }
            }
            .navigationTitle("Tshirtinder!")
            .task {
                await viewModel.loadAllShirts()
            }
        }
    }
}

#Preview {
    ContentView()
}
