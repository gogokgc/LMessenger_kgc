//
//  LMessenger_kgcApp.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import SwiftUI

@main // 애플리케이션의 진입점을 나타냅니다.
struct LMessenger_kgcApp: App { // LMessenger_kgcApp이라는 구조체를 정의하고, 이 구조체는 App 프로토콜을 따릅니다.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // AppDelegate를 사용하기 위해 델리게이트를 설정합니다.
    @StateObject var container: DIContainer = .init(services: Services()) // DIContainer라는 객체를 StateObject로 선언하고 초기화합니다. 이 객체는 서비스의 종속성 주입을 관리합니다.
    
    var body: some Scene { // body 프로퍼티는 하나 이상의 Scene을 반환합니다.
        WindowGroup { // 윈도우 그룹을 생성합니다. 이는 앱의 콘텐츠를 나타내는 장면입니다.
            AuthenticaetdView(authViewModel: .init(container: container)) // AuthenticaetdView를 생성하고, DIContainer를 사용하여 AuthViewModel을 초기화합니다.
                .environmentObject(container) // environmentObject 수식을 사용하여 DIContainer를 모든 하위 뷰에서 사용할 수 있게 설정합니다.
        }
    }
}
