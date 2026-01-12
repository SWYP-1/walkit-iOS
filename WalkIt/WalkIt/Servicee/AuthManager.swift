//
//  Untitled.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import Combine
import KakaoSDKAuth
import KakaoSDKUser
import NidThirdPartyLogin
import AuthenticationServices

enum AuthState {
    case LogOut
    case LogIn
    case SignUp
}

class AuthManager: AuthManagerProtocol, ObservableObject {
    static let shared = AuthManager()
    private let serverManager = ServerManager.shared
    @Published var errorMessage: String?
    @Published var authSate: AuthState = .LogOut
    @Published var authToken: LoginResponse?
    @Published var isShowingProgress: Bool = false
    
    var kakaoToken: OAuthToken?
    var naverToken: AccessToken?
    var appleCredential: ASAuthorizationAppleIDCredential?
    @Published var continuousAttendance: Int = 1

    var nickname: String = ""
    var email: String = ""
    var name: String = ""
    var loginType = ""
    
    private let defaults = UserDefaults.standard
    private let lastOpenedKey = "MyPage.lastOpenedDate"
    private let streakKey = "MyPage.streakCount"
    init() {
        let attendanceDict = defaults.dictionary(forKey: "attendanceDict") as? [String: [String: Any]] ?? [:]
        let userId = String(UserManager.shared.userId ?? 0)

        if let userInfo = attendanceDict[userId],
           let streak = userInfo["streak"] as? Int {
            continuousAttendance = streak
        } else {
            continuousAttendance = 1
        }
    }
    
