//
//  BottleView_Info.swift
//  Bottles_V2
//
//  Created by hyemi on 2023/01/23.
//

import SwiftUI

struct BottleView_Info: View {
    var tagList: [String] = ["위스키", "한정판", "스모키"]
    
    @State private var checkBookmark: Bool = true
    
    var body: some View {
        // MARK: - 바틀 이미지, 이름, 가격, 바틀샵 이름
        VStack(alignment: .leading) {
            // 바틀 이미지
            Image("promesa")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width, height: 220)
           
            VStack(alignment: .leading) {
                HStack {
                    // 바틀 이름
                    Text("프로메샤 모스카토")
                        .font(.bottles18)
                        .fontWeight(.medium)
                    Spacer()
                    HStack(spacing: 25) {
                        // Share 버튼
                        ShareLink(item: "") {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .frame(width: 17, height: 23)
                        }

                        // 북마크 버튼
                        Button(action: {
                            checkBookmark.toggle()
                        }) {
                            Image(checkBookmark ? "BookMark.fill" : "BookMark")
                                .resizable()
                                .frame(width: 15, height: 19)
                        }
                        
                    }
                }
                // 가격
                Text("10,100원")
                    .font(.bottles24)
                    .fontWeight(.bold)
                
                // 바틀샵 이름
                HStack {
                    Image("Map_Tab_fill")
                        .resizable()
                        .frame(width: 11, height: 16)
                    Text("바틀샵 이름")
                        .font(.bottles15)
                        .fontWeight(.medium)
                }
            }
            .padding()
               
            // MARK: 바틀 소개
            VStack(alignment: .leading) {
                Text("술 소개. 친구 연인 가족과 함께 부담없이 마시기 좋은 스파클링 와인을 추천합니다.\n 어떤 음식과 페어링해도 평타 이상일거에요!")
                    .font(.bottles14)
                    .fontWeight(.medium)
                    .lineSpacing(3)
                
                HStack {
                    ForEach(tagList, id: \.self) { tag in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                                .opacity(0.4)
                                .frame(width: 54, height: 21)
                            Text(tag)
                                .font(.bottles12)
                                .fontWeight(.medium)
                                .opacity(0.4)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // MARK: Tasting Notes, Information, Paring
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Tasting Notes")
                        .font(.bottles15)
                        .fontWeight(.bold)
                        .padding(.vertical, 3)
                    Group {
                        HStack {
                            Text("Aroma")
                            Text("사과, 시트러스, 그린 애플")
                        }
                        HStack {
                            Text("Taste")
                            Text("복숭아, 파인애플, 망고, 미네랄")
                        }
                        HStack {
                            Text("Finish")
                            Text("꽃, 구아바, 체리, 달콤한")
                        }
                    }
                    .font(.bottles13)
                    .fontWeight(.medium)
                }
                
                VStack(alignment: .leading) {
                    Text("Information")
                        .font(.bottles15)
                        .fontWeight(.bold)
                        .padding(.vertical, 3)
                    Group {
                        HStack {
                            Text("종류")
                            Text("스파클링 와인")
                        }
          
                        HStack {
                            Text("용량")
                            Text("750ml")
                        }
                
                        HStack {
                            Text("도수")
                            Text("8%")
                        }
                        
                        HStack {
                            Text("국가")
                            Text("스페인")
                        }
                        
                        HStack {
                            Text("품종")
                            Text("모스카토")
                        }
                    }
                    .font(.bottles13)
                    .fontWeight(.medium)
                }
                
                VStack(alignment: .leading) {
                    Text("Pairing")
                        .font(.bottles15)
                        .fontWeight(.bold)
                        .padding(.vertical, 3)
                    Text("회, 생선, 랍스타 등의 해산물")
                        .font(.bottles13)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            .padding()
            
        }
    }
}

struct BottleView_Info_Previews: PreviewProvider {
    static var previews: some View {
        BottleView_Info()
    }
}