//
//  NaverMap.swift
//  Bottles_V2
//
//  Created by 강창현 on 2023/01/20.
//

import SwiftUI
import NMapsMap
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift   //GeoPoint 사용을 위한 프레임워크

struct NaverMap: UIViewRepresentable {
    
    @EnvironmentObject var userDataStore: UserStore
    @EnvironmentObject var shopDataStore : ShopDataStore
    
    @Binding var currentShopId: String
    @Binding var showMarkerDetailView: Bool
    @Binding var coord: (Double, Double)
    @Binding var userLocation: (Double, Double)
    @Binding var isBookMarkTapped: Bool
    
    // MARK: - 북마크 유무 확인
    func filterUserShopData() -> [ShopModel] {
        var bookMarkedBottleShops: [ShopModel] = []
        
        for bookMarkedBottleShop in userDataStore.user.followShopList {
            let filterData = shopDataStore.shopData.filter {$0.id == bookMarkedBottleShop}[0]
            bookMarkedBottleShops.append(filterData)
        }
        return bookMarkedBottleShops
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coord, $showMarkerDetailView, userLocation, $isBookMarkTapped)
    }
    
    init(_ coord: Binding<(Double, Double)>, _ showMarkerDetailView: Binding<Bool>, _ currentShopId: Binding<String>, _ userLocation: Binding<(Double, Double)>, _ isBookMarkTapped: Binding<Bool>
    ) {
        self._coord = coord
        self._showMarkerDetailView = showMarkerDetailView
        self._currentShopId = currentShopId
        self._userLocation = userLocation
        self._isBookMarkTapped = isBookMarkTapped
    }
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {
        
        @Binding var showMarkerDetailView: Bool
        @Binding var isBookMarkTapped: Bool
        
        var coord: (Double, Double)
        var userLocation: (Double, Double)
        
        init(_ coord: (Double, Double), _ showMarkerDetailView: Binding<Bool>, _ userLocation: (Double, Double), _ isBookMarkTapped: Binding<Bool>) {
            self.coord = coord
            self.userLocation = userLocation
            self._showMarkerDetailView = showMarkerDetailView
            self._isBookMarkTapped = isBookMarkTapped
        }
        
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            //            print("카메라 변경 - reason: \(reason)")
        }
        
        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
            // MARK: - 카메라 변경 Reason 번호 별 차이
            /// 0 : 개발자의 코드로 화면이 움직였을 때
            /// -1 : 사용자의 제스처로 화면이 움직였을 때
            /// -2 : 버튼 선택으로 카메라가 움직였을 때
            /// -3 : 네이버 지도가 제공하는 위치 트래킹 기능으로 카메라가 움직였을 때
            //            print("카메라 변경 - reason: \(reason)")
            
            // MARK: - 카메라 위치 변경 시 위도/경도 값 받아오기
            let cameraPosition = mapView.cameraPosition
            //            print("카메라 위치 변경 : \(cameraPosition.target.lat)", "\(cameraPosition.target.lng)")
        }
        
        // MARK: - 지도 터치에 이용되는 Delegate
        /// 지도 터치 시 MarkerDetailView 창 닫기
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            print("Map Tapped")
            showMarkerDetailView = false
        }
    }
    
    func makeUIView(context: Context) -> some NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.isNightModeEnabled = true
        // MARK: - 줌 레벨 제한
        view.mapView.zoomLevel = 15 // 기본 카메라 줌 레벨
        view.mapView.minZoomLevel = 10 // 최소 줌 레벨
        view.mapView.maxZoomLevel = 17 // 최대 줌 레벨
        // MARK: - 현 위치 추적 버튼
        view.showLocationButton = false
        view.showCompass = false
        view.showZoomControls = false
        let cameraPosition = view.mapView.cameraPosition
        // MARK: - 마커 생성
        for (index, shopMarker) in self.shopDataStore.shopData.enumerated() {
            // TODO: 아래 코드 위경도를 바꿔주면 서 for 문 생성
            let marker = NMFMarker()
            marker.position = NMGLatLng(
                lat: shopMarker.location.latitude,
                lng: shopMarker.location.longitude)
            marker.captionRequestedWidth = 100 // 마커 캡션 너비 지정
            marker.captionText = shopMarker.shopName
            marker.captionMinZoom = 10
            marker.captionMaxZoom = 17
            
            // MARK: - 마커 이미지 변경
            marker.iconImage = NMFOverlayImage(name: shopMarker.isRegister ? "MapMarker.fill" : "MapMarker")
            marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
            marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
            
            // MARK: - 마커 터치 핸들러
            marker.touchHandler = { (overlay) -> Bool in
                //                print("marker touched")
                currentShopId = shopMarker.id
                showMarkerDetailView = true
                
                // 마커 터치 시 마커 아이콘 크기 변경
                if shopMarker.isRegister {
                    marker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker_tapped" : "MapMarker.fill")
                } else {
                    // TODO: isRegister == false일 때 이미지 추가/수정
                    marker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker" : "MapMarker")
                }
                
                marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                
                // 마커 터치 시 해당 마커 좌표로 카메라 이동
                coord = (marker.position.lat,marker.position.lng)
                
                return true
            }
            marker.mapView = view.mapView
            
        }
        // MARK: - NMFMapViewCameraDelegate를 상속 받은 Coordinator 클래스 넘겨주기
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        // MARK: - 지도 터치 시 발생하는 touchDelegate
        view.mapView.touchDelegate = context.coordinator
        print("camera position: \(cameraPosition)")
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let coord = NMGLatLng(lat: coord.0, lng: coord.1)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 1
        uiView.mapView.moveCamera(cameraUpdate)
        
        // MARK: - 내 주변 5km 반경 overlay 표시
        let circle = NMFCircleOverlay()
        circle.center = NMGLatLng(lat: userLocation.0, lng: userLocation.1)
        circle.radius = 5000
        circle.mapView = nil
        
        // MARK: - 현재 위치 좌표 overlay 마커 표시
        let locationOverlay = uiView.mapView.locationOverlay
        locationOverlay.location = NMGLatLng(lat: userLocation.0, lng: userLocation.1)
        locationOverlay.hidden = false
        
        // MARK: - TEST
