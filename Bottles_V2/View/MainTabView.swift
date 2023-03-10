//
//  MainTapView.swift
//  Bottles_V2
//
//  Created by 서찬호 on 2023/01/18.
//

import SwiftUI

enum Destination: Hashable {
    case bottleShop
    case bottle
    case cart
    case pickUpList
    case setting
}

struct MainTabView: View {
    @EnvironmentObject private var delegate: AppDelegate
    //    @EnvironmentObject var sessionManager : SessionManager
    @EnvironmentObject var shopDataStore: ShopDataStore
    @EnvironmentObject var bottleDataStore: BottleDataStore
    @EnvironmentObject var reservationDataStore: ReservationDataStore
    @EnvironmentObject var userDataStore: UserStore
    @EnvironmentObject var cartStore: CartStore
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var shopNoticeDataStore: ShopNoticeDataStore

    //    let user: AuthUser
    
    @State var selection: Int = 1
    @State private var rootSection1: Bool = false
    @State private var rootSection2: Bool = false
    @State private var rootSection3: Bool = false
    @State private var rootSection4: Bool = false
    
    @State private var isActive = false
    @State private var isloading = true
    
    var selectionBinding: Binding<Int> { Binding (
        get: {
            self.selection
        },
        set: {
            if $0 == self.selection && rootSection1 {
                rootSection1 = false
            }
            if $0 == self.selection && rootSection2 {
                rootSection2 = false
            }
            if $0 == self.selection && rootSection3 {
                rootSection3 = false
            }
            if $0 == self.selection && rootSection4 {
                rootSection4 = false
            }
            self.selection = $0
        }
    )}
    
    var body: some View {
            TabView(selection: selectionBinding) {
                MapView(root: $rootSection1).tabItem {
                    Image(selection == 1 ? "Maptabfill" : "Map_tab")
                    Text("주변")
                }.tag(1)
                BookMarkView(root: $rootSection2).tabItem {
                    Image(selection == 2 ? "BookMark_tab_fill" : "BookMark_tab")
                    Text("북마크")
                }.tag(2)
                NotificationView(root: $rootSection3).tabItem {
                    Image(selection == 3 ? "Notification_tab_fill" : "Notification_tab")
                    Text("알림")
                }.tag(3)
                MyPageView(root: $rootSection4, selection: $selection).tabItem {
                    Image(selection == 4 ? "MyPage_tab_fill" : "MyPage_tab")
                    Text("MY")
                }.tag(4)
            }
            .toolbarBackground(Color.white, for: .tabBar)
            .sheet(isPresented: $delegate.openedFromNotification, onDismiss: didDismiss) {
                NotificationView(root: $rootSection3)
            }
            .task {
                userDataStore.readUser(userId: authStore.currentUser?.email ?? "")
                cartStore.readCart(userEmail: authStore.currentUser?.email ?? "")
                shopNoticeDataStore.getAllShopNoticeDataRealTime()
            }
    }
    
    func didDismiss(){
        delegate.openedFromNotification = false
    }
}


//
//struct TabButtonModifier: ViewModifier {
//    func body(image: Image) -> some View {
//        image
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 20)
//    }
//}

