//
//  AgoraRtmTokenManager.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 02.04.2022.
//

import Foundation

class AgoraTokenManager: Networking<UserEndpoint> {
    
    // MARK: Constant
    
    static let shared = AgoraTokenManager()
    
    // MARK: Private Constant
    
    
    private(set) var rtmToken: String = ""
    private(set) var chatToken: String = ""
    
    // MARK: Private Variable
    private var userDefaultsManager = DefaultsManager()
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Function
    
    /// Forces rtm token update. Should be used to get the token for the first time calling RtmKit's login.
    ///
    /// Assuming should not be called afterwards because AgoraRtmTokenManager's token instance variable should contain already updated token on expiring existing token.
    /// - Parameter completion: returns result with token or error.
    func fetchRTMToken(completion: ((Result<String, Error>) -> Void)?) {
        requestString(endpoint: UserEndpoint.rtmToken) { [weak self] result in
            switch result {
            case .success(let rtmToken):
                self?.rtmToken = rtmToken
                completion?(.success(rtmToken))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    /// Forces chat token update. Should be used to get the token for Agora Chat SDK login
    ///
    /// Assuming should not be called afterwards because token instance variable should contain already updated token on expiring existing token.
    /// - Parameter completion: returns result with token or error.
    func fetchChatToken(completion: ((Result<String, Error>) -> Void)?) {
        guard chatToken.isEmpty else {
            completion?(.success(chatToken))
            return
        }
        requestString(endpoint: UserEndpoint.chatToken) { [weak self] result in
            switch result {
            case .success(let chatToken):
                self?.chatToken = chatToken
                completion?(.success(chatToken))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func clearToken() {
        rtmToken = ""
        chatToken = ""
    }
}
