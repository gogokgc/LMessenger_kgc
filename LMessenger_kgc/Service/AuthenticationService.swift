//
//  AuthenticationService.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/5/24.
//

// 필요한 프레임워크를 가져옵니다.
import Foundation // 기본적인 Foundation 프레임워크를 가져옵니다.
import Combine // 비동기 작업 처리를 위한 Combine 프레임워크를 가져옵니다.
import FirebaseCore // Firebase의 코어 기능을 가져옵니다.
import FirebaseAuth // Firebase 인증 기능을 가져옵니다.
import GoogleSignIn // 구글 로그인을 위한 GoogleSignIn 프레임워크를 가져옵니다.
import AuthenticationServices // 애플 로그인 기능을 위한 AuthenticationServices 프레임워크를 가져옵니다.

// 인증 오류를 정의하는 열거형입니다.
enum AuthenticationError: Error {
    case clientIDError // 클라이언트 ID 오류
    case tokenError // 토큰 오류
    case invalidated // 인증 무효화 오류
}

// 인증 서비스 프로토콜을 정의합니다.
protocol AuthenticationServiceType {
    func checkAuthenticationState() -> String? // 인증 상태를 확인하는 함수입니다.
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> // 구글 로그인을 처리하는 함수입니다.
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String // 애플 로그인 요청을 처리하는 함수입니다.
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<User, ServiceError> // 애플 로그인 완료를 처리하는 함수입니다.
    func logout() -> AnyPublisher<Void, ServiceError> // 로그아웃을 처리하는 함수입니다.
}

// 인증 서비스를 구현하는 클래스입니다.
class AuthenticationService: AuthenticationServiceType {
    
    // 현재 인증 상태를 확인하는 함수입니다.
    func checkAuthenticationState() -> String? {
        if let user = Auth.auth().currentUser { // Firebase로부터 현재 인증된 사용자를 가져옵니다.
            return user.uid // 현재 사용자가 있으면 사용자 ID를 반환합니다.
        } else {
            return nil // 현재 사용자가 없으면 nil을 반환합니다.
        }
    }
    
    // 구글 로그인을 처리하는 함수입니다.
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in // 비동기 작업을 처리하기 위해 Future를 사용합니다.
            self?.signInWithGoogle { result in // 내부 signInWithGoogle 함수를 호출합니다.
                switch result {
                case let .success(user): // 로그인이 성공하면
                    promise(.success(user)) // 성공 결과를 promise에 전달합니다.
                case let .failure(error): // 로그인이 실패하면
                    promise(.failure(.error(error))) // 실패 결과를 promise에 전달합니다.
                }
            }
        }.eraseToAnyPublisher() // AnyPublisher 타입으로 변환합니다.
    }
    
    // 애플 로그인 요청을 처리하는 함수입니다.
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email] // 애플 ID 요청에 필요한 범위를 설정합니다.
        let nonce = randomNonceString() // 난수를 생성합니다.
        request.nonce = sha256(nonce) // 생성된 난수를 해시 값으로 설정합니다.
        return nonce // 난수를 반환합니다.
    }
    
    // 애플 로그인 완료를 처리하는 함수입니다.
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in // 비동기 작업을 처리하기 위해 Future를 사용합니다.
            self?.handleSignInWithAppleCompletion(authorization, nonce: none) { result in // 내부 handleSignInWithAppleCompletion 함수를 호출합니다.
                switch result {
                case let .success(user): // 로그인이 성공하면
                    promise(.success(user)) // 성공 결과를 promise에 전달합니다.
                case let .failure(error): // 로그인이 실패하면
                    promise(.failure(.error(error))) // 실패 결과를 promise에 전달합니다.
                }
            }
        }.eraseToAnyPublisher() // AnyPublisher 타입으로 변환합니다.
    }
    
    // 로그아웃을 처리하는 함수입니다.
    func logout() -> AnyPublisher<Void, ServiceError> {
        Future { promise in // 비동기 작업을 처리하기 위해 Future를 사용합니다.
            do {
                try Auth.auth().signOut() // Firebase 인증에서 로그아웃을 시도합니다.
                promise(.success(())) // 성공 결과를 promise에 전달합니다.
            } catch {
                promise(.failure(.error(error))) // 실패하면 오류를 promise에 전달합니다.
            }
        }.eraseToAnyPublisher() // AnyPublisher 타입으로 변환합니다.
    }
}

