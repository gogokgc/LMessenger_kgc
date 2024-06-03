//
//  AuthenticaetdView.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import SwiftUI

struct AuthenticaetdView: View {
    @StateObject var authViewModel: AuthenticaetionViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    AuthenticaetdView(authViewModel: .init())
}
