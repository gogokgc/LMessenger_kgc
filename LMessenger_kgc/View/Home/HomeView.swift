//
//  HomeView.swift
//  LMessenger_kgc
//
//  Created by KYUCHEOL KIM on 6/8/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel // HomeViewModel 인스턴스를 상태 객체로 선언합니다.
    
    var body: some View {
        NavigationStack {
            contentView
                .fullScreenCover(item: $viewModel.modalDestination) {
                    switch $0 {
                    case .myProfile:
                        MyProfileView()
                        
                    case let .otherProfile(userId):
                        OtherProfileView()
                    }
                }
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        switch viewModel.phase {
        case .notRequested:
            PlaceHolderView()
                .onAppear {
                    viewModel.send(action: .load) // 뷰가 나타날 때 사용자 정보를 가져오는 액션을 실행합니다.
                }
        case .loading:
            LoadingView()
        case .success:
            loadedView
                .toolbar {
                    Image("bookmark") // 북마크 이미지 아이콘을 추가합니다.
                    Image("notifications") // 알림 이미지 아이콘을 추가합니다.
                    Image("person_add") // 친구 추가 이미지 아이콘을 추가합니다.
                    Button {
                        // viewModel.send(action: .presentView(.setting)) // 설정 화면을 표시하는 액션 (주석 처리됨)
                    } label: {
                        Image("settings", label: Text("설정")) // 설정 버튼을 추가하고 레이블을 설정합니다.
                    }
                }
        case .fail:
            ErrorView()
        }
    }
    
    var loadedView: some View {
        ScrollView {
            profileView
                .padding(.bottom, 30) // 프로필 뷰를 추가하고 아래쪽 패딩을 설정합니다.
            
            searchButton
                .padding(.bottom, 24) // 검색 버튼을 추가하고 아래쪽 패딩을 설정합니다.
            
            HStack {
                Text("친구")
                    .font(.system(size: 14)) // 텍스트의 폰트 크기를 설정합니다.
                    .foregroundColor(.bkText) // 텍스트의 색상을 설정합니다.
                
                Spacer()
            }
            .padding(.horizontal, 30) // 수평 패딩을 설정합니다.
            
            if viewModel.users.isEmpty {
                Spacer(minLength: 89) // 최소 길이가 89인 Spacer를 추가합니다.
                emptyView // 사용자 목록이 비어있을 경우 표시할 emptyView를 추가합니다.
            } else {
                LazyVStack {
                    ForEach(viewModel.users, id: \.id) { user in // 사용자 목록을 순회하며 사용자 정보를 표시합니다.
                        Button {
                            viewModel.send(action: .presentOtherprofileView(user.id))
                        } label: {
                            HStack(spacing: 8) {
                                Image("person")
                                    .resizable()
                                    .frame(width: 40, height: 40) // 이미지의 크기를 설정합니다.
                                    .clipShape(Circle()) // 이미지를 원형으로 자릅니다.
                                Text(user.name)
                                    .font(.system(size: 12)) // 텍스트의 폰트 크기를 설정합니다.
                                    .foregroundColor(.bkText) // 텍스트의 색상을 설정합니다.
                                Spacer()
                            }
                            .padding(.horizontal, 30) // 수평 패딩을 설정합니다.
                        }
                    }
                }
            }
        }
    }
    
    var profileView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.myUser?.name ?? "이름")
                    .font(.system(size: 22, weight: .bold)) // 텍스트의 폰트 크기와 굵기를 설정합니다.
                    .foregroundColor(.bkText) // 텍스트의 색상을 설정합니다.
                Text(viewModel.myUser?.description ?? "상태 메시지 입력")
                    .font(.system(size: 12)) // 텍스트의 폰트 크기를 설정합니다.
                    .foregroundColor(.greyDeep) // 텍스트의 색상을 설정합니다.
            }
            
            Spacer()
            
            Image("person")
                .resizable()
                .frame(width: 52, height: 52) // 이미지의 크기를 설정합니다.
                .clipShape(Circle()) // 이미지를 원형으로 자릅니다.
        }
        .padding(.horizontal, 30) // 수평 패딩을 설정합니다.
        .onTapGesture {
            viewModel.send(action: .presentMyProfileView)
        }
    }
    
    var searchButton: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear) // 배경색을 투명하게 설정합니다.
                .frame(height: 36) // 높이를 설정합니다.
                .background(Color.greyCool) // 배경색을 설정합니다.
                .cornerRadius(5) // 모서리를 둥글게 설정합니다.
            
            HStack {
                Text("검색")
                    .font(.system(size: 12)) // 텍스트의 폰트 크기를 설정합니다.
                    .foregroundColor(.greyLightVer2) // 텍스트의 색상을 설정합니다.
                Spacer()
            }
            .padding(.leading, 22) // 왼쪽 패딩을 설정합니다.
        }
        .padding(.horizontal, 30) // 수평 패딩을 설정합니다.
    }
    
    var emptyView: some View {
        VStack {
            VStack(spacing: 3) {
                Text("친구를 추가해 보세요.")
                    .foregroundColor(.bkText) // 텍스트의 색상을 설정합니다.
                Text("큐알코드나 검색을 이용해서 친구를 추가해보세요.")
                    .foregroundColor(.greyDeep) // 텍스트의 색상을 설정합니다.
            }
            .font(.system(size: 14)) // 텍스트의 폰트 크기를 설정합니다.
            .padding(.bottom, 30) // 아래쪽 패딩을 설정합니다.
            
            Button {
                viewModel.send(action: .requestContacts)
            } label: {
                Text("친구추가")
                    .font(.system(size: 14)) // 텍스트의 폰트 크기를 설정합니다.
                    .foregroundColor(.bkText) // 텍스트의 색상을 설정합니다.
                    .padding(.vertical, 9) // 수직 패딩을 설정합니다.
                    .padding(.horizontal, 24) // 수평 패딩을 설정합니다.
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5) // 버튼을 둥근 사각형으로 설정합니다.
                    .stroke(Color.greyLight) // 외곽선을 설정합니다.
            }
        }
    }
}

#Preview {
    HomeView(viewModel: .init(container: .init(services: StubService()), userId: "user1_id")) // 미리보기에서 사용할 뷰를 초기화합니다.
}
