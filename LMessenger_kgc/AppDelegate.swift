//
//  AppDelegate.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/4/24.
//

import UIKit // UIKit 프레임워크를 가져옵니다. UIKit은 iOS 앱의 사용자 인터페이스를 구성하는 데 사용됩니다.
import FirebaseCore // FirebaseCore 모듈을 가져옵니다. 이는 Firebase를 초기화하는 데 필요합니다.
import FirebaseAuth // FirebaseAuth 모듈을 가져옵니다. 이는 Firebase 인증 기능을 사용하기 위해 필요합니다.
import GoogleSignIn // GoogleSignIn 모듈을 가져옵니다. 이는 Google 로그인 기능을 사용하기 위해 필요합니다.

class AppDelegate: NSObject, UIApplicationDelegate { // AppDelegate 클래스를 정의하고, NSObject 및 UIApplicationDelegate 프로토콜을 따릅니다.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 앱이 실행되고 초기화가 완료된 후 호출되는 메서드입니다. launchOptions는 앱이 시작될 때 전달된 옵션입니다.
        FirebaseApp.configure() // Firebase를 초기화합니다.
        
        return true // 초기화가 성공적으로 완료되었음을 나타냅니다.
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // 앱이 다른 앱에서 URL을 통해 열릴 때 호출되는 메서드입니다.
      return GIDSignIn.sharedInstance.handle(url) // GoogleSignIn 인스턴스를 통해 URL을 처리하고 성공 여부를 반환합니다.
    }
}
