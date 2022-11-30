//
//  ChatMembersViewController.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 20.02.2022.
//

import UIKit
import AgoraChat
import ProgressHUD

open class ChatMembersViewController: UIViewController, IAlertHelper {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    var chatId: String?
    var room: AgoraChatroom?
    var audioRoom: Room?
    var chatMembers: [RoomMember]?
    var mutedMembersUsernames: [String] = []
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupUI() {
        self.title = "Chat members"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: Private Function
    
    private func fetchData() {
        ProgressHUD.show()
        fetchChatMembers { result in
            switch result {
            case .success(let userNames):
                self.chatMembers = self.audioRoom?.members?.filter({ userNames.contains($0.username) })
                self.fetchMutedMembers()
            case .failure(let error):
                ProgressHUD.dismiss()
                self.presentOkAlert(error.localizedDescription)
            }
        }
     
    }
    
    private func fetchChatMembers(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let chatId = chatId else { return }

        AgoraChatClient.shared().roomManager.getChatroomMemberListFromServer(withId: chatId, cursor: nil, pageSize: 20) { agoraResult, agoraChatError in
            if let userNames = agoraResult?.list as? [String] {
                completion(.success(userNames))
            }
        }
    }
    
    private func fetchMutedMembers() {
        guard let chatId = chatId else { return }

        AgoraChatClient.shared().roomManager.getChatroomMuteListFromServer(withId: chatId, pageNumber: 0, pageSize: 20) { agoraResult, agoraChatError in
            if let mutedUserNames = agoraResult {
                self.mutedMembersUsernames.append(contentsOf: mutedUserNames)
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
        }
    }
    
    private func muteMember(with username: String, muteMilliseconds: Int) {
        guard let chatId = chatId else { return }
        AgoraChatClient.shared().roomManager.muteMembers([username], muteMilliseconds: muteMilliseconds, fromChatroom: chatId) { chatroom, agoraError in
            if let error = agoraError {
                print(error)
            } else {
                self.mutedMembersUsernames.append(username)
                self.tableView.reloadData()
            }
        }
    }
    
    private func unmuteMember(with username: String) {
        guard let chatId = chatId else { return }
        AgoraChatClient.shared().roomManager.unmuteMembers([username], fromChatroom: chatId) { chatroom, agoraError in
            if let error = agoraError {
                print(error)
            } else {
                if let index = self.mutedMembersUsernames.firstIndex(of: username) {
                    self.mutedMembersUsernames.remove(at: index)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    private func presentMuteTimeActionSheet(with username: String) {
        let hourAction = Action(target: nil, selector: nil, title: "1 hour", style: .default, handler: {
            self.muteMember(with: username, muteMilliseconds: 3600000)
        })
        
        let dayAction = Action(target: nil, selector: nil, title: "1 day", style: .default, handler: {
            self.muteMember(with: username, muteMilliseconds: 86400000)
        })
        
        let foreverAction = Action(target: nil, selector: nil, title: "Forever", style: .default, handler: {
            self.muteMember(with: username, muteMilliseconds: Int.max)
        })
        
        let cancelAction = Action(target: nil, selector: nil, title: "Cancel", style: .cancel, handler: { })
        
        self.presentAlert(style: .actionSheet, title: "", message: "For how long do you want to block \(username) ?", actions: [hourAction, dayAction, foreverAction, cancelAction], completion: nil)
    }
}

// MARK: - TableView Delegate & DataSource

extension ChatMembersViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMembers?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMemberCell.identifier, for: indexPath) as! ChatMemberCell
        guard let member = chatMembers?[indexPath.row] else { return cell }
        let isMutedMember = mutedMembersUsernames.contains(member.username)
        cell.configureCell(name: member.associatedUser?.fullName ?? "-", username: member.username, avatar: member.associatedUser?.avatar, isMuted: isMutedMember)
        cell.muteUnmuteActionCallback = {
            if !isMutedMember {
                self.presentMuteTimeActionSheet(with: member.username)
            } else {
                self.unmuteMember(with: member.username)
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
