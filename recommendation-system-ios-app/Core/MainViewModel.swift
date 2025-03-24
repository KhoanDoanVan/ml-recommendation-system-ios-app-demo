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
    }
    
    
    func resetUserChoices() {
        shirts = allShirts.map(\.model)
        recommendations = []
    }
}
