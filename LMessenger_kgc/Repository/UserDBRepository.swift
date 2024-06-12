//
//  UserDBRepository.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/10/24.
//

import Foundation
import Combine
import FirebaseDatabase

protocol UserDBRepositoryType {
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> // addUser 메서드를 정의합니다.
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> // getUser 메서드를 정의합니다.
}

class UserDBRepository: UserDBRepositoryType {
    
    var db: DatabaseReference = Database.database().reference() // Firebase 실시간 데이터베이스의 참조를 초기화합니다.
    
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> { // addUser 메서드를 구현합니다. 이 메서드는 UserObject를 받아서 AnyPublisher<Void, DBError>를 반환합니다.
        Just(object) // UserObject를 방출하는 Just 퍼블리셔를 생성합니다.
            .compactMap { try? JSONEncoder().encode($0) } // UserObject를 JSON 데이터로 인코딩합니다. 실패하면 nil을 반환합니다.
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) } // JSON 데이터를 JSON 객체로 변환합니다. 실패하면 nil을 반환합니다.
            .flatMap { value in // 값을 사용하여 새로운 퍼블리셔를 생성합니다.
                Future<Void, Error> { [weak self] promise in // 비동기 작업을 처리하기 위해 Future 퍼블리셔를 생성합니다.
                    self?.db.child(DBKey.Users).child(object.id).setValue(value) { error, _ in // Firebase 데이터베이스에 값을 설정합니다.
                        if let error {
                            promise(.failure(error)) // 오류가 발생하면 promise를 실패로 설정합니다.
                        } else {
                            promise(.success(())) // 성공하면 promise를 성공으로 설정합니다.
                        }
                    }
                }
            }
            .mapError { DBError.error($0) } // Error 타입을 DBError 타입으로 변환합니다.
            .eraseToAnyPublisher() // 퍼블리셔를 AnyPublisher<Void, DBError> 타입으로 변환합니다.
    }
    
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> { // getUser 메서드를 구현합니다. 이 메서드는 사용자 ID를 받아서 AnyPublisher<UserObject, DBError>를 반환합니다.
        Future<Any?, DBError> { [weak self] promise in // 비동기 작업을 처리하기 위해 Future 퍼블리셔를 생성합니다.
            self?.db.child(DBKey.Users).child(userId).getData { error, snapshot in // Firebase 데이터베이스에서 데이터를 가져옵니다.
                if let error {
                    promise(.failure(DBError.error(error))) // 오류가 발생하면 promise를 실패로 설정합니다.
                } else if snapshot?.value is NSNull {
                    promise(.success(nil)) // 데이터가 없으면 nil을 반환합니다.
                } else {
                    promise(.success(snapshot?.value)) // 데이터를 성공적으로 가져오면 promise를 성공으로 설정합니다.
                }
            }
        }.flatMap { value in // 가져온 데이터를 flatMap으로 변환합니다.
            if let value {
                return Just(value) // 데이터를 방출하는 Just 퍼블리셔를 생성합니다.
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) } // JSON 객체를 JSON 데이터로 변환합니다. 실패하면 오류를 던집니다.
                    .decode(type: UserObject.self, decoder: JSONDecoder()) // JSON 데이터를 UserObject로 디코딩합니다.
                    .mapError { DBError.error($0) } // Error 타입을 DBError 타입으로 변환합니다.
                    .eraseToAnyPublisher() // 퍼블리셔를 AnyPublisher<UserObject, DBError> 타입으로 변환합니다.
            } else {
                return Fail(error: .emptyValue).eraseToAnyPublisher() // 값이 없으면 실패하는 퍼블리셔를 반환합니다.
            }
        }
        .eraseToAnyPublisher() // 최종 퍼블리셔를 AnyPublisher<UserObject, DBError> 타입으로 변환합니다.
    }
}

