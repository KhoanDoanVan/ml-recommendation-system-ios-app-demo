//
//  RecommendationStore.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//

import Foundation
import TabularData


final class RecommendationStore {
    
    
    func computeRecommendations(basedOn items: [FavouriteWrapper<Shirt>]) async throws -> [Shirt] {
        return []
    }
    
    
    private func dataFrame(for data: [FavouriteWrapper<Shirt>]) -> DataFrame {
        
        
        var dataFrame = DataFrame()
        
        /// Color
        dataFrame.append(
            column: Column(
                name: "color",
                contents: data.map(\.model.color.rawValue)
            )
        )
        
        /// Design
        dataFrame.append(
            column: Column(
                name: "design",
                contents: data.map(\.model.design.rawValue)
            )
        )
        
        /// Neck
        dataFrame.append(
            column: Column(
                name: "neck",
                contents: data.map(\.model.neck.rawValue)
            )
        )
        
        /// Sleeve
        dataFrame.append(
            column: Column(
                name: "sleeve",
                contents: data.map(\.model.sleeve.rawValue)
            )
        )
        
        /// Favourite
        dataFrame.append(
            column: Column<Int>(
                name: "favourite",
                contents: data.map {
                    
                    if let isFavourite = $0.isFavourite {
                        return isFavourite ? 1 : -1
                    } else {
                        return 0
                    }
                    
                }
            )
        )
        
        
        return dataFrame
    }
    
}
