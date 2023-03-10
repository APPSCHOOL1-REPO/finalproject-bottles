//
//  BottleShopView.swift
//  Bottles_V2
//
//  Created by 강창현 on 2023/01/18.
//

import SwiftUI
//import Contacts

// 바틀샵 뷰 내에서 [1. "상품 검색"과 2. "사장님의 공지" 뷰 이동]시 사용할 enum
enum bottleShopInfo : String, CaseIterable {
    case bottle = "상품 검색"
    case notice = "사장님의 공지"
}

// 바틀샵 메인 뷰
struct BottleShopView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var bookmarkToggle: Bool = false
    @State var bookmarkToggle_fill: Bool = false
    @State var bookmarkToggle_empty: Bool = false
    @State private var isSearchView: Bool = true
    @State private var selectedPicker: bottleShopInfo = .bottle
    
    @FocusState var focus: Bool
    @State var isNavigationBarHidden: Bool = false
    @State var search: Bool = false
    @State var testSearchText: String = ""
    
    @State var calling: Bool = false
    @State private var isSuccess: Bool = false
    @State private var showCallAction: Bool = false
    
    @Namespace private var animation
    
    @EnvironmentObject var shopDataStore: ShopDataStore
    @EnvironmentObject var bottleDataStore: BottleDataStore
    
    var bottleShop: ShopModel
    
    // 검색 결과를 필터링해주는 연산 프로퍼티
    var filteredResult: [BottleModel] {
        let bottles = bottleDataStore.bottleData
        let test = bottles.filter{ $0.shopID == bottleShop.id }
        return test.filter {
            $0.itemName.contains(testSearchText)
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                ScrollView{
                    VStack{
                        
                        // 데이터 연동 시 "shopTitleImage" 연동
                        AsyncImage(url: URL(string: String(bottleShop.shopTitleImage)), content: { image in
                            image
                                .resizable()
                            //                                .scaledToFit()
                                .aspectRatio(contentMode: .fit)
                        }, placeholder: {
                            Image("ready_image")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        })
                        
                        HStack{
                            // 데이터 연동 시 "shopName" 연동
                            Text(bottleShop.shopName)
                                .font(.bottles20)
                                .fontWeight(.bold)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            // "매장 정보 뷰"로 이동
                            NavigationLink(destination: BottleShopDetailView(bottleShop: bottleShop))
                            {
                                HStack{
                                    Text("매장정보")
                                    Image(systemName: "chevron.right")
                                        .padding(.leading, -5)
                                }
                                .font(.bottles14)
                                .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // 전화 아이콘 버튼
                            Button(action: {
                                calling = true
                                self.showCallAction = true
                                print(bottleShop.shopPhoneNumber)
                            }) {
                                Image("Phone.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15)
                                    .padding(.trailing, 5)
                                
                            }
                            
                            Spacer()
                                .frame(width: 15)
                            
                            // 북마크 아이콘 버튼
                            
                            Button(action: {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    bookmarkToggle.toggle()
                                }
                                
                                if compareMyFollowShopID(bottleShop.id) == true {
                                    bookmarkToggle = false
                                    userStore.deleteFollowShopId(bottleShop.id)
                                    shopDataStore.deleteFollowUserList(userStore.user.email, bottleShop.id)
                                    withAnimation(.easeOut(duration: 1.5)) {
                                        bookmarkToggle_empty.toggle()
                                        print("북마크 해제")
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                        bookmarkToggle_empty.toggle()
                                    }
                                }
                                
                                if compareMyFollowShopID(bottleShop.id) == false {
                                    bookmarkToggle = true
                                    userStore.addFollowShopId(bottleShop.id)
                                    shopDataStore.addFollowUserList(userStore.user.id, bottleShop.id)
                                    withAnimation(.easeOut(duration: 1.5)) {
                                        bookmarkToggle_fill.toggle()
                                        print("북마크 완료")
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                        bookmarkToggle_fill.toggle()
                                    }
                                }
                                
                            }) {
                                Image(compareMyFollowShopID(bottleShop.id) ? "BookMark.fill" : "BookMark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15)
                                    .padding(.trailing, 5)
                            }
                        }
                        .padding()
                        
                        HStack{
                            
                            // 데이터 연동 시 "shopIntroduction" 연동
                            Text(bottleShop.shopIntroduction)
                                .font(.bottles14)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, -15)
                        
                        if bottleShop.shopCurationTitle == "" {
                            HStack{
                                Image(systemName: "wineglass")
                                    .padding(.leading, -5)
                                Text("큐레이션 준비 중이에요!")
                                Spacer()
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .font(.bottles14)
                            .padding()
                            .background(Color.purple_3)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            
                        }else{
                            // 큐레이션 있을 시 "큐레이션 뷰"로 이동
                            NavigationLink(destination: BottleShopCurationView(bottleShop: bottleShop)){
                                HStack{
                                    
                                    // 데이터 연동 시 "shopCurationTitle" 연동
                                    Text(bottleShop.shopCurationTitle)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .padding(.leading, -5)
                                    
                                }
                                .fontWeight(.semibold)
                            }
                            .font(.bottles14)
                            .padding()
                            .background(Color.purple_3)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                        VStack {
                            animate()
                            BottleShopInfoView(bottleShopInfo: selectedPicker, search: $search, focus: _focus, isNavigationBarHidden: $isNavigationBarHidden, bottleShop: bottleShop)
                        }
                        
                    }
                }
                
                // MARK: - 상품검색 클릭시 navigationbarhidden 후 상단에 나오는 검색창
                if search {
                    VStack{
                        HStack {
                            TextField(" 이 바틀샵의 상품 검색", text: $testSearchText)
                                .focused($focus)
                                .font(.bottles16)
                                .padding(7)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 7)
                                .cornerRadius(8)
                                .overlay(
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.black)
                                            .font(.system(size: 18))
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 8)
                                        
                                        Button(action: {
                                            self.testSearchText = ""
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 8)
                                        }
                                    }
                                )
                                .padding(.leading, 10)
                            
                            // 검색종료버튼(검색창, 키보드 내리기 및 네비게이션바 다시 보이게 하는 액션)
                            Button(action: {
                                search = false
                                focus = false
                                isNavigationBarHidden = false
                                self.testSearchText = ""
                                
                                // Dismiss the keyboard
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                
                            }) {
                                Text("종료  ")
                                    .padding(.trailing, 20)
                            }
                            
                        }
                        .background(.white)
                        .padding(.bottom, -10)
                        
                        ZStack {
                            ZStack{
                                Color.black.opacity(0.3)
                            }
                            .ignoresSafeArea()
                            .onTapGesture {
                                search = false
                                focus = false
                                isNavigationBarHidden = false
                            }
                            
                            // 검색결과 필터링 후 바틀셀 반복문
                            ScrollView {
                                ForEach(filteredResult, id: \.self) { item in
                                    NavigationLink(destination: BottleView(bottleData: item), label:{
                                        BottleShopView_BottleList(selectedItem: item)
                                            .padding(.horizontal)
                                    })
                                    .simultaneousGesture(TapGesture().onEnded {
                                        focus = false
                                    })
                                }
                            }
                            .background(Color.white)
                            .zIndex(1)
                            
                        }
                        
                    }
                    .transition(.asymmetric(insertion: AnyTransition.opacity.animation(.easeInOut),
                                            removal: AnyTransition.opacity.animation(.easeInOut))
                    )
                    //                    .animation(.easeOut)
                }
                
                BookMarkToggle(bookmarkToggle_fill: $bookmarkToggle_fill, bookmarkToggle_empty: $bookmarkToggle_empty)
                
                // MARK: - "전화기 image 눌렀을 때" custom alert (시뮬레이터 x, 실기기에서만 작동)
                MakeCallOrAddToCallBook(calling: $calling, bottleShop: bottleShop)
            }
            .navigationBarHidden(isNavigationBarHidden)
            .toolbar { // <-
                NavigationLink {
                    CartView()
                } label: {
                    Image("cart")
                }
            }
        }
    }
    
    // MARK: - Picker Animation 함수
    @ViewBuilder
    private func animate() -> some View {
        VStack {
            HStack {
                ForEach(bottleShopInfo.allCases, id: \.self) { item in
                    VStack {
                        Text(item.rawValue)
                            .kerning(-1)
                            .frame(maxWidth: 200, maxHeight: 30)
                            .foregroundColor(selectedPicker == item ? .black : .gray)
                            .padding(.top, 10)
                        
                        if selectedPicker == item {
                            Capsule()
                                .foregroundColor(.black)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "info", in: animation)
                        } else if selectedPicker != item {
                            Capsule()
                                .foregroundColor(.white)
                                .frame(height: 2)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.selectedPicker = item
                        }
                    }
                }
            }
            .padding(.horizontal, 15)
        }
        
    }
    
    func compareMyFollowShopID(_ shopId: String) -> Bool {
        return (userStore.user.followShopList.filter { $0 == shopId }.count != 0) ? true : false
    }
}

// MARK: 바틀샵 메인 뷰 내 [1. "상품 검색"과 2. "사장님의 공지" 뷰] 탭
struct BottleShopInfoView: View {
    var bottleShopInfo: bottleShopInfo
    
    @Binding var search: Bool
    @FocusState var focus: Bool
    @Binding var isNavigationBarHidden: Bool
    
    var bottleShop: ShopModel
    
    var body: some View {
        VStack {
            switch bottleShopInfo {
                
                // "상품 검색 탭"
            case .bottle:
                VStack(alignment: .leading){
                    BottleShopView_Search(search: $search, focus: _focus, isNavigationBarHidden: $isNavigationBarHidden, bottleShop: bottleShop)
                }
                
                // "사장님의 공지 탭"
            case .notice:
                VStack{
                    BottleShopView_Notice(shopData: bottleShop)
                }
            }
        }
    }
}

//struct BottleShopView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack{
//            BottleShopView()
//        }
//    }
//}
