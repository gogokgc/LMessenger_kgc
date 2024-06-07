//
//  AuthenticationViewModel.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import Foundation

enum AuthenticationState {
    case unauthenticated
    case authenticated
}

class AuthenticationViewModel: ObservableObject {
    
    enum Action {
        case googleLogin
    }
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    
    private var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}
