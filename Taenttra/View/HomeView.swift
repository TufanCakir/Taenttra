    //
    //  HomeView.swift
    //  Taenttra
    //
    //  Created by Tufan Cakir on 14.02.26.
    //

    import SwiftUI

    struct HomeView: View {
        
        @StateObject private var stageVM = StageViewModel()
        @StateObject private var viewModel = WorldViewModel()
        
        @State private var battleLevel: Level?
        @State private var selectedIsland: Island?
        @State private var selectedTab: FooterTab?
        
        var body: some View {
            ZStack {
                backgroundLayer
                islandsLayer
            }
            .safeAreaInset(edge: .bottom) {
                bottomUILayer
            }
            .fullScreenCover(item: $battleLevel) { level in
                BattleView(level: level)
            }
        }
        
        private var bottomUILayer: some View {
            VStack {
                
                stageFooter
                
                FooterView(selectedTab: $selectedTab)
            }
        }
        
        
        // MARK: - Layers
        
        @ViewBuilder
        private var backgroundLayer: some View {
            if let dimension = viewModel.currentDimension {
                Image(dimension.background)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .onTapGesture {
                        selectedIsland = nil
                    }
            }
        }
        
        private var islandsLayer: some View {
            GeometryReader { geo in
                
                let islands = viewModel.currentDimension?.islands ?? []
                
                ForEach(islands) { island in
                    
                    let islandSize = geo.size.width * 0.32
                    
                    let unlocked = viewModel.currentDimension.map {
                        stageVM.isIslandUnlocked(island, in: $0)
                    } ?? false
                    
                    ZStack {
                        Image(island.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: islandSize)
                            .opacity(unlocked ? 1 : 0.4)
                        
                        if selectedIsland?.id == island.id {
                            levelOverlay(for: island, size: islandSize)
                        }
                    }
                    .position(
                        x: geo.size.width * island.x,
                        y: geo.size.height * island.y
                    )
                    .onTapGesture {
                        if unlocked {
                            withAnimation(.easeInOut) {
                                selectedIsland = island
                            }
                        }
                    }
                }
            }
        }
        
        private func levelOverlay(for island: Island, size: CGFloat) -> some View {
            
            GeometryReader { geo in
                ForEach(island.levels) { level in
                    
                    let unlocked = stageVM.isLevelUnlocked(level)
                    
                    VStack(spacing: 4) {
                        
                        Circle()
                            .fill(unlocked ? Color.green : Color.gray)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(level.number)")
                                    .foregroundColor(.white)
                                    .font(.caption2)
                                    .bold()
                            )
                        
                        if unlocked {
                            Text("Battle")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(6)
                        }
                    }
                    .position(
                        x: geo.size.width * level.x,
                        y: geo.size.height * level.y
                    )
                    .onTapGesture {
                        if unlocked {
                            battleLevel = level
                        }
                    }
                }
            }
            .frame(width: size, height: size)
        }
        
        @ViewBuilder
        private var stageFooter: some View {
            if let dimension = viewModel.currentDimension {

                let currentStage = stageVM.currentUnlockedStage(in: dimension)

                HStack {
                    HStack(spacing: 8) {

                        ForEach(dimension.stages) { stage in

                            let unlocked = stage.id <= currentStage
                            let isCurrent = stage.id == currentStage

                            ZStack {

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        isCurrent
                                        ? Color.blue
                                        : unlocked
                                            ? Color.blue.opacity(0.6)
                                            : Color.gray.opacity(0.3)
                                    )
                                    .frame(width: 34, height: 34)

                                if unlocked {
                                    Text("\(stage.id)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                    }

                    Spacer() // 👈 DAS ist der Trick
                }
           
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.1, blue: 0.22),
                            Color(red: 0.02, green: 0.05, blue: 0.15)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }

    #Preview {
        HomeView()
            .environmentObject(NavigationState())
    }
