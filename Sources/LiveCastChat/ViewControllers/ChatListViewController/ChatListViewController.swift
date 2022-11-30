//
//  ChatListViewController.swift
//  LiveCast
//
//  Created by Nik on 23.09.2022.
//

import UIKit
import AgoraChat
import ProgressHUD
//import EmptyStateKit

open class ChatListViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    var chats: [AgoraChatConversation] = []
    var presence: [AgoraChatPresence] = []
    var users: [AgoraChatUserInfo] = []
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchConversations()
    }
        
    func setupUI() {
        self.title = "Chats"
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.emptyState.dataSource = self
//        tableView.emptyState.delegate = self
//        tableView.emptyState.format.buttonWidth = 150
//        tableView.emptyState.format.buttonColor = UIColor.accentColor
//        tableView.emptyState.format.verticalMargin = -100
//        tableView.emptyState.format.titleAttributes = [.font: UIFont.systemFont(ofSize: 26, weight: .semibold), .foregroundColor: UIColor.accentColor]
//        tableView.emptyState.format.descriptionAttributes = [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.lightGray]
//        tableView.emptyState.format.buttonAttributes = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: UIColor.white]
    }
    
    func updateEmptyStates() {
//        if chats.isEmpty {
//            tableView.emptyState.show(State.noChats)
//        } else {
//            tableView.emptyState.hide()
//        }
    }
    
    func fetchConversations() {
        ProgressHUD.show()
        AgoraChatClient.shared().chatManager.getConversationsFromServer({ converstaions, error in
            ProgressHUD.dismiss()
            if let error = error {
//                self.showAlert(withTitle: "Error", andMessage: error.errorDescription, actionHandler: nil)
            } else {
                self.chats = converstaions ?? []
                self.subscribePresence()
                self.fetchUsers()
                self.updateEmptyStates()
            }
        })
    }
    
    func subscribePresence() {
        AgoraChatClient.shared().presenceManager.subscribe(chats.compactMap({ $0.conversationId }), expiry: 500, completion: { presence, error in
            self.presence = presence ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func fetchUsers() {
        AgoraChatClient.shared().userInfoManager.fetchUserInfo(byId: chats.compactMap({ $0.conversationId }),completion: { users, error in
            for item in users ?? [:] {
                print(item.value)
                if let userInfo = item.value as? AgoraChatUserInfo {
                    self.users.append(userInfo)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}

// MARK: - TableView Delegate & DataSource

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.identifier, for: indexPath) as! ChatListCell
        let chat = chats[indexPath.row]
        let status = presence.first(where: { $0.publisher == chat.conversationId })?.statusDetails?.first?.status ?? 0
        let avatar = users.first(where: { $0.userId == chat.conversationId })?.avatarUrl

        cell.configureCell(username: chat.conversationId, lastMessage: chat.latestMessage?.messageText() ?? "", date: chat.latestMessage?.messageDate() ?? "-", avatar: avatar, isOnline: status)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = chats[indexPath.row]
        let userInfo = users[indexPath.row]
        let chatVC = SingleChatViewController(userId: chat.conversationId, roomName: chat.conversationId, chatUserInfo: userInfo, chatMessages: [])
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - EmptyStateDataSource

//extension ChatListViewController: EmptyStateDataSource {
//
//    func imageForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> UIImage? {
//        return State.noChats.image
//    }
//
//    func titleForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
//        return State.noChats.title
//    }
//
//    func descriptionForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
//        return State.noChats.description
//    }
//
//    func titleButtonForState(_ state: CustomState, inEmptyState emptyState: EmptyState) -> String? {
//        return State.noChats.titleButton
//    }
//}

// MARK: - EmptyStateDelegate
//FIXME: EmptyState
//extension ChatListViewController: EmptyStateDelegate {
//    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
//        NavigationManager.shared.showInviteToChatViewController()
//    }
//}
