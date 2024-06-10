//
//  HomeViewModel.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/8/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var myUser: User?
    @Published var users: [User] = [.stub1, .stub2]
}
