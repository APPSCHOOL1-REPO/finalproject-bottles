//
//  PickUpDetailView.swift
//  Bottles_V2
//
//  Created by BOMBSGIE on 2023/01/18.
//

import SwiftUI

struct PickUpDetailView: View {
    /// 주소 복사를 했을 때 주소 복사 알림을 띄워줌
    @State private var isShowingPasted: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var shopDataStore: ShopDataStore
    @EnvironmentObject var bottleDataStore: BottleDataStore
    @EnvironmentObject var reservationDataStore: ReservationDataStore
    @State var reservationData: ReservationModel
    @State var isShowingCancelAlert: Bool = false
    @State private var check: Bool = false
    @State private var isShowing: Bool = false
    @State private var hiddenBottle: Bool = false
    @State private var hiddenInfo: Bool = false
    var tempId: String = UUID().uuidString
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 13) {
                            HStack(alignment: .top) {
                                Text("예약 정보")
                                    .font(.bottles16)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                            }
                            
                            HStack {
                                Text("예약 번호")
                                    .font(.bottles14)
                                    .fontWeight(.medium)
                                    .padding(.trailing)
                                Spacer()
                                Text(textLimit(str: reservationData.id))
                            }
                            .font(.bottles14)
                            .padding(.bottom, -1)
                            
                            HStack {
                                Text("픽업 매장")
                                    .font(.bottles14)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Image("Maptabfill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 17)
                                
                                // MARK: - 바틀샵 이름
                                Text("\(reservationData.shopId)")
                                    .font(.bottles14)
                                    .fontWeight(.regular)
                                
                                // MARK: - 픽업 매장 HStack내의 주소복사 버튼
                                Button(action: {
                                    
                                    // TODO: 주소를 copyToClipboard에 매개변수로 넘겨준다.
                                    copyToClipboard(shopAddress: shopDataStore.getMatchedShopData(shopID: reservationData.shopId).shopAddress)
                                    isShowingPasted.toggle()
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                                        isShowingPasted.toggle()
                                    }
                                    
                                }){
                                    Text("주소 복사")
                                        .font(.bottles12)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack {
                                Text("픽업 날짜")
                                    .font(.bottles14)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                // MARK: - 픽업 날짜
                                Text("\(reservationData.pickUpTime)까지 방문")
                                    .font(.bottles14)
                                    .fontWeight(.regular)
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("예약 상품")
                                    .font(.bottles16)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                HStack {
                                    // MARK: - 예약 바틀 총 개수
                                    Text("\(reservationData.reservedBottles.count)건")
                                        .font(.bottles16)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.bottom, 5)
                            
                            // MARK: - 예약 바틀 리스트
                            ForEach ($reservationData.reservedBottles, id: \.BottleId) { $bottle in
                                PickUpDetailCell(bottleModel: bottleDataStore.getMatchedBottleModel(bottleId: bottle.BottleId), count: bottle.itemCount)
                            }
                            .padding(.bottom, 5)
                            
                            // MARK: - 예약 바틀 총 금액
                            HStack {
                                Text("총 금액")
                                    .font(.bottles16)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(bottleDataStore.getTotalPrice(reservedBottles: reservationData.reservedBottles))원")
                                    .font(.bottles16)
                                    .fontWeight(.regular)
                            }
                            Divider()
                                .padding(.vertical, 5)
                            
                            // MARK: - 예약상태 HStack
                            HStack {
                                Text("예약 상태")
                                    .font(.bottles16)
                                    .fontWeight(.medium)
                                    .padding(.trailing)
                                
                                Spacer()
                                
                                if reservationData.state == "예약취소" {
                                    Text("\(reservationData.state)")
                                        .font(.bottles16)
                                        .fontWeight(.regular)
                                        .foregroundColor(.red)
                                } else {
                                    Text("\(reservationData.state)")
                                        .font(.bottles16)
                                        .fontWeight(.regular)
                                }
                                
                                if reservationData.state == "예약완료" {
                                    Text("\(reservationData.pickUpTime)까지 방문해주세요")
                                        .font(.bottles12)
                                        .foregroundColor(.gray)
                                }
                            }
                            //.padding(.top)
                            .padding(.bottom, 40)
                            
                            HStack {
                                Spacer()
                                if reservationData.state == "예약접수" {
                                    cancelButton
                                }
                                else {
                                    anotherShopButton
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    //MARK: - 주소복사 버튼 눌렀을 시 뜨는 알림
                    if isShowingPasted{
                        Text("주소 복사 완료")
                            .foregroundColor(.primary)
                            .font(.bottles12)
                            .background{
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke()
                                    .frame(width: 200, height: 30)
                                    .foregroundColor(.purple_2)
                            }
                            .position(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height / 5) * 3)
                        
                    }
                }
            }
        }
        .edgesIgnoringSafeArea([.bottom])
        .customAlert(isPresented: $isShowingCancelAlert, message: "예약을 취소하시겠습니까?", primaryButtonTitle: "확인", primaryAction: {
            Task {
                await reservationDataStore.cancelReservation(reservationId: reservationData.id)
            }
            self.reservationData.state = "예약취소"
            //            self.presentationMode.wrappedValue.dismiss()
        }, withCancelButton: true)
        
    }
    
    private var cancelButton : some View {
        Button {
            isShowingCancelAlert.toggle()
        } label : {
            Text("예약 취소")
                .font(.bottles18)
                .bold()
                .foregroundColor(.white)
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.accentColor)
                        .frame(width: 360, height: 50)
                }
            //.padding(.bottom, 20)
        }
    }
    
    private var anotherShopButton : some View {
        //MARK: - 다른 샵 보러가기 버튼
        // BottleShopView()로 변경해야 함
        NavigationLink(destination:
                        BottleShopView(bottleShop: shopDataStore.getMatchedShopData(shopID: reservationData.shopId))
        ){
            Text("이 바틀샵의 다른 상품 보러가기")
                .font(.bottles18)
                .bold()
                .foregroundColor(.white)
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.accentColor)
                        .frame(width: 360, height: 50)
                }
        }
        
    }
    
    var backButton : some View {
        Button(
            action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.backward")    // back button 이미지
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.black)
            }
    }
    
    // Todo: 데이터가 구성된 뒤 복사할 텍스트를 매개변수로 받아서 처리하기
    func copyToClipboard(shopAddress: String) {
        UIPasteboard.general.string = shopAddress
    }
    
    func textLimit(str: String) -> String {
        let startIndex = str.index(str.startIndex, offsetBy: 0)
        let endIndex = str.index(str.startIndex, offsetBy: 5)
        let range = startIndex...endIndex
        return String(str[range])
    }
    
    func setDateFormat(reservedTime: Date) -> String {
        let calender = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        
        var day3 = DateComponents()
        day3.day = 3
        
        let reservedTimePlusDay3 = calender.date(byAdding: day3, to: reservedTime)
        let convertDate = formatter.string(from: reservedTimePlusDay3!)
        return convertDate
    }
    
    
    
}

//struct PickUpDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PickUpDetailView()
//    }
//}
