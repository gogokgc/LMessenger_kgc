//
//  UserService.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/10/24.
//

import Foundation
import Combine

protocol UserServiceType {
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> // addUser 메서드를 정의합니다. 이 메서드는 User 객체를 받아서 AnyPublisher<User, ServiceError>를 반환합니다.
    func getUser(userId: String) -> AnyPublisher<User, ServiceError>
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError>
}

class UserService: UserServiceType {
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> { // addUser 메서드를 구현합니다. 이 메서드는 User 객체를 받아서 AnyPublisher<User, ServiceError>를 반환합니다.
        dbRepository.addUser(user.toObject()) // dbRepository의 addUser 메서드를 호출합니다. 이 메서드는 내부적으로 User 객체를 데이터베이스 객체로 변환하여 저장합니다.
            .map { user } // 반환된 결과를 map 연산자를 사용하여 원래의 User 객체로 변환합니다.
            .mapError { .error($0) } // 오류를 ServiceError 타입으로 매핑합니다.
            .eraseToAnyPublisher() // 퍼블리셔를 AnyPublisher 타입으로 변환하여 반환합니다.
    }
    
    func getUser(userId: String) -> AnyPublisher<User, ServiceError> {
        dbRepository.getUser(userId: userId)
            .map { $0.toModel()}
            .mapError{ .error($0)}
            .eraseToAnyPublisher()
    }
    
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError> {
        dbRepository.loadUsers()
            .map { $0
                .map { $0.toModel() }
                .filter { $0.id != id }
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    private var dbRepository: UserDBRepositoryType // dbRepository는 UserDBRepositoryType 프로토콜을 준수하는 객체입니다.
    
    init(dbRepository: UserDBRepositoryType) {
        self.dbRepository = dbRepository // 생성자에서 dbRepository를 초기화합니다.
    }
}


class StubUserService: UserServiceType {
    
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError> {
        Just([.stub1, .stub2]).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
}
