//
//  NaverMap.swift
//  Bottles_V2
//
//  Created by 강창현 on 2023/01/20.
//

import SwiftUI
import NMapsMap

// MARK: - 마커 더미 데이터 생성
//struct Marker: Identifiable {
//    let id: String
//    let latitude: Double
//    let longitude: Double
//}
//
//class MarkerStore: ObservableObject {
//    var markers: [Marker] = []
//
//    init() {
//        markers = [
//            Marker(id: UUID().uuidString, latitude: 37.5670135, longitude: 126.9783740, bookmark),
//            Marker(id: UUID().uuidString, latitude: 37.6670135, longitude: 126.9883740),
//            Marker(id: UUID().uuidString, latitude: 37.7670135, longitude: 126.9983740),
//            Marker(id: UUID().uuidString, latitude: 37.3670135, longitude: 126.9683740),
//            Marker(id: UUID().uuidString, latitude: 37.4670135, longitude: 126.9583740)
//        ]
//    }
//}

struct NaverMap: UIViewRepresentable {
    
    @Binding var showMarkerDetailView: Bool
    var coord: (Double, Double)
    //    var markers: [Marker]
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coord, $showMarkerDetailView)
    }
    
    init(_ coord: (Double, Double), _ showMarkerDetailView: Binding<Bool>
    ) {
        self.coord = coord
        self._showMarkerDetailView = showMarkerDetailView
        
    }
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate {
        
        @Binding var showMarkerDetailView: Bool
        var coord: (Double, Double)
        
        init(_ coord: (Double, Double), _ showMarkerDetailView: Binding<Bool>) {
            self.coord = coord
            self._showMarkerDetailView = showMarkerDetailView
        }
        
        
        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
            print("카메라 변경 - reason: \(reason)")
        }
        
        func mapView(_ mapView: NMFMapView, cameraIsChangingByReason reason: Int) {
            // MARK: - 카메라 변경 Reason 번호 별 차이
            /// 0 : 개발자의 코드로 화면이 움직였을 때
            /// -1 : 사용자의 제스처로 화면이 움직였을 때
            /// -2 : 버튼 선택으로 카메라가 움직였을 때
            /// -3 : 네이버 지도가 제공하는 위치 트래킹 기능으로 카메라가 움직였을 때
            print("카메라 변경 - reason: \(reason)")
            
            // MARK: - 카메라 위치 변경 시 위도/경도 값 받아오기
            let cameraPosition = mapView.cameraPosition
            print("카메라 위치 변경 : \(cameraPosition.target.lat)", "\(cameraPosition.target.lng)")
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
        
        // MARK: - 줌 레벨 제한
        view.mapView.zoomLevel = 13 // 기본 카메라 줌 레벨
        view.mapView.minZoomLevel = 10 // 최소 줌 레벨
        
        let locationOverlay = view.mapView.locationOverlay
        
        // MARK: - 현 위치 추적 버튼
        view.showLocationButton = true
        
        view.showCompass = false
        view.showZoomControls = false
        let cameraPosition = view.mapView.cameraPosition
        
        // MARK: - 마커 생성
        //        for shopMarker in markers {
        let marker = NMFMarker()
        //            marker.position = NMGLatLng(lat: shopMarker.latitude, lng: shopMarker.longitude)
        // 임시 마커(서울시청)
        marker.position = NMGLatLng(lat: 37.56668, lng: 126.978415)
        marker.captionRequestedWidth = 100
        //            marker.captionText = foodCart.name
        marker.captionMinZoom = 12
        marker.captionMaxZoom = 16
        
        // MARK: - 마커 이미지 변경
        marker.iconImage = NMFOverlayImage(name: "MapMarker.fill")
        marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
        marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)
        
        // MARK: - 마커 터치 핸들러
        marker.touchHandler = { (overlay) -> Bool in
            print("marker touched")
            showMarkerDetailView.toggle()
            
            // 마커 터치 시 마커 아이콘 크기 변경
            marker.iconImage = NMFOverlayImage(name: showMarkerDetailView ? "MapMarker_tapped" : "MapMarker.fill")
            marker.width = CGFloat(NMF_MARKER_SIZE_AUTO)
            marker.height = CGFloat(NMF_MARKER_SIZE_AUTO)

            return true
        }
        
        marker.mapView = view.mapView
        
        // MARK: - NMFMapViewCameraDelegate를 상속 받은 Coordinator 클래스 넘겨주기
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        
        // MARK: - 지도 터치 시 발생하는 touchDelegate
        view.mapView.touchDelegate = context.coordinator
        //        }
        print("camera position: \(cameraPosition)")
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let coord = NMGLatLng(lat: coord.0, lng: coord.1)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 1
        uiView.mapView.moveCamera(cameraUpdate)
    }
}


