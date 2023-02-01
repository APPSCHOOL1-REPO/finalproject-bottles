//
//  SearchShopList.swift
//  Bottles_V2
//
//  Created by 서찬호 on 2023/01/18.
//

import SwiftUI

struct SearchShopList: View {
    // 검색어를 저장하는 변수
    var shopName: String
    // 테스트용 모델
    @StateObject var bookMarkTestStore: BookMarkTestStore = BookMarkTestStore()
    // 검색 결과를 필터링해주는 연산 프로퍼티
    var filteredResult: [BookMarkShop] {
        let bottles = bookMarkTestStore.BookMarkShops
        return bottles.filter {
            $0.shopName.contains(shopName)
        }
    }
    
    var body: some View {
        VStack {
            // 검색어를 포함하는 Data가 없을 경우
            if filteredResult == [] {
                Text("검색 결과가 없습니다.")
                    .font(.bottles14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
                Spacer()
            } else {
                // TODO: 서버 Shop 데이터 연결
                ScrollView {
                    ForEach(filteredResult, id: \.self) { shop in
                        NavigationLink {
                            BottleShopView()
                        } label: {
                            SearchShopListCell(shopInfo: shop)
                        }
                    }
                }
            }
        }
    }
}

struct SearchShopListCell: View {
    // 필터링된 Shop의 정보를 저장하는 변수
    var shopInfo: BookMarkShop
    
    var body: some View {
        HStack(alignment: .top) {
            // Shop 이미지
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black)
                .frame(width: 120, height: 120)
                .overlay {
                    AsyncImage(url: URL(string: "https://wine21.speedgabia.com/NEWS_MST/froala/202007/20200716101122567972.jpg")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                    } placeholder: {
                        Image("ready_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
    
            VStack(alignment: .leading, spacing: 10) {
                // Shop 이름
                Text(shopInfo.shopName)
                    .font(.bottles18)
                    .bold()
                // Shop 소개글
                Text("바틀샵 소개 가나다라마 아자차 마바사가다")
                    .font(.bottles14)
                Spacer()
            }
            .foregroundColor(.black)
            .padding(.top, 5)
            
            Spacer()
            VStack {
                // TODO: 즐겨찾기 기능 추가해야함
                Button {
                    
                } label: {
                    Image(systemName: "bookmark.fill")
                }
                Spacer()
            }
            .font(.title2)
            .padding()
            .padding(.top, -5)
        }
        .frame(height: 130)
        .padding(.vertical, 5)
    }
}

//struct SearchShopList_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchShopList()
//    }
//}