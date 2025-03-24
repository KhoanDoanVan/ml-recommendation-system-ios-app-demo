//
//  RecommendationsView.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//


import SwiftUI

struct RecommendationsView<Model>: View
where Model: TextImageProviding & Hashable & Identifiable
{
    
    let recommendations: [Model]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            SectionTitleView(text: "Recommendations")
            
            if !recommendations.isEmpty {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    LazyHStack(alignment: .center, spacing: 12.0) {
                        ForEach(recommendations) { item in
                            SmallCardView(model: item)
                        }
                    }
                    .padding(.horizontal)
                }
                
            } else {
                
                HStack {
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "tshirt.fill")
                            .imageScale(.large)
                            .font(.title3)
                        
                        Text("Nothing yet!")
                            .multilineTextAlignment(.center)
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 32)
                
            }
            
        }
        
    }
}
