//
//  AuthenticationViewModel.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/2/24.
//

import Foundation // Foundation 프레임워크를 가져옵니다. 이는 기본 데이터 타입과 컬렉션을 제공합니다.
import Combine // Combine 프레임워크를 가져옵니다. 이는 선언형 Swift API를 사용하여 비동기 이벤트를 처리하는 데 사용됩니다.
import AuthenticationServices // AuthenticationServices 프레임워크를 가져옵니다. 이는 Apple ID 인증 서비스를 사용하기 위해 필요합니다.

enum AuthenticationState { // AuthenticationState라는 열거형을 정의합니다.
    case unauthenticated // 인증되지 않은 상태를 나타냅니다.
    case authenticated // 인증된 상태를 나타냅니다.
}

class AuthenticationViewModel: ObservableObject { // AuthenticationViewModel 클래스를 정의하고, ObservableObject 프로토콜을 따릅니다.
    
    enum Action { // Action이라는 열거형을 정의합니다.
        case checkAuthenticationState // 인증 상태를 확인하는 동작을 나타냅니다.
        case googleLogin // Google 로그인을 시도하는 동작을 나타냅니다.
        case appleLogin(ASAuthorizationAppleIDRequest) // Apple 로그인을 시도하는 동작을 나타냅니다. 매개변수로 ASAuthorizationAppleIDRequest를 받습니다.
        case appleLoginCompletion(Result<ASAuthorization, Error>) // Apple 로그인 완료 시 호출되는 동작을 나타냅니다. 매개변수로 Result<ASAuthorization, Error>를 받습니다.
        case logout // 로그아웃 동작을 나타냅니다.
    }
    
    @Published var authenticationState: AuthenticationState = .unauthenticated // 인증 상태를 나타내는 Published 변수를 정의합니다. 초기값은 unauthenticated입니다.
    @Published var isLoading = false // 로딩 상태를 나타내는 Published 변수를 정의합니다. 초기값은 false입니다.
    
    var userId: String? // 사용자 ID를 저장하는 변수입니다.
    
    private var currentNonce: String? // 현재 nonce 값을 저장하는 변수입니다.
    private var container: DIContainer // 종속성 주입 컨테이너를 저장하는 변수입니다.
    private var subscriptions = Set<AnyCancellable>() // 구독을 저장하는 Set입니다.
    
    init(container: DIContainer) { // DIContainer를 매개변수로 받아 초기화하는 생성자입니다.
        self.container = container
    }
    
    func send(action: Action) { // Action을 매개변수로 받아 처리하는 메서드입니다.
        switch action { // 액션 타입에 따라 다르게 처리합니다.
        case .checkAuthenticationState: // 인증 상태를 확인하는 경우
            if let userId = container.services.authService.checkAuthenticationState() { // authService에서 인증 상태를 확인합니다.
                self.userId = userId // userId를 설정합니다.
                self.authenticationState = .authenticated // 인증 상태를 authenticated로 설정합니다.
            }
            
        case .googleLogin: // Google 로그인을 시도하는 경우
            isLoading = true // 로딩 상태를 true로 설정합니다.
            
            container.services.authService.signInWithGoogle() // Google 로그인 시도합니다.
                .flatMap { user in // 로그인 성공 시, 사용자 정보를 받아옵니다.
                    self.container.services.userService.addUser(user) // 받은 사용자 정보를 이용해 UserService에 사용자를 추가합니다.
                }
                .sink { [weak self] completion in // 비동기 작업의 완료를 처리합니다.
                    if case .failure = completion { // 실패한 경우
                        self?.isLoading = false // 로딩 상태를 false로 설정합니다.
                    }
                } receiveValue: { [weak self] user in // 성공한 경우 사용자 정보를 받습니다.
                    self?.isLoading = false // 로딩 상태를 false로 설정합니다.
                    self?.userId = user.id // userId를 설정합니다.
                    self?.authenticationState = .authenticated // 인증 상태를 authenticated로 설정합니다.
                }.store(in: &subscriptions) // 구독을 저장합니다.
            
        case let .appleLogin(request): // Apple 로그인을 시도하는 경우
            let nonce = container.services.authService.handleSignInWithAppleRequest(request) // Apple 로그인 요청을 처리하고 nonce를 생성합니다.
            currentNonce = nonce // nonce를 저장합니다.
             
        case let .appleLoginCompletion(result): // Apple 로그인 완료 시 호출되는 경우
            if case let .success(authorization) = result { // 성공한 경우
                guard let nonce = currentNonce else { return } // nonce가 존재하는지 확인합니다.
                
                container.services.authService.handleSignInWithAppleCompletion(authorization, none: nonce) // Apple 로그인 완료를 처리합니다.
                    .flatMap { user in // 로그인 성공 시, 사용자 정보를 받아옵니다.
                        self.container.services.userService.addUser(user) // 받은 사용자 정보를 이용해 UserService에 사용자를 추가합니다.
                    }
                    .sink { [weak self] completion in // 비동기 작업의 완료를 처리합니다.
                        if case .failure = completion { // 실패한 경우
                            self?.isLoading = false // 로딩 상태를 false로 설정합니다.
                        }
                    } receiveValue: { [weak self] user in // 성공한 경우 사용자 정보를 받습니다.
                        self?.isLoading = false // 로딩 상태를 false로 설정합니다.
                        self?.userId = user.id // userId를 설정합니다.
                        self?.authenticationState = .authenticated // 인증 상태를 authenticated로 설정합니다.
                    }.store(in: &subscriptions) // 구독을 저장합니다.
                
            } else if case let .failure(error) = result { // 실패한 경우
                isLoading = false // 로딩 상태를 false로 설정합니다.
                print(error.localizedDescription) // 에러를 출력합니다.
            }
            
        case .logout: // 로그아웃을 시도하는 경우
            container.services.authService.logout() // 로그아웃을 시도합니다.
                .sink { completion in // 비동기 작업의 완료를 처리합니다.
                    
                } receiveValue: { [weak self] _ in // 성공한 경우
                    self?.authenticationState = .unauthenticated // 인증 상태를 unauthenticated로 설정합니다.
                    self?.userId = nil // userId를 nil로 설정합니다.
                }.store(in: &subscriptions) // 구독을 저장합니다.

        }
    }
}