    func reset() {
        errorMessage = nil
        authSate = .LogOut
        authToken = nil
        isShowingProgress = false
        
        kakaoToken = nil
        naverToken = nil
        appleCredential = nil
        continuousAttendance = 1

        nickname = ""
        email = ""
        name = ""
        loginType = ""
    }

    
    func kakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    Task {
                        self?.isShowingProgress = true
                        do {
                            self?.authToken = try await self?.serverManager.login(with: "kakao", token: oauthToken?.accessToken ?? "")
                            debugPrint("서버 토큰: \(self?.authToken?.accessToken ?? "")")
                            let result = await self?.isUsers()
                            self?.isShowingProgress = false
                            self?.getKakaoInfo()
                            if(result ?? false) {
                                self?.authSate = .LogIn
                            } else {
                                self?.authSate = .SignUp
                            }
                            self?.errorMessage = nil
                        } catch {
                            self?.isShowingProgress = false
                        }
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    Task {
                        self?.isShowingProgress = true
                        do {
                            self?.authToken = try await self?.serverManager.login(with: "kakao", token: oauthToken?.accessToken ?? "")
                            debugPrint("서버 토큰: \(self?.authToken?.accessToken ?? "")")
                            let result = await self?.isUsers()
                            self?.isShowingProgress = false
                            self?.getKakaoInfo()
                            if(result ?? false) {
                                self?.authSate = .LogIn
                            } else {
                                self?.authSate = .SignUp
                            }
                            self?.errorMessage = nil
                        } catch {
                            self?.isShowingProgress = false
                        }
                    }
                }
            }
        }
    }
    
    func getKakaoInfo() {
        UserApi.shared.me { user, error in
            if let error = error {
                debugPrint("유저 정보 요청 실패:", error)
                return
            }
            guard let user = user else { return }
            
            self.nickname = user.kakaoAccount?.profile?.nickname ?? ""
            self.email = user.kakaoAccount?.email ?? ""
            self.name = user.kakaoAccount?.name ?? ""
            self.loginType = "카카오"
            
        }
    }
    
    func naverLogin() async {
        do {
            let accessToken = try await requestNaverLogin()
            if accessToken.isExpired {
                self.errorMessage = "네이버 엑세스 토큰이 만료되었습니다."
            } else {
                self.isShowingProgress = true
                self.authToken = try await self.serverManager.login(with: "naver", token: accessToken.tokenString)
                debugPrint("서버 토큰: \(self.authToken?.accessToken ?? "")")
                let result = await self.isUsers()
                self.isShowingProgress = false
                getNaverInfo()
                if(result) {
                    self.authSate = .LogIn
                } else {
                    self.authSate = .SignUp
                }
                self.errorMessage = nil
            }
        } catch {
            self.isShowingProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func requestNaverLogin() async throws -> AccessToken {
        return try await withCheckedThrowingContinuation { continuation in
            NidOAuth.shared.requestLogin { result in
                switch result {
                case .success(let loginResult):
                    continuation.resume(returning: loginResult.accessToken)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
        
    func getNaverInfo() {
        guard let accessToken = NidOAuth.shared.accessToken?.tokenString else {
            debugPrint("accessToken 없음")
            return
        }

        NidOAuth.shared.getUserProfile(accessToken: accessToken) { result in
            switch result {
            case .success(let profile):
                self.name = profile["name"] ?? ""
                self.nickname = profile["nickname"] ?? ""
                self.email = profile["email"] ?? ""
                self.loginType = "네이버"
                
            case .failure(let error):
                debugPrint("프로필 요청 실패:", error)
            }
        }
    }

    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let identityToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: identityToken, encoding: .utf8)
                else { return }
                
                Task { @MainActor in
                    self.isShowingProgress = true
                    self.authToken = try await self.serverManager.login(with: "apple", token: idTokenString)
                    debugPrint("서버 토큰: \(self.authToken?.accessToken ?? "")")
                    let result = await self.isUsers()
                    if(result) {
                        self.isShowingProgress = false
                        self.authSate = .LogIn
                    } else {
                        self.isShowingProgress = false
                        self.authSate = .SignUp
                    }
                }
                
                self.appleCredential = appleIDCredential
                self.errorMessage = nil
            } else {
                self.isShowingProgress = false
                self.errorMessage = "애플 로그인 인증 정보가 올바르지 않습니다."
            }
        case .failure(let error):
            self.isShowingProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func isUsers() async -> Bool {
        await UserManager.shared.getUserInfo()
        if(UserManager.shared.nickname == "") { return false }
        updateAttendanceIfNeeded(for: String(UserManager.shared.userId ?? 0))
        let result = await UserManager.shared.getGoals()
        return result
    }
    
    func updateAttendanceIfNeeded(for userId: String, now: Date = Date()) {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let todayTimestamp = startOfToday.timeIntervalSince1970

        var attendanceDict = defaults.dictionary(forKey: "attendanceDict") as? [String: [String: Any]] ?? [:]

        // 기본값도 TimeInterval 기준
        var userInfo = attendanceDict[userId] ?? [
            "streak": 1,
            "lastDate": todayTimestamp
        ]

        let lastTimestamp = userInfo["lastDate"] as? TimeInterval ?? todayTimestamp
        let lastDate = Date(timeIntervalSince1970: lastTimestamp)

        var streak = userInfo["streak"] as? Int ?? 1

        let startOfLast = calendar.startOfDay(for: lastDate)

        if startOfToday != startOfLast {
            let days = calendar.dateComponents([.day], from: startOfLast, to: startOfToday).day ?? 0

            if days == 1 {
                streak += 1
            } else if days > 1 {
                streak = 1
            }
        } else {
            // 오늘 이미 체크됨
            return
        }

        userInfo["streak"] = streak
        userInfo["lastDate"] = todayTimestamp
        attendanceDict[userId] = userInfo
        defaults.set(attendanceDict, forKey: "attendanceDict")

        continuousAttendance = streak
    }


 
    func handleCredential(_ credential: ASAuthorizationAppleIDCredential) {
            if let email = credential.email {
                self.email = email
            }

            if let fullName = credential.fullName {
                self.name = [fullName.familyName, fullName.givenName]
                    .compactMap { $0 }
                    .joined()
            }
        }
}
