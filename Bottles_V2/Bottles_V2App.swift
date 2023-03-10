//
//  Bottles_V2App.swift
//  Bottles_V2
//
//  Created by mac on 2023/01/17.
//

import SwiftUI
import UIKit
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseFirestore
import FirebaseMessaging

import FBSDKCoreKit
@main
struct Bottles_V2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var userDataStore = UserStore()
    @ObservedObject var bottleDataStore = BottleDataStore()
    @ObservedObject var shopDataStore = ShopDataStore()
    @ObservedObject var shopNoticeDataStore = ShopNoticeDataStore()
    @ObservedObject var reservationDataStore = ReservationDataStore()
    @ObservedObject var cartStore = CartStore()
    @StateObject var authStore = AuthStore()
    // coreData
    @StateObject var dataController = DataController()
    

    init() {
//        FirebaseApp.configure()


        KakaoSDK.initSDK(appKey: "f2abf38572d20d5dde71ea5c33a02c07")
    }
    
    var body: some Scene {
        
        WindowGroup {
            //            TotalLoginView()
            //               .environmentObject(UserStore()).environmentObject(googleLoginViewModel)
            //                .onOpenURL(perform: { url in
            //                    if AuthApi.isKakaoTalkLoginUrl(url) {
            //                        AuthController.handleOpenUrl(url: url)
            //                   }
            //                })
            //            MainTabView()
            // coreData
            //                .environment(\.managedObjectContext, dataController.container.viewContext)
            
            
            LaunchView()
            // coreData
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(authStore)
                .environmentObject(bottleDataStore)
                .environmentObject(shopDataStore)
                .environmentObject(shopNoticeDataStore)
                .environmentObject(reservationDataStore)
                .environmentObject(userDataStore)
                .environmentObject(cartStore)
                .environmentObject(appDelegate)
                .task {
//                    userDataStore.readUser(userId: authStore.currentUser?.email ?? "")
//                    userDataStore.getUserDataRealTime(userId: authStore.currentUser?.email ?? "")
//                    cartStore.readCart(userEmail: authStore.currentUser?.email ?? "")
                    await shopDataStore.getAllShopData()
                    await bottleDataStore.getAllBottleData()
                    await reservationDataStore.readReservation()
                }
            // MARK: - AccentColor ??????
                .accentColor(Color("AccentColor"))
        }
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    //published property: ????????????????????? ????????? ??? Data-driven?????? ??????????????? ??????.
    @Published var openedFromNotification: Bool = false
    // ?????? ????????????
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Use Firebase library to configure APIs
        // ?????????????????? ??????
        FirebaseApp.configure()
        FBSDKCoreKit.ApplicationDelegate.shared.application(
                   application,
                   didFinishLaunchingWithOptions: launchOptions
               )
        // ?????? ?????? ??????
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // ????????? ?????????
        Messaging.messaging().delegate = self
        
        
        // ?????? ??????????????? ??????
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // fcm ????????? ?????? ????????? ???
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("?????????????????? ????????? ???: \(userInfo)")
        
        if let viewType = userInfo["viewType"] as? String {
            
        }
    }
    
    
    func application( app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
}


extension AppDelegate : MessagingDelegate {
    
    // fcm ?????? ????????? ????????? ???
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - ?????? ????????? ?????????.")
        print("AppDelegate - Firebase registration token: \(String(describing: fcmToken))")
        
        //UserStore ????????? fcmToken??? ??? ??????
        UserStore.shared.fcmToken = fcmToken
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // MARK: ?????? active??? ??? notification??? ?????? ?????? ( willPresent )
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        //openedFromNotification = true
        print("?????????????????? ?????? ?????? ????????? ?????? : \(userInfo)")
        completionHandler([.banner, .sound, .badge])
    }
    
    // MARK: push notification click?????? ??????( didReceive )
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if UIApplication.shared.applicationState == .active {
                // ?????? foreground??? ?????? ?????? ??????
            sleep(1);
            openedFromNotification = true;
        } else {
               
            //????????? ?????? ?????? ???????????? ?????? ???, ???????????? ??? 3?????? ?????? ??? 1??? ?????? ?????? ????????? ???????????? ??????.
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation {
                    self.openedFromNotification = true
                }
            }
        }
        
        print("?????????????????? ????????? ??? : \(userInfo)")
        guard let viewType = userInfo["viewType"] as? String else {
            print("viewType?????? ???????????? ??????..")
            return
        }
        
        completionHandler()
    }
    
}
