//
//  HomeViewModel.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/8/24.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    enum Action {
        case load // 사용자 정보를 가져오는 액션을 정의합니다.
    }
    
    @Published var myUser: User? // myUser는 사용자 정보를 저장하는 옵셔널 User 객체입니다.
    @Published var users: [User] = [] // users는 User 객체의 배열로, 초기값은 빈 배열입니다.
    @Published var phase: Phase = .notRequested
    
    private var userId: String // 사용자 ID를 저장하는 변수입니다.
    private var container: DIContainer // 의존성 주입 컨테이너를 저장하는 변수입니다.
    private var subscriptions = Set<AnyCancellable>() // Combine의 구독을 관리하기 위한 Set입니다.
    
    init(container: DIContainer, userId: String) {
        self.container = container // 생성자에서 DIContainer를 초기화합니다.
        self.userId = userId // 생성자에서 userId를 초기화합니다.
    }
    
    func send(action: Action) {
        // 액션을 처리하는 메서드입니다.
        switch action {
        case .load:
            phase = .loading
            
            // getUser 액션이 호출된 경우
            container.services.userService.getUser(userId: userId) // UserService의 getUser 메서드를 호출하여 사용자 정보를 가져옵니다.
                .handleEvents(receiveOutput: { [weak self] user in // 중간 이벤트를 처리하기 위해 handleEvents를 사용합니다.
                    print("user : \(user)")
                    self?.myUser = user // 받아온 사용자 정보를 myUser 변수에 저장합니다.
                })
                .flatMap { [weak self] user -> AnyPublisher<[User], ServiceError> in // flatMap을 사용하여 새로운 퍼블리셔를 생성합니다.
                    guard let `self` = self else { return Empty().eraseToAnyPublisher() } // self가 nil인 경우 빈 퍼블리셔를 반환합니다.
                    return self.container.services.userService.loadUsers(id: user.id) // loadUsers 메서드를 호출하여 사용자 리스트를 가져옵니다.
                }
                .sink {  [weak self] completion in // 완료 시 호출됩니다.
                    if case .failure = completion {
                        self?.phase = .fail
                    }
                } receiveValue: { [weak self] user in // 사용자 정보를 성공적으로 받아올 경우 호출됩니다.
                    self?.phase = .success
                    self?.users = user // users 변수에 받아온 사용자 정보를 저장합니다.
                }
                .store(in: &subscriptions) // 구독을 저장하여 메모리에서 해제되지 않도록 합니다.
        }
    }
}

