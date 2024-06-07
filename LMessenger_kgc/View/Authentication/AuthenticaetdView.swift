//
//  AuthenticaetdView.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import SwiftUI

struct AuthenticaetdView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        switch authViewModel.authenticationState {
        case .unauthenticated:
            LoginIntroView()
        case .authenticated:
            MainTabView()
        }
    }
}
#Preview {
    AuthenticaetdView(authViewModel: .init(container: .init(services: StubService())))
}
