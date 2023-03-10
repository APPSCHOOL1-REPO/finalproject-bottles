//
//  BookMarkView.swift
//  Bottles_V2
//
//  Created by 강창현 on 2023/01/18.
//

import SwiftUI

// BookMark Tab의 종류를 담은 열거형
enum tabInfo : String, CaseIterable {
    case bottle = "북마크한 상품"
    case shop = "북마크한 바틀샵"
}

struct BookMarkView: View {
    
    // tab picker
    @State private var selectedPicker: tabInfo = .bottle
    @Namespace private var animation
    
    
    // Search View 연결 관련
    @State var transitionView: Bool = false
    @FocusState var focus: Bool
    
    @Binding var root: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if !transitionView {
                    VStack {
                        HStack {
                            // Test
                            Button {
                                transitionView.toggle()
                                focus = true
                            } label: {
                                SearchViewNavigationLabel()
                            }
                            // CartView 로 이동하는 버튼
                            CartViewNavigationLink()
                                .padding(.leading, 5)
                        }
                        .padding(.top)
                        // tab picker 애니메이션 함수 및 탭뷰
                        animate()
                        BookMarkTabView(bookMarkTab: selectedPicker, root: $root)
                    }
                } else {
                    VStack {
                        SearchView(focus: _focus, transitionView: $transitionView, root: $root)
                    }
                }
            }
            
        }
    }
    
    // MARK: - Picker Animation 함수
    @ViewBuilder
    private func animate() -> some View {
        VStack {
            HStack {
                ForEach(tabInfo.allCases, id: \.self) { item in
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
}


struct BookMarkTabView: View {
    var bookMarkTab: tabInfo
    @Binding var root: Bool
    
    var body: some View {
        VStack {
            switch bookMarkTab {
            case .bottle:
                BookMarkBottleList(root: $root)
            case .shop:
                BookMarkShopList(root: $root)
            }
        }
    }
}

struct BookMarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookMarkView(root: .constant(false))
    }
}
