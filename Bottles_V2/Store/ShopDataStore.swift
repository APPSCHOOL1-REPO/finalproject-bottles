//
//  ShopStore.swift
//  Bottles_V2
//
//  Created by Ethan Choi on 2023/01/19.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift   //GeoPoint 사용을 위한 프레임워크
import CoreLocation

class ShopDataStore : ObservableObject {
    
    // 전체 샵 데이터 저장 변수
    @Published var shopData : [ShopModel] = []
    
    // 로그인 시 전체 패치 실행
    @MainActor
    func getAllShopData() async {
        
        do {
            let documents = try await Firestore.firestore().collection("Shop").getDocuments()
            for document in documents.documents {
                let docData = document.data()
                // 있는지를 따져서 있으면 데이터 넣어주고, 없으면 옵셔널 처리
                
                let id : String = document.documentID
                let shopName : String = docData["shopName"] as? String ?? ""
                let shopOpenCloseTime : String = docData["shopOpenCloseTime"] as? String ?? ""
                let shopAddress : String = docData["shopAddress"] as? String ?? ""
                let shopPhoneNumber : String = docData["shopPhoneNumber"] as? String ?? ""
                let shopIntroduction : String = docData["shopIntroduction"] as? String ?? ""
                let shopSNS : String = docData["shopSNS"] as? String ?? ""
                let followerUserList : Array<String> = docData["followerUserList"] as? Array<String> ?? ["no"]
                let isRegister : Bool = docData["isRegister"] as? Bool ?? true
                let location : GeoPoint = docData["location"] as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                let reservedList : Array<String> = docData["reservedList"] as? Array<String> ?? ["no"]
                let shopTitleImage : String = docData["shopTitleImage"] as? String ?? ""
                let shopImages : Array<String> = docData["shopImages"] as? Array<String> ?? ["no"]
                let shopCurationTitle : String = docData["shopCurationTitle"] as? String ?? ""
                let shopCurationBody : String = docData["shopCurationBody"] as? String ?? ""
                let shopCurationImage : String = docData["shopCurationImage"] as? String ?? ""
                let shopCurationBottleID : Array<String> = docData["shopCurationBottleID"] as? Array<String> ?? ["no"]
                let bottleCollections : Array<String> = docData["BottleCollections"] as? Array<String> ?? ["no"]
                let noticeCollection : Array<String> = docData["NoticeCollection"] as? Array<String> ?? ["no"]
                let reservationCollection : Array<String> = docData["reservationCollection"] as? Array<String> ?? ["no"]
                
                let shopData : ShopModel = ShopModel(id: id, shopName: shopName, shopOpenCloseTime: shopOpenCloseTime, shopAddress: shopAddress, shopPhoneNumber: shopPhoneNumber, shopIntroduction: shopIntroduction, shopSNS: shopSNS, followerUserList: followerUserList, isRegister: isRegister, location: location, reservedList: reservedList, shopTitleImage: shopTitleImage, shopImages: shopImages, shopCurationTitle: shopCurationTitle, shopCurationBody: shopCurationBody, shopCurationImage: shopCurationImage, shopCurationBottleID: shopCurationBottleID, bottleCollections: bottleCollections, noticeCollection: noticeCollection, reservationCollection: reservationCollection)
                
                self.shopData.append(shopData)
//                                        print("우하하하 \(self.shopData)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addFollowUserList(_ userId: String, _ shopName: String) {
        Firestore.firestore().collection("Shop")
            .document(shopName)
            .updateData(["followerUserList": FieldValue.arrayUnion([userId])])
    }
    
    func deleteFollowUserList(_ userId: String, _ shopName: String) {
        Firestore.firestore().collection("Shop")
            .document(shopName)
            .updateData(["followerUserList": FieldValue.arrayRemove([userId])])
    }
    
    // MARK: - 검색 로직 및 거리 순 오름차순 정렬 함수
    func getSearchResult(searchText: String) -> [ShopModel] {
        let filteredData = self.shopData
        if !searchText.isEmpty {
            return filteredData.filter {
                $0.shopName.contains(searchText)
            }.sorted(by: {$0.shopName < $1.shopName }).sorted(by: {distance($0.location.latitude, $0.location.longitude) < distance($1.location.latitude, $1.location.longitude)})
        }
        return filteredData
    }
    
    // MARK: - 현재 위치 좌표 거리 계산 함수
    func distance(_ lat: Double, _ log: Double) -> CLLocationDistance {
        let from = CLLocation(latitude: lat, longitude: log)
        let to = CLLocation(latitude: Coordinator.shared.userLocation.0, longitude: Coordinator.shared.userLocation.1)
        //        print("\(from.distance(from: to))")
        return from.distance(from: to)
    }
    
    
    // MARK: - 특정 바틀에 대한 바틀샵 매칭 함수
    func getMatchedShopData(shopID: String) -> ShopModel {
        let matchedShopData = shopData.filter {$0.id == shopID}
        return matchedShopData[0]
    }
    
    // MARK: - 바틀데이터 정렬
    func sortBottleData(_ filterBottleData: [BottleModel], selection: String) -> [BottleModel] {
        switch selection {
        case "거리순":
            return filterBottleData.sorted(by: {$0.itemName < $1.itemName})
                .sorted(by: {distance(getMatchedShopData(shopID: $0.shopID).location.latitude, getMatchedShopData(shopID: $0.shopID).location.longitude) < distance(getMatchedShopData(shopID: $1.shopID).location.latitude, getMatchedShopData(shopID: $1.shopID).location.longitude)})
        case "낮은 가격순":
            return filterBottleData.sorted(by: {$0.itemName < $1.itemName}).sorted(by: {$0.itemPrice < $1.itemPrice})
        case "높은 가격순":
            return filterBottleData.sorted(by: {$0.itemName < $1.itemName}).sorted(by: {$0.itemPrice > $1.itemPrice})
        default:
            return filterBottleData.sorted(by: {$0.itemName < $1.itemName})
        }
    }
    
    // MARK: - Shop데이터 정렬
    func sortShopData(_ bookMarkShops: [ShopModel], selection: String) -> [ShopModel] {
        switch selection {
        case "거리순":
            return bookMarkShops.sorted(by: {$0.shopName < $1.shopName}).sorted(by: {distance($0.location.latitude, $0.location.longitude) < distance($1.location.latitude, $1.location.longitude)})
        default:
            return bookMarkShops.sorted(by: {$0.shopName < $1.shopName})
        }
    }
    
    // MARK: - 북마크된 Shop들을 가져오는 함수
    func filterUserShopData(followShopList: [String]) -> [ShopModel] {
        var resultData: [ShopModel] = []
        
        for itemList in followShopList {
            let filterData = self.shopData.filter {$0.id == itemList}[0]
            resultData.append(filterData)
        }
        return resultData
    }
    
    // MARK: - 검색 결과를 필터링해주는 함수
    func shopSearchResult(shopName: String) -> [ShopModel] {
        return self.shopData.filter {
            $0.shopName.contains(shopName)
        }
    }
}

