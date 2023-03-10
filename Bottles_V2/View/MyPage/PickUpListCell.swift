//
//  PickUpListCell.swift
//  Bottles_V2
//
//  Created by BOMBSGIE on 2023/01/18.
//

import SwiftUI

struct PickUpListCell: View {
    
    @EnvironmentObject var bottleDataStore: BottleDataStore
    let reservationData: ReservationModel
    
    var body: some View {
        VStack{
            // MARK: - 예약 일자, 예약 상태 HStack
            HStack {
                Text(setDateFormat(reservedTime: reservationData.reservedTime))
                    .font(.bottles16)
                    //.bold()
                Spacer()
                
                //Text("예약접수")
                Text("\(reservationData.state)")
                    .font(.bottles12)
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke()
                            .frame(width: 61, height: 23)
                    }
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
            .padding(.vertical, 5)
            
            // MARK: - 픽업 매장, 상품명 HStack
            HStack{
                VStack(alignment:.leading){
                    Text("픽업 매장")
                        .padding(.bottom, -3)
                    Text("상품명")
                }
                .padding(.trailing)
                VStack(alignment:.leading){
                    //Text("test")
                    Text("\(reservationData.shopId)")
                        .padding(.bottom, -3)
                    
                    if reservationData.reservedBottles.count > 1 {
                        
                        Text("\(bottleDataStore.getMatchedBottleModel(bottleId: reservationData.reservedBottles[0].BottleId).itemName) 외 \(reservationData.reservedBottles.count-1)병")
                    }
                    else {
                        Text("\(bottleDataStore.getMatchedBottleModel(bottleId: reservationData.reservedBottles[0].BottleId).itemName)")
                    }
                    
                }
                Spacer()
            }
            .font(.bottles14)
        }
        .foregroundColor(.black)
        .padding(.horizontal)
        .padding(.bottom, 5)
        .padding(.top, 5)

    }

    func setDateFormat(reservedTime: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_kr")
            dateFormatter.timeZone = TimeZone(abbreviation: "KST")
            dateFormatter.dateFormat = "yyyy.MM.dd" // "yyyy-MM-dd HH:mm:ss"
            let dateCreatedAt = reservedTime
            return dateFormatter.string(from: dateCreatedAt)
    }
}

//struct PickUpListCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PickUpListCell()
//    }
//}
