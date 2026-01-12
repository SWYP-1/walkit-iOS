//
//  WalkItApp.swift
//  WalkIt
//
//  Created by 조석진 on 12/5/25.
//

import SwiftUI
import KakaoMapsSDK
import KakaoSDKCommon
import NidThirdPartyLogin
import KakaoSDKAuth
import FirebaseCore
import FirebaseMessaging

@main
struct WalkItApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    init() {
#if !targetEnvironment(simulator)
        if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        } else {
            fatalError("Kakao App Key is missing in Info.plist")
        }
#endif
        
    }
    
    @StateObject var signUpViewModel = SignUpViewModel()
    var body: some Scene {
        WindowGroup {
            switch(authManager.authSate) {
            case .LogIn:
                MainTabView()
            case .LogOut, .SignUp:
                NavigationStack(path: $signUpViewModel.path) {
                    ZStack {
                        LoginView(vm: LoginViewModel())
                            .onOpenURL { url in
                                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                                    _ = AuthController.handleOpenUrl(url: url)
                                } else {
                                    _ = NidOAuth.shared.handleURL(url)
                                }
                            }
                        if(authManager.authSate == .SignUp) {
                            Color.black.opacity(0.6)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    authManager.authSate = .LogOut
                                }
                            VStack {
                                Spacer()
                                SignUpView(vm: signUpViewModel, showSignUpView: $authManager.authSate)
                                    .frame(height: UIScreen.main.bounds.height * 0.5)
                                    .transition(.move(edge: .bottom))
                                    .zIndex(1)
                                    .navigationDestination(for: LoginRoute.self) { route in
                                        switch route {
                                        case .CreateCharacterView: CreateCharacterView(vm: signUpViewModel)
                                        case .BirthYearView: BirthYearView(vm: signUpViewModel)
                                        case .GoalSettingView: GoalSettingView(vm: signUpViewModel)
                                        }
                                    }
                                
                            }
                        }
                        if(signUpViewModel.isShowingProgress || authManager.isShowingProgress) {
                            Color.black.opacity(0.6)
                                .ignoresSafeArea()
                            ProgressView()
                        }
                    }
                    
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if !targetEnvironment(simulator)
        if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String {
            SDKInitializer.InitSDK(appKey: kakaoAppKey)
        } else {
            fatalError("Kakao App Key is missing in Info.plist")
        }
        NidOAuth.shared.initialize(appName: "walkit", clientId: "pqYCAiLlppKm8_M3VnNA", clientSecret: "V_NACUpG7I", urlScheme: "com.swyp.WalkIt")
        NidOAuth.shared.setLoginBehavior(.appPreferredWithInAppBrowserFallback)
        
        FirebaseApp.configure()
        
        // 알림 델리게이트/메시징 델리게이트 설정
        UNUserNotificationCenter.current().delegate = self
           Messaging.messaging().delegate = self

           // 현재 알림 권한 상태 확인
           UNUserNotificationCenter.current().getNotificationSettings { settings in
               switch settings.authorizationStatus {
               case .authorized, .provisional:
                   DispatchQueue.main.async {
                       application.registerForRemoteNotifications()
                   }
               case .notDetermined, .denied, .ephemeral:
                   break

               @unknown default:
                   break
               }
           }
#endif
        return true
    }
    

    
    // APNs 등록 성공: 디바이스 토큰 수신
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // FCM에 APNs 토큰 연결
        Messaging.messaging().apnsToken = deviceToken

        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        debugPrint("APNs deviceToken: \(tokenString)")

        // APNs 토큰이 설정된 후 FCM 토큰 요청
        Messaging.messaging().token { token, error in
            if let error = error {
                debugPrint("FCM token fetch after APNs set error: \(error)")
            } else {
                debugPrint("FCM token after APNs set: \(token ?? "nil")")
                if let token {
                    UserDefaults.standard.set(token, forKey: "fcmToken")
                    // self.sendFCMTokenToServer(token: token)
                }
            }
        }
    }
    
    // APNs 등록 실패
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register for remote notifications: \(error)")
    }
    
    // FCM 토큰 갱신/수신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        debugPrint("messaging didReceiveRegistrationToken: \(fcmToken ?? "nil")")
        guard let token = fcmToken else { return }
        UserDefaults.standard.set(token, forKey: "fcmToken")
        // 로그인 상태라면 서버로 전송
        // sendFCMTokenToServer(token: token)
    }
    
    // 포그라운드에서도 배너/사운드/배지 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("📩 withCompletionHandler 호출됨")
        debugPrint("📦 userInfo:", notification)
        
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    // 선택한 알림에 대한 응답 처리(필요 시 구현)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림 탭 시 라우팅/처리 로직 추가 가능
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        debugPrint("📩 didReceiveRemoteNotification 호출됨")
        debugPrint("📦 userInfo:", userInfo)
        
        let title = (userInfo["title"] as? String) ?? "알림"
        let body = (userInfo["body"] as? String) ?? "내용 없음"
        
        // 로컬 알림 만들기
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: nil) // 즉시 표시
        
        UNUserNotificationCenter.current().add(request)
        
        completionHandler(.newData)
        
    }

    
    // 서버 전송 헬퍼(선택)
    private func sendFCMTokenToServer(token: String) {
        guard let accessToken = AuthManager.shared.authToken?.accessToken else { return }
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let fcm = FCMToken(id: 0, token: token, deviceType: "iOS", deviceId: deviceId)
        Task {
            do {
                _ = try await ServerManager.shared.postFCMToken(token: accessToken, fcmToken: fcm)
                debugPrint("FCM token sent to server.")
            } catch {
                debugPrint("Failed to send FCM token to server: \(error)")
            }
        }
    }
}