//
//        for (index, shopMarker) in self.shopDataStore.shopData.enumerated() {
//            let marker = NMFMarker()
//            // TODO: 아래 코드 위경도를 바꿔주면 서 for 문 생성
//            marker.position = NMGLatLng(
//                lat: shopMarker.location.latitude,
//                lng: shopMarker.location.longitude)
//            marker.captionRequestedWidth = 100 // 마커 캡션 너비 지정
//            marker.captionText = shopMarker.shopName
//            marker.captionMinZoom = 10
//            marker.captionMaxZoom = 17
//
//            // MARK: - 마커 이미지 변경
//            marker.iconImage = NMFOverlayImage(name: shopMarker.isRegister ? "MapMarker.fill" : "MapMarker")
//            marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
//            marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
//
//            // MARK: - 마커 터치 핸들러
//            marker.touchHandler = { (overlay) -> Bool in
//                //                print("marker touched")
//                currentShopId = shopMarker.id
//                showMarkerDetailView = true
//
//                // 마커 터치 시 마커 아이콘 크기 변경
//                if shopMarker.isRegister {
//                    marker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker_tapped" : "MapMarker.fill")
//                } else {
//                    // TODO: isRegister == false일 때 이미지 추가/수정
//                    marker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker" : "MapMarker")
//                }
//
//                marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
//                marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
//
//                /*
//                 let coord = NMGLatLng(lat: coord.0, lng: coord.1)
//                 let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
//                 cameraUpdate.animation = .fly
//                 cameraUpdate.animationDuration = 1
//                 uiView.mapView.moveCamera(cameraUpdate)
//
//                 */
//
//                // 마커 터치 시 해당 마커 좌표로 카메라 이동
//                let markerPosition = NMGLatLng(lat: marker.position.lat, lng: marker.position.lng)
//                let cameraUpdate = NMFCameraUpdate(scrollTo: markerPosition)
//                cameraUpdate.animation = .fly
//                cameraUpdate.animationDuration = 1
//                uiView.mapView.moveCamera(cameraUpdate)
//
//                return true
//            }
//            print("NaverMap -isBookMarkTapped : \(isBookMarkTapped)")
//            if !isBookMarkTapped {
//                marker.mapView = uiView.mapView
//
//            }
//        }
//
//        for bookMarkedBottleShop in filterUserShopData() {
//            let bookMarkedMarker = NMFMarker()
//            // TODO: 아래 코드 위경도를 바꿔주면 서 for 문 생성
//            bookMarkedMarker.position = NMGLatLng(
//                lat: bookMarkedBottleShop.location.latitude,
//                lng: bookMarkedBottleShop.location.longitude)
//            bookMarkedMarker.captionRequestedWidth = 100 // 마커 캡션 너비 지정
//            bookMarkedMarker.captionText = bookMarkedBottleShop.shopName
//            bookMarkedMarker.captionMinZoom = 10
//            bookMarkedMarker.captionMaxZoom = 17
//
//            // MARK: - 마커 이미지 변경
//            bookMarkedMarker.iconImage = NMFOverlayImage(name: bookMarkedBottleShop.isRegister ? "MapMarker.fill" : "MapMarker")
//            bookMarkedMarker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
//            bookMarkedMarker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
//
//            // MARK: - 마커 터치 핸들러
//            bookMarkedMarker.touchHandler = { (overlay) -> Bool in
//                //                print("marker touched")
//                currentShopId = bookMarkedBottleShop.id
//                showMarkerDetailView = true
//
//                // 마커 터치 시 마커 아이콘 크기 변경
//                if bookMarkedBottleShop.isRegister {
//                    bookMarkedMarker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker_tapped" : "MapMarker.fill")
//                } else {
//                    // TODO: isRegister == false일 때 이미지 추가/수정
//                    bookMarkedMarker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker" : "MapMarker")
//                }
//
//                bookMarkedMarker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
//                bookMarkedMarker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
//
//                /*
//                 let coord = NMGLatLng(lat: coord.0, lng: coord.1)
//                 let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
//                 cameraUpdate.animation = .fly
//                 cameraUpdate.animationDuration = 1
//                 uiView.mapView.moveCamera(cameraUpdate)
//
//                 */
//
//                // 마커 터치 시 해당 마커 좌표로 카메라 이동
//                let markerPosition = NMGLatLng(lat: bookMarkedMarker.position.lat, lng: bookMarkedMarker.position.lng)
//                let cameraUpdate = NMFCameraUpdate(scrollTo: markerPosition)
//                cameraUpdate.animation = .fly
//                cameraUpdate.animationDuration = 1
//                uiView.mapView.moveCamera(cameraUpdate)
//
//                return true
//            }
//            print("NaverMap -isBookMarkTapped : \(isBookMarkTapped)")
//            //                        bookMarkedMarker.mapView = uiView.mapView
//            if isBookMarkTapped {
//                bookMarkedMarker.mapView = uiView.mapView
//            }
//        }
        
    }
}
