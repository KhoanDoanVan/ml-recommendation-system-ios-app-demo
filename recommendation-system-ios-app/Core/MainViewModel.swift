//
//  MainViewModel.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//

import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    
    // MARK: - Properties
    private var allShirts: [FavouriteWrapper<Shirt>] = []
    @Published private(set) var shirts: [Shirt] = []
    @Published private(set) var recommendations: [Shirt] = []
    
    
    private var recommendationsTask: Task<Void, Never>?
    
    private let recommendationStore: RecommendationStore
    
    // MARK: - Init
    init(recommendationStore: RecommendationStore = RecommendationStore()) {
        self.recommendationStore = recommendationStore
    }
    
    
    // MARK: - Methods
    func loadAllShirts() async {
        guard let url = Bundle.main.url(forResource: "shirts", withExtension: "json") else {
            return
        }
        
        do {
            
            let data = try Data(contentsOf: url)
            
            allShirts = (try JSONDecoder().decode([Shirt].self, from: data)).shuffled().map {
                FavouriteWrapper(model: $0)
            }
            
            shirts = allShirts.map(\.model)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func didRemove(_ item: Shirt, isLiked: Bool) {
        shirts.removeAll { $0.id == item.id }
        
        if let index = allShirts.firstIndex(where: { $0.model.id == item.id }) {
            allShirts[index] = FavouriteWrapper(model: item, isFavourite: isLiked)
        }
        
        
        /// Cancel any ongoing computation task since the user may swipe quickly.
        recommendationsTask?.cancel()
        
        
        recommendationsTask = Task {
            
            do {
                let result = try await recommendationStore.computeRecommendations(basedOn: allShirts)
                
                /// Check for the canceled task, because by the time the result is ready, you might have canceled it.
                if !Task.isCancelled {
                    recommendations = result
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    func resetUserChoices() {
        shirts = allShirts.map(\.model)
        recommendations = []
    }
}
