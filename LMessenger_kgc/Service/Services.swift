//
//  Services.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import Foundation

protocol ServicesType {
    var authService: AuthenticationServiceType { get set }
    var userService: UserServiceType { get set }
}

class Services: ServicesType {
    var authService: AuthenticationServiceType
    var userService: any UserServiceType
    
    init() {
        self.authService = AuthenticationService()
        self.userService = UserService(dbRepository: UserDBRepository())
    }
}

class StubService: ServicesType {
    var authService: any AuthenticationServiceType = StubAuthenticationService()
    var userService: any UserServiceType = StubUserService()
    
}

