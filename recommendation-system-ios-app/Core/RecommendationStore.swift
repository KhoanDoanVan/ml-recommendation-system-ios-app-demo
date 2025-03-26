//
//  RecommendationStore.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//

import Foundation
import TabularData

#if canImport(CreateML)
import CreateML
#endif

// y = w_1x_1 + w_2x_2 + … + w_nx_n + b

final class RecommendationStore {
    
    
    private let queue = DispatchQueue(
        label: "com.recommendation-service.queue",
        qos: .userInitiated
    )
    
    
    func computeRecommendations(basedOn items: [FavouriteWrapper<Shirt>]) async throws -> [Shirt] {
        
        return try await withCheckedThrowingContinuation { continuation in
            
            queue.async {
                #if targetEnvironment(simulator)
                continuation.resume(
                    throwing: NSError(
                        domain: "Simulator not supported",
                        code: -1
                    )
                )
                
                #else
                
                /// Training data
                let trainingData = items.filter {
                    $0.isFavourite != nil
                }
                let trainingDataFrame = self.dataFrame(for: trainingData)
                
                /// Test data
                let testData = items
                let testDataFrame = self.dataFrame(for: testData)
                
                
                do {
                    
                    /// Regressor
                    let regressor = try MLLinearRegressor (
                        trainingData: trainingDataFrame,
                        targetColumn: "favorite"
                    )
                    
                    /// Predictions Column
                    let predictionsColumn = (try regressor.predictions(from: testDataFrame))
                        .compactMap { value in
                            value as? Double
                        }
                    
                    
                    /// Sort: create a sequence of pairs built out of two underlying sequences
                    let sorted = zip(testData, predictionsColumn)
                        .sorted { lhs, rhs -> Bool in
                            lhs.1 > rhs.1
                        }
                        .filter {
                            $0.1 > 0
                        }
                        .prefix(10) /// the first 10 items
                    
                    
                    /// Return result
                    let result = sorted.map(\.0.model)
                    continuation.resume(returning: result)
                    
                    
                } catch {
                    continuation.resume(throwing: error)
                }
                
                #endif
            }
            
            
        }
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
