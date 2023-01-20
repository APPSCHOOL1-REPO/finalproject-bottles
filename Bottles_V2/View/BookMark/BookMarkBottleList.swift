//
//  BookMarkBottleList.swift
//  Bottles_V2
//
//  Created by 서찬호 on 2023/01/18.
//

import SwiftUI

struct BookMarkBottleList: View {
    // ActionSheet (iOS 14 이하 - ActionSheet, iOS 15 이상 - confirmationDialog 사용해야함)
    @State private var showingActionSheet: Bool = false
    @State private var selection = "기본순"
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    showingActionSheet = true
                } label: {
                    HStack {
                        Text("\(selection)")
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.black)
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            ScrollView {
                BookMarkBottleListCell()
                BookMarkBottleListCell()
                BookMarkBottleListCell()
            }
        }
        // MARK: - 정렬 ActionSheet
        .confirmationDialog("select a sort", isPresented: $showingActionSheet) {
            Button {
                selection = "기본순"
            } label: {
                Text("기본순")
            }

            Button("신상품순") {
                selection = "신상품순"
            }
            
            Button("낮은 가격순") {
                selection = "낮은 가격순"
            }
            
            Button("높은 가격순") {
                selection = "높은 가격순"
            }
        }
    }
}

struct BookMarkBottleListCell: View {
    var body: some View {
        HStack(alignment: .top) {
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(.black)
//                .frame(width: 150, height: 150)
//                .overlay {
                    Image("whisky_Image1")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .cornerRadius(10)
                         .frame(width: 120, height: 120)
                         .padding(.horizontal)
//                }
//                .padding()
    
            VStack(alignment: .leading, spacing: 10) {
                Text("킬호만 샤닉")
                    .font(.title3)
                Text("350,000원")
                NavigationLink {
                    BottleShopView()
                } label: {
                    HStack {
                        Image("MapMarker")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                        Text("와인앤모어")
                    }
                }
            }
            .bold()
            .padding(.vertical)
            
            Spacer()
            VStack {
                Button {
                    
                } label: {
                    Image(systemName: "bookmark.fill")
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "cart.badge.plus")
                }
            }
            .font(.title2)
            .padding()
        }
        .frame(height: 130)
        .padding(.vertical, 5)
    }
}

struct BookMarkBottleList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookMarkBottleList()
        }
    }
}

// AsyncImage 사용
/*
 RoundedRectangle(cornerRadius: 5)
     .stroke(.black)
     .frame(width: 150, height: 150)
     .overlay {
         AsyncImage(url: URL(string: "https://kanashop.kr/web/product/big/201903/97ef5cee30f4cd6072fd736831623d2e.jpg")) { image in
             image
                 .resizable()
                 .aspectRatio(contentMode: .fit)
         } placeholder: {
             Image("ready_image")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
         }
     }
     .padding()
 */