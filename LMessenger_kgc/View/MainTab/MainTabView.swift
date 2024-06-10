//
//  MainTabView.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/5/24.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTabType = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .home:
//                        HomeView(viewModel: .init(container: container, userId: authViewModel.userId ?? ""))
                        HomeView(viewModel: .init())
                    case .chat:
//                        ChatListView(viewModel: .init(container: container, userId: authViewModel.userId ?? ""))
                        ChatListView()
                    case .phone:
                        Color.blackFix
                    }
                }
                .tabItem {
                    Label(tab.title, image: tab.imageName(selected: selectedTab == tab))
                }
                .tag(tab)
            }
        }
        .tint(.bkText)
    }
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.bkText)
    }
}

#Preview {
    MainTabView()
}
