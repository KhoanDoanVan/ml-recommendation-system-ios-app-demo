//
//  CardView.swift
//  recommendation-system-ios-app
//
//  Created by Đoàn Văn Khoan on 24/3/25.
//

import SwiftUI

struct CardView<Model>: View
where Model: TextImageProviding
{
    
    private enum Constants {
        static var swipeThreshold: CGFloat {
            0.25
        }
    }
    
    private enum SwipeStatus {
        case like
        case dislike
        case none
    }
    
    @State private var translation: CGSize = .zero
    @State private var swipeStatus: SwipeStatus = .none
    
    private let model: Model
    private let onRemove: (_ model: Model, _ isLiked: Bool) -> Void
    
    
    init(
        model: Model,
        onRemove: @escaping (_ model: Model, _ isLiked: Bool) -> Void = { _, _ in
            
        }
    ) {
        self.model = model
        self.onRemove = onRemove
    }
    
    
    var body: some View {
        
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 0) {
                
                Group {
                    if let image = model.image {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        Color(uiColor: .systemFill)
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: proxy.size.width,
                    alignment: .center
                )
                .clipped()
                .overlay(
                    alignment: swipeStatus == .like ? .topLeading : (swipeStatus == .dislike ? .topTrailing : .top)
                ) {
                    Image(
                        systemName: swipeStatus == .like ? "hand.thumbsup.circle" : (
                            swipeStatus == .dislike ? "hand.thumbsdown.circle" : "hand.raised.circle"
                        )
                    )
                    .resizable()
                    .imageScale(.large)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color(.systemBackground))
                    .padding(8)
                    .background(
                        Circle()
                            .background(.thinMaterial)
                    )
                    .clipShape(Circle())
                    .padding(8)
                    .opacity(swipeStatus == .none ? 0.0 : 1.0)
                }
                
                Text(model.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .minimumScaleFactor(0.7)
                    .layoutPriority(1)
            }
            .background(Color(uiColor: .tertiarySystemBackground))
            .cornerRadius(16.0)
            .shadow(radius: 6)
            .offset(
                x: translation.width,
                y: 0
            )
            .rotationEffect(
                .degrees(translation.width / proxy.size.width * 25.0),
                anchor: .bottom
            )
            .gesture(dragGesture(on: proxy))
        }
        
    }
    
    
    private func gestureFraction(
        in geometry: GeometryProxy,
        from gesture: DragGesture.Value
    ) -> CGFloat {
        gesture.translation.width / geometry.size.width
    }
    
    
    private func dragGesture(on geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                
                translation = value.translation
                
                switch gestureFraction(in: geometry, from: value) {
                    
                case ...(-Constants.swipeThreshold):
                    if swipeStatus != .dislike {
                        withAnimation(.spring()) {
                            swipeStatus = .dislike
                        }
                    }
                    
                case Constants.swipeThreshold...:
                    if swipeStatus != .like {
                        withAnimation(.spring()) {
                            swipeStatus = .like
                        }
                    }
                    
                default:
                    if swipeStatus != .none {
                        withAnimation(.spring()) {
                            swipeStatus = .none
                        }
                    }
                    
                }
                
                
            }
            .onEnded { value in
                if abs(gestureFraction(in: geometry, from: value)) > Constants.swipeThreshold {
                    
                    onRemove(model, swipeStatus == .like)
                    
                }
                
                withAnimation(.spring()) {
                    translation = .zero
                    swipeStatus = .none
                }
                
            }
    }
    
}


