//
//  SearchShopList.swift
//  Bottles_V2
//
//  Created by 서찬호 on 2023/01/18.
//

import SwiftUI
import CoreLocation

struct SearchShopList: View {
    // 검색어를 저장하는 변수
    var shopName: String
    // ActionSheet
    @State private var showingActionSheet: Bool = false
    @State private var selection = "이름순"
    // 북마크 알림
    @State var bookMarkAlarm: Bool = false
    @State var bookMark: Bool = false
    
    // Server Data
    @EnvironmentObject var shopDataStore: ShopDataStore
    
    @State var destination: Destination?
    @Binding var root: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    // 정렬 기준 선택 버튼
                    Button {
                        showingActionSheet = true
                    } label: {
                        HStack {
                            Text("\(selection)")
                                .font(.bottles14)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(.black)
                    }
                    .padding(.trailing, 20)
                }

                // 검색어를 포함하는 Data가 없을 경우
                if shopDataStore.shopSearchResult(shopName: shopName).isEmpty {
                    Text("검색 결과가 없습니다.")
                        .font(.bottles14)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                    Spacer()
                } else {
                    // TODO: 서버 Shop 데이터 연결
                    ScrollView {
                        ForEach(shopDataStore.sortShopData(shopDataStore.shopSearchResult(shopName: shopName), selection: selection)) { shop in
                            NavigationLink(destination: {
                                BottleShopView(bottleShop: shop)
                            }) {
                                SearchShopListCell(shopDataStore: shopDataStore, shopInfo: shop, distance: shopDataStore.distance(shop.location.latitude, shop.location.longitude), bookMark: $bookMark, bookMarkAlarm: $bookMarkAlarm)
                            }
                
                            Divider()
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
            // MARK: - 정렬 ActionSheet
            .confirmationDialog("select a sort", isPresented: $showingActionSheet) {
                // TODO: 각 버튼 별로 정렬 액션 추가해야함
                Button("이름순") {
                    selection = "이름순"
                }
                Button("거리순") {
                    selection = "거리순"
                }
            }
            if bookMarkAlarm {
                HStack{
                    Image(bookMark ? "BookMark.fill" : "BookMark")
                    Text(bookMark ? "북마크가 완료되었습니다." : "북마크가 해제되었습니다.")
                        .foregroundColor(.black)
                        .font(.bottles11)
                    
                }
                .zIndex(1)
                .transition(.opacity.animation(.easeIn))
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 30)
                        .foregroundColor(.gray_f7)
                }
                .offset(y: (UIScreen.main.bounds.height/4))
            }
        }
    }
}

struct SearchShopListCell: View {
    // 필터링된 Shop의 정보를 저장하는 변수
    @EnvironmentObject var userStore: UserStore
    var shopDataStore: ShopDataStore
    var shopInfo: ShopModel
    var distance: Double
    // 북마크 알림
    @Binding var bookMark: Bool
    @Binding var bookMarkAlarm: Bool
    
    var body: some View {
        HStack(alignment: .top) {
            // Shop 이미지
            AsyncImage(url: URL(string: shopInfo.shopTitleImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .cornerRadius(12)
            } placeholder: {
                Image("ready_image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .cornerRadius(12)
            }
            .background(Color.gray_f7)
            .cornerRadius(12)
            .frame(height: 128)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                // Shop 이름
                Text(shopInfo.shopName)
                    .font(.bottles18)
                    .bold()
                    .multilineTextAlignment(.leading)
                // Shop 소개글
                Text(shopInfo.shopIntroduction)
                    .font(.bottles14)
                    .multilineTextAlignment(.leading)
                Spacer()
                /// 현재 위치와 바틀샵과의 거리
                /// 초기 distance 값(m) -> km로 환산 후 소수점 1번째 자리까지 제거
                ///  distance -> m 값 분기처리
                if distance/1000 < 1 {
                    Text("\(String(format: "%.0f", round(distance))) m")
                        .font(.bottles14)
                        .foregroundColor(.gray)
                } else {
                    Text("\(String(format: "%.0f", round(distance/1000))) km")
                        .font(.bottles14)
                        .foregroundColor(.gray)
                }
            }
            .foregroundColor(.black)
            .padding(.vertical, 10)
            
            Spacer()
            VStack {
                // TODO: 즐겨찾기 기능 추가해야함
                Button(action: {
                    withAnimation(.easeIn(duration: 1)) {
                        bookMark.toggle()
                        bookMarkAlarm.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        withAnimation(.easeIn(duration: 1)) {
                            bookMarkAlarm.toggle()
                        }
                    }
                    
                    if compareMyFollowShopID(shopInfo.id) == true {
                        bookMark = false
                        userStore.deleteFollowShopId(shopInfo.id)
                        shopDataStore.deleteFollowUserList(userStore.user.email, shopInfo.id)
                    }
                    
                    if compareMyFollowShopID(shopInfo.id) == false {
                        bookMark = true
                        userStore.addFollowShopId(shopInfo.id)
                        shopDataStore.addFollowUserList(userStore.user.id, shopInfo.id)
                    }
                    
                }) {
                    Image(compareMyFollowShopID(shopInfo.id) ? "BookMark.fill" : "BookMark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 18)
                        .padding(.trailing, 10)
                }
                Spacer()
            }
            .font(.title2)
            .padding()
            .padding(.top, -5)
        }
        .frame(minHeight: 130, maxHeight: 300)
        .padding(.vertical, 5)
        
    }
    func compareMyFollowShopID(_ shopId: String) -> Bool {
        return (userStore.user.followShopList.filter { $0 == shopId }.count != 0) ? true : false
    }
}

//struct SearchShopList_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchShopList()
//    }
//}
