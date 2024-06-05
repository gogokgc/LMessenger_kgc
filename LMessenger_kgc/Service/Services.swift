//
//  Services.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import Foundation

protocol ServicesType {
    var authService: AuthenticationServiceType { get set }
}

class Services: ServicesType {
    var authService: AuthenticationServiceType
    
    init() {
        self.authService = AuthenticationService()
    }
}

class StubService: ServicesType {
    var authService: any AuthenticationServiceType = StubAuthenticationService()
    
}

