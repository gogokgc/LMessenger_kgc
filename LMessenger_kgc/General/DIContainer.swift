//
//  DIContainer.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServicesType
    
    init(services: ServicesType) {
        self.services = services
    }
}
