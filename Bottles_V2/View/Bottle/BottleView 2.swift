//
//  BottleView.swift
//  Bottles_V2
//
//  Created by 강창현 on 2023/01/18.
//

import SwiftUI

struct BottleView: View {
    @State private var isShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Image("promesa")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width, height: 220)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("프로메샤 모스카토")
                                .font(.system(size: 18, weight: .medium))
                            Spacer()
                            HStack(spacing: 25) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .frame(width: 17, height: 23)
                                Image(systemName: "bookmark.fill")
                                    .resizable()
                                    .frame(width: 15, height: 19)
                            }
                        }
                        Text("10,100원")
                            .font(.system(size: 24, weight: .bold))
                        HStack {
                            Image("location")
                                .resizable()
                                .frame(width: 11, height: 16)
                            Text("바틀샵 이름")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                       
                    VStack(alignment: .leading) {
                        Text("술 소개. 친구 연인 가족과 함께 부담없이 마시기 좋은 스파클링 와인을 추천합니다.\n 어떤 음식과 페어링해도 평타 이상일거에요!")
                            .font(.system(size: 14, weight: .medium))
                            .lineSpacing(3)
                        
                        HStack {
                            ForEach(0..<3, id: \.self) { _ in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 1)
                                        .opacity(0.4)
                                        .frame(width: 54, height: 21)
                                    Text("위스키")
                                        .font(.caption)
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
                    
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading) {
                            Text("Tasting Notes")
                                .font(.subheadline)
                                .fontWeight(.bold)
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
                            
                            .font(.footnote)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Information")
                                .font(.subheadline)
                                .fontWeight(.bold)
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
                            .font(.footnote)
                            
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Pairing")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text("회, 생선, 랍스타 등의 해산물")
                                .font(.footnote)
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
                    .padding()
                    
                }
                ForEach(0..<3, id: \.self) {_ in
                    OtherBottleView()
                }
                
                NavigationLink(destination: ReservationView()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray)
                            .frame(width: 358, height: 51)
                        Text("예약하기")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .padding()
            }
        }
     
//        .sheet(isPresented: $isShowing) {
//            ReservationView()
//
//        }
       
    }
}

struct BottleView_Previews: PreviewProvider {
    static var previews: some View {
        BottleView()
    }
}