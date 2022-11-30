//
//  ChatViewController.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 14.02.2022.
//

import UIKit
import AgoraChat
import AlamofireImage
import GiphyUISDK

protocol ChatViewControllerDelegate: AnyObject {
    func didUpdateLastMessage(with message: ChatMessage, avatarUrl: URL?)
}

open class ChatViewController: MessagesViewController, IAlertHelper {
    
    // MARK: - UI
    
    private lazy var lazyMessagesCollectionView: MessagesCollectionView = {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.register(ChatTextMessageCell.self)
        messagesCollectionView.register(GifMessageCell.self)
        return messagesCollectionView
    }()
    
    private lazy var chatMembersButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(showChatMembersViewController))
        item.image = UIImage(systemName: "person.2.fill")
        return item
    }()
    
    private lazy var backButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(back))
        return item
    }()
    
    private lazy var chatDisabledLabel: UILabel = {
        let label = UILabel()
        label.text = chatDisabledByHostMessage
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        return control
    }()
    
    open override var messagesCollectionView: MessagesCollectionView {
         get {
             return lazyMessagesCollectionView
         }
         set {
             lazyMessagesCollectionView = newValue
         }
     }
        
    // MARK: - Private
    
    private var conversation: AgoraChatConversation
    
    private var roomName: String = ""
    private var chatId: String = ""
    private var isLoadingMore = false
    private lazy var messages = [ChatMessage]()
    private var channelUsers: [String: ChatMessageSender] = [:]
    private var room: AgoraChatroom?
    private var chatInitError: CustomError?
    
    var audioRoom: Room?
    weak var delegate: ChatViewControllerDelegate?

    private lazy var sender: ChatMessageSender = {
//        let avatarURLString = UserManager.user.currentUser?.avatar?.presignedUrl ?? ""
//        let avatarURL = URL(string: avatarURLString)
//        let output = ChatMessageSender(senderId: "\(UserManager.user.currentUser?.id ?? UUID().hashValue)", displayName: UserManager.user.currentUser?.fullName ?? "Me", profileImageURL: avatarURL)
        
        let avatarURLString = ""
        let avatarURL = URL(string: avatarURLString)
        let output = ChatMessageSender(senderId: "", displayName: "Me", profileImageURL: avatarURL)
        return output
    }()
    
    // MARK: - View Controller life cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        if let chatInitError = chatInitError {
            self.presentErrorAlert(chatInitError)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //FIXME: Setup IQKeyboardManager
        //IQKeyboardManager.shared.enable = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
     
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardListeners()
        messagesCollectionView.scrollToLastItem()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //IQKeyboardManager.shared.enable = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Init
    
    public init(chatId: String, roomName: String, chatMessages: [ChatMessage] = []) {
        self.conversation = (AgoraChatClient.shared().chatManager.getConversation(chatId, type: .chatRoom, createIfNotExist: true))!

        super.init(nibName: "ChatViewController", bundle: Bundle(for: type(of: self)))

        self.roomName = roomName
        self.messages = chatMessages
        self.chatId = chatId
        
        AgoraChatClient.shared().roomManager.joinChatroom(self.chatId) { [weak self] room, error in
            guard let room = room, error == nil else {
                print(error?.errorDescription ?? "Failed to join room")
                self?.chatInitError = CustomError(description: error?.errorDescription ?? "Failed to join room")
                return
            }
            
            var ext = self?.conversation.ext ?? [:]
            ext["subject"] = room.subject
            self?.conversation.ext = ext
            self?.room = room
            
           // AgoraChatClient.shared().roomManager?.add(self, delegateQueue: nil)
          //  AgoraChatClient.shared().chatManager?.add(self, delegateQueue: nil)
        }
        
        prefetchChat { }


        NotificationCenter.default.addObserver(self, selector: #selector(chatEnded),
                                               name: .init("endChat_notification"),
                                               object: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Action
    @objc func refresh(sender:AnyObject) {
        refreshControl.endRefreshing()
        loadMore()
    }
    
    // MARK: Private Action
    
    @objc private func showChatMembersViewController() {
        let chatMembersVC = ChatMembersViewController.instantiate(from: .chat)
        chatMembersVC.chatId = chatId
        chatMembersVC.room = room
        chatMembersVC.audioRoom = audioRoom
        self.navigationController?.pushViewController(chatMembersVC, animated: true)
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: Function
    
    func removeChatObservers() {
        AgoraChatClient.shared().roomManager.remove(self)
        AgoraChatClient.shared().chatManager.remove(self)
    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
        case .attributedText:
            let cell = messagesCollectionView.dequeueReusableCell(ChatTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .text:
            let cell = messagesCollectionView.dequeueReusableCell(ChatTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            let cell = messagesCollectionView.dequeueReusableCell(GifMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        default:
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    // MARK: - Private Function
    
    private func configureUI() {
        //FIXME: Setup navigation bar
//        if let room = audioRoom, let currentUser = UserManager.user.currentUser {
//            if room.hostUsername == currentUser.username {
//                navigationItem.setRightBarButtonItems([chatMembersButtonItem], animated: true)
//            }
//        }
        navigationItem.setLeftBarButton(backButtonItem, animated: true)
        navigationItem.title = roomName
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.titleView?.tintColor = .black
        navigationController?.navigationBar.tintColor = .accentColor
        messagesCollectionView.showsVerticalScrollIndicator = false
        
        messageInputBar.delegate = self
        configureMessageInputBar()
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            // set the vertical position of the Avatar for incoming messages so that the bottom of the Avatar
            // aligns with the bottom of the Message
            layout.setMessageIncomingAvatarPosition(.init(vertical: .messageBottom))
            
            // set the vertical position of the Avatar for outgoing messages so that the bottom of the Avatar
            // aligns with the `cellBottom`
            layout.setMessageOutgoingAvatarPosition(.init(vertical: .cellBottom))
        }
        
        refreshControl.endRefreshing()
        messagesCollectionView.alwaysBounceVertical = true
        setChatDisabledByHostLabel()
        setChatDisabledByHostLabel(hidden: true)
    }
    
    private func insertMessage(_ message: ChatMessage, shouldScroll: Bool = false) {
        guard !messages.contains(where: { $0.messageId == message.messageId }) else { return }
        let lastSectionVisible = isLastSectionVisible()
        let index = insertAndGetIndex(for: message)
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([index])
            // reload top label and avatar of nearby messages
            if index > 0 {
                messagesCollectionView.reloadSections([index - 1])
            }
            if index < messages.count - 2 {
                messagesCollectionView.reloadSections([index + 1])
            }
        }, completion: { [weak self] _ in
            DispatchQueue.main.async {
                guard shouldScroll && lastSectionVisible else { return }
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    private func insert(newMessages: [ChatMessage]) {
        guard !newMessages.isEmpty else { return }
        var mutableMessages = newMessages
        newMessages.forEach {
            if messages.contains($0), let index = mutableMessages.firstIndex(of: $0) {
                mutableMessages.remove(at: index)
            } else {
                messages.append($0)
            }
        }
        
        messages.sort { lhs, rhs in
            lhs.sentDate < rhs.sentDate
        }
        messagesCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.messagesCollectionView.scrollToLastItem()
        }
    }
    
    private func insertAndGetIndex(for message: ChatMessage) -> Int {
        if let last = messages.last, last.sentDate < message.sentDate {
            messages.append(message)
            return messages.count - 1
        }
        if let first = messages.first, first.sentDate > message.sentDate {
            messages.insert(message, at: 0)
            return 0
        }
        messages.append(message)
        messages.sort { lhs, rhs in
            lhs.sentDate < rhs.sentDate
        }
        return messages.firstIndex(of: message) ?? 0
    }
    
    private func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func configureMessageInputBar() {
        messageInputBar = GIfInputBarAccessoryView()
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholder = messageInputBarPlaceholderText
    }
    
    private func setChatDisabledByHostLabel() {
        messagesCollectionView.addSubview(chatDisabledLabel)
        
        NSLayoutConstraint.activate([
            chatDisabledLabel.widthAnchor.constraint(equalTo: messagesCollectionView.widthAnchor, multiplier: 0.8),
            chatDisabledLabel.heightAnchor.constraint(equalToConstant: 50),
            chatDisabledLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chatDisabledLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setChatDisabledByHostLabel(hidden shouldHide: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.transitionCrossDissolve], animations: {
            let alpha: CGFloat = shouldHide ? 0 : 1
            self.chatDisabledLabel.alpha = alpha
        }, completion: { [weak self] isFinished in
            guard let self = self else { return }
            guard isFinished else { return }
            
            self.chatDisabledLabel.isHidden = shouldHide
        })
    }
    
    @objc private func chatEnded() {
        back()
    }
}

// MARK: - Darkable
extension ChatViewController: Darkable {
    @objc var shouldDarkenBackground: Bool {
        return true
    }
    
    var viewToDarken: UIView? {
        return self.view
    }
    
    var darkeningAnimationDuration: CFTimeInterval {
        return 0.2
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    public func currentSender() -> SenderType {
        return sender
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = messages[indexPath.section]
        return message
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    public func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard let message = message as? ChatMessage else {
            assertionFailure()
            return nil
        }
        
        let sentDateString = shouldHideTimeAndSender(at: indexPath) ? "" : message.sentDate.prettyPrinted
        let sentDateAttrString = NSAttributedString(string: sentDateString, attributes: [
            .font : UIFont.systemFont(ofSize: 12, weight: .light)
        ])
        
        let senderNameString = isPreviousMessageSameSender(at: indexPath) ? "" : (message.sender.displayName + " • ")
        let senderNameAttrString = NSAttributedString(string: senderNameString, attributes: [
            .font : UIFont.systemFont(ofSize: 13, weight: .regular)
        ])
        
        let attrString = NSMutableAttributedString(attributedString: senderNameAttrString)
        attrString.append(sentDateAttrString)
        
        return attrString
    }
    
    public func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard !shouldHideTimeAndSender(at: indexPath) else { return 0 }
        return 15
    }
    
    public func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .clear
    }
    
    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.image = nil
        guard shouldShowAvatar(at: indexPath) else {
            avatarView.af.cancelImageRequest()
            avatarView.isHidden = true
            return
        }
        avatarView.isHidden = false

        guard let message = message as? ChatMessage,
              let messageSender = message.sender as? ChatMessageSender
        else {
            return
        }
        let currentUser = self.sender
//FIXME: Set avatar
//        if messageSender.senderId == currentUser.senderId {
//            if let userAvatar = UserManager.user.currentUser?.avatar,
//               let avatarURL = URL(string: userAvatar.presignedUrl) {
//                avatarView.af.setImage(withURL: avatarURL)
//            } else {
//                DispatchQueue.main.async {
//                    avatarView.image = LetterAvatarConfigurator.makeAvatar(with: currentUser.initials)
//                }
//            }
//        } else {
//            if let avatarURL = messageSender.profileImageURL {
//                avatarView.af.setImage(withURL: avatarURL)
//            } else {
//                DispatchQueue.main.async {
//                    avatarView.image = LetterAvatarConfigurator.makeAvatar(with: messageSender.initials)
//                }
//            }
//        }
    }
    
    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    private func shouldHideTimeAndSender(at indexPath: IndexPath) -> Bool {
        guard isPreviousMessageSameSender(at: indexPath) else { return false }
        return abs(messages[indexPath.section].sentDate.timeIntervalSince(messages[indexPath.section - 1].sentDate)) < 90
    }
    
    private func shouldShowAvatar(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return true }
        return messages[indexPath.section].sender.senderId != messages[indexPath.section + 1].sender.senderId
    }
}

extension ChatViewController {
    
    private func loadMore() {
        isLoadingMore = true
        refreshControl.beginRefreshing()

        let messageId = self.messages.last?.messageId ?? "-"
        conversation.loadMessagesStart(fromId: messageId,
                                       count: 20,
                                       searchDirection: .up,
                                       completion: { messagesa, error in
            self.refreshControl.endRefreshing()
            self.isLoadingMore = false
            if error != nil {
                print("Errors \(error?.errorDescription ?? "")")
            } else {
                if let messages = messagesa {
                    let messageKitMessages = messages.compactMap { msg -> ChatMessage? in
                        if let text = (msg.body as? AgoraChatTextMessageBody)?.text,
                           let messageData = text.data(using: .utf8) {
                            return try? JSONDecoder().decode(ChatMessage.self, from: messageData)
                        } else {
                            return nil
                        }
                    }
                    self.insert(newMessages: messageKitMessages)
                }
            }
        })
    }
    
    func prefetchChat(completion: @escaping () -> Void) {
        guard !isLoadingMore else { return }
        isLoadingMore = true
                
        conversation.loadMessagesStart(fromId: nil,
                                       count: 20,
                                       searchDirection: .up,
                                       completion: { messagesa, error in
            self.isLoadingMore = false
            if error != nil {
                print("Errors \(error?.errorDescription ?? "")")
            } else {
                if let messages = messagesa {
                    let messageKitMessages = messages.compactMap { msg -> ChatMessage? in
                        if let text = (msg.body as? AgoraChatTextMessageBody)?.text,
                           let messageData = text.data(using: .utf8) {
                            return try? JSONDecoder().decode(ChatMessage.self, from: messageData)
                        } else {
                            return nil
                        }
                    }
                    self.insert(newMessages: messageKitMessages)
                }
            }
        })
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = messageInputBarTextWhileSending
        
        inputBar.sendButton.stopAnimating()
        inputBar.inputTextView.placeholder = self.messageInputBarPlaceholderText
        
        for component in components {
            if let messageText = component as? String {
                let textAttributed = NSAttributedString(string: messageText,
                                                        attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0)])
                let messageKind = MessageKind.attributedText(textAttributed)
                var innerChatMessage = ChatMessage(sender: self.sender,
                                                   sentDate: Date(),
                                                   kind: messageKind,
                                                   text: messageText)
                
                if let messageData = try? JSONEncoder().encode(innerChatMessage) {
                    
                    guard let dataString = String(data: messageData, encoding: .utf8) else {
                        let error = CustomError(description: "Failed to create data string from ChatMessage in ChatViewController's didPressSendButton func")
                        self.presentErrorAlert(error)
                        return
                    }
                    
                    guard let agoraMessage = AgoraSDKHelper.initMessage(dataString,
                                                                  to: chatId,
                                                                        chatType: .chatRoom,
                                                                        messageExt: nil) else { return }
                    
                    AgoraChatClient.shared().chatManager.send(agoraMessage, progress: {_ in }) { [weak self] message, error in
                        if let error = error {
                            self?.presentOkAlert("Failed to send message. Error code: \(error.errorDescription ?? "-" )")
                            return
                        }
                        innerChatMessage.messageId = message?.messageId ?? ""
                        self?.insertMessage(innerChatMessage, shouldScroll: true)
                        self?.notifyAudioRoomAboutLastMessage()
                    }
                }
            }
        }
                
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
}

// MARK: - GIfInputBarAccessoryViewDelegate
extension ChatViewController: GIfInputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressMoreButtonWith attachments: [AttachmentManager.Attachment]) {
        //TODO: Need to configure logic
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressGifButtonWith attachments: [AttachmentManager.Attachment]) {
        let giphy = GiphyViewController()
        giphy.mediaTypeConfig = [.gifs, .stickers, .text, .emoji]
        giphy.theme = GPHTheme(type: .light)
        giphy.showConfirmationScreen = true
        giphy.delegate = self
        present(giphy, animated: true, completion: nil)
    }
}

// MARK: - GiphyDelegate
extension ChatViewController: GiphyDelegate {
    public func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia) {
        
        let gifURL = media.url(rendition: .fixedWidth, fileType: .gif)
        let gifExtension = GifAttachment(gifUrl: gifURL?.description ?? "-",
                                         gifWidth: media.images?.fixedWidth?.width ?? 0,
                                         gifHeight: media.images?.fixedWidth?.height ?? 0)
        
        giphyViewController.dismiss(animated: true, completion: nil)
        
        let messageKind = MessageKind.custom(gifExtension)
        let innerChatMessage = ChatMessage(sender: self.sender,
                                           sentDate: Date(),
                                           kind: messageKind,
                                           text: "",
                                           gifExtension: gifExtension)
        
        if let messageData = try? JSONEncoder().encode(innerChatMessage) {
            
            guard let dataString = String(data: messageData, encoding: .utf8) else {
                let error = CustomError(description: "Failed to create data string from ChatMessage in ChatViewController's didPressSendButton func")
                self.presentErrorAlert(error)
                return
            }
            
            guard let agoraMessage = AgoraSDKHelper.initMessage(dataString,
                                                          to: chatId,
                                                          chatType: .chatRoom,
                                                          messageExt: nil) else { return }
            
            AgoraChatClient.shared().chatManager.send(agoraMessage, progress: {_ in }) { [weak self] message, error in
                if let error = error {
                    self?.presentOkAlert("Failed to send message. Error code: \(error.errorDescription ?? "-" )")
                    return
                }
                
                self?.insertMessage(innerChatMessage, shouldScroll: true)
            }
        }
    }
   
    public func didDismiss(controller: GiphyViewController?) {
        // your user dismissed the controller without selecting a GIF.
   }
    
    func notifyAudioRoomAboutLastMessage() {
        if let lastMessage = messages.last {
            if let messageSender = lastMessage.sender as? ChatMessageSender {
                let avatarUrl: URL? = messageSender.profileImageURL
                delegate?.didUpdateLastMessage(with: lastMessage, avatarUrl: avatarUrl)
            }
        }
    }
}

