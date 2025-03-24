//
//  SectionTitleView.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//

import SwiftUI

struct SectionTitleView: View {
    
    let text: LocalizedStringKey
    
    var body: some View {
        Text(text)
          .font(.title3)
          .fontWeight(.bold)
          .padding([.top, .horizontal])
    }
}