// AuthenticationService 클래스의 확장을 정의합니다.
extension AuthenticationService {
    // 구글 로그인을 처리하는 내부 함수입니다.
    private func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { // Firebase 앱의 클라이언트 ID를 가져옵니다.
            completion(.failure(AuthenticationError.clientIDError)) // 클라이언트 ID가 없으면 오류를 반환합니다.
            return
        }
        
        let config = GIDConfiguration(clientID: clientID) // 구글 로그인 구성을 설정합니다.
        GIDSignIn.sharedInstance.configuration = config // 구글 로그인 인스턴스에 구성을 설정합니다.
        
        // 현재 윈도우 씬, 윈도우, 루트 뷰 컨트롤러를 가져옵니다.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // 구글 로그인 인스턴스를 사용하여 로그인 프로세스를 시작합니다.
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error { // 오류가 발생하면
                completion(.failure(error)) // 오류를 반환합니다.
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { // 사용자의 토큰을 가져옵니다.
                completion(.failure(AuthenticationError.tokenError)) // 토큰을 가져오지 못하면 오류를 반환합니다.
                return
            }
            
            let accessToken = user.accessToken.tokenString // 액세스 토큰을 가져옵니다.
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken) // 구글 자격 증명을 생성합니다.
            
            self?.authenticateUserWithFirebase(credential: credential, completion: completion) // Firebase 인증을 처리합니다.
        }
    }
    
    // 애플 로그인 완료를 처리하는 내부 함수입니다.
    private func handleSignInWithAppleCompletion(_ authorization: ASAuthorization,
                                                 nonce: String,
                                                 completion: @escaping (Result<User, Error>) -> Void) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken else { // 애플 ID 자격 증명과 토큰을 가져옵니다.
            completion(.failure(AuthenticationError.tokenError)) // 토큰이 없으면 오류를 반환합니다.
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { // 토큰 문자열을 가져옵니다.
            completion(.failure(AuthenticationError.tokenError)) // 문자열로 변환하지 못하면 오류를 반환합니다.
            return
        }
        
        // 애플 자격 증명을 생성합니다.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        
        authenticateUserWithFirebase(credential: credential) { result in // Firebase 인증을 처리합니다.
            switch result {
            case var .success(user): // 성공적으로 로그인하면
                // 사용자의 이름을 설정합니다.
                user.name = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                completion(.success(user)) // 성공 결과를 반환합니다.
            case let .failure(error): // 실패하면
                completion(.failure(error)) // 오류를 반환합니다.
            }
        }
    }
    
    // Firebase 인증을 처리하는 내부 함수입니다.
    private func authenticateUserWithFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in // Firebase로 로그인 시도합니다.
            if let error = error { // 오류가 발생하면
                completion(.failure(error)) // 오류를 반환합니다.
                return
            }
            
            guard let result = result else { // 로그인 결과를 가져옵니다.
                completion(.failure(AuthenticationError.invalidated)) // 결과가 없으면 무효화 오류를 반환합니다.
                return
            }
            
            // Firebase 사용자 정보를 가져옵니다.
            let firebaseUser = result.user
            let user: User = .init(id: firebaseUser.uid,
                                   name: firebaseUser.displayName ?? "",
                                   phoneNumber: firebaseUser.phoneNumber,
                                   profileURL: firebaseUser.photoURL?.absoluteString)
            
            completion(.success(user)) // 성공 결과를 반환합니다.
        }
    }
}

// 테스트용 인증 서비스를 정의합니다.
class StubAuthenticationService: AuthenticationServiceType {
    func logout() -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher() // 로그아웃을 처리하는 빈 Publisher를 반환합니다.
    }
    
    func checkAuthenticationState() -> String? {
        return nil // 인증 상태를 확인하는 빈 함수를 반환합니다.
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        return "" // 애플 로그인 요청을 처리하는 빈 함수를 반환합니다.
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher() // 애플 로그인 완료를 처리하는 빈 Publisher를 반환합니다.
    }
    
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher() // 구글 로그인을 처리하는 빈 Publisher를 반환합니다.
    }
}
