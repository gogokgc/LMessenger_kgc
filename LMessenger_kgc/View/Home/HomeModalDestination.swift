//
//  HomeModalDestination.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/14/24.
//

import Foundation

enum HomeModalDestination: Hashable, Identifiable {
    case myProfile
    case otherProfile(String)
//    case setting
    
    var id: Int {
        hashValue
    }
}