// MARK: - AgoraRtmChannelDelegate
extension ChatViewController: AgoraChatroomManagerDelegate, AgoraChatManagerDelegate {
    
    private func messagesDidReceive(_ aMessages: [Any]!) {
        guard let messages = aMessages as? [AgoraChatMessage] else { return }
        let messageKitMessages = messages.compactMap { msg -> ChatMessage? in
           if let text = (msg.body as? AgoraChatTextMessageBody)?.text,
              let messageData = text.data(using: .utf8) {
               return try? JSONDecoder().decode(ChatMessage.self, from: messageData)
           } else {
               return nil
           }
        }
        
        insert(newMessages: messageKitMessages)
        notifyAudioRoomAboutLastMessage()
    }

}

private extension ChatViewController {

    @objc func keyboardWillShow(_ notification: NSNotification) {
        self.messagesCollectionView.scrollToLastItem()
    }

    @objc func keyboardWillHide(_ notification: NSNotification) { }
}

// MARK: Private Constant
//FIXME: Add localization
private extension ChatViewController {
    var messageInputBarPlaceholderText: String { "Add to the discussion..." }
    var messageInputBarTextWhileSending: String { "Sending..." }
    var enablesTextChatSettingTitle: String { "Text chat" }
    var enablesTextChatSettingDescription: String { "Allow people to chat in the room`s discussion area." }
    var chatSettingsSavedMessage: String { "Chat settings were saved successfully" }
    var chatDisabledByHostMessage: String { "Chat disabled by host" }
}
