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
import ProgressHUD
//FIXME: Add Lightbox
//import Lightbox
import AVKit
import ReactionButton

open class SingleChatViewController: MessagesViewController, IAlertHelper {
    
    // MARK: - UI
    
    var selectedMessageID = ""
    
    private lazy var lazyMessagesCollectionView: MessagesCollectionView = {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.register(ChatTextMessageCell.self)
        messagesCollectionView.register(ChatMediaMessageCell.self)
        messagesCollectionView.register(GifMessageCell.self)
        return messagesCollectionView
    }()
    
    private lazy var settingsButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(blockUserAction))
        item.image = UIImage(systemName: "person.crop.circle.badge.xmark")
        return item
    }()
    
    private var isUserBlocked = false {
        didSet {
            //FIXME: Add images
           // settingsButtonItem.image = isUserBlocked ? Images.unblockUser : Images.blockUser
        }
    }
    
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
    private var chatUserInfo: AgoraChatUserInfo?
    #warning("This is userID or username?")
    private var userId: String = ""
    private var partnerUserName: String = ""
    private var isLoadingMore = false
    private lazy var messages = [ChatMessage]()
    private var channelUsers: [String: ChatMessageSender] = [:]
    private var room: AgoraChatroom?
    private var chatInitError: CustomError?
    private var chatUser: User?
    private var imagePicker: ImagePicker?
    
    weak var delegate: ChatViewControllerDelegate?

    private lazy var sender: ChatMessageSender = {
        //FIXME: Setup sender
//        let avatarURLString = UserManager.user.currentUser?.avatar?.presignedUrl ?? ""
//        let avatarURL = URL(string: avatarURLString)
//        let output = ChatMessageSender(senderId: UserManager.user.currentUser?.username ?? "", displayName: UserManager.user.currentUser?.fullName ?? "Me", profileImageURL: avatarURL)
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
      //  IQKeyboardManager.shared.enable = true
       // self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Init
    
    public init(userId: String, roomName: String, chatUserInfo: AgoraChatUserInfo? = nil, chatMessages: [ChatMessage] = []) {

        self.conversation = (AgoraChatClient.shared().chatManager.getConversation(userId, type: .chat, createIfNotExist: true))!

        super.init(nibName: "SingleChatViewController", bundle: Bundle(for: type(of: self)))

        self.roomName = roomName
        self.messages = chatMessages
        self.chatId = userId
        self.partnerUserName = userId
        self.chatUserInfo = chatUserInfo
        
        AgoraChatClient.shared().chatManager.add(self, delegateQueue: nil)
        fetchUser()
        prefetchChat {
            ChatReactionManager.shared.fetchReactions(messageIds: self.messages.compactMap({ $0.messageId }), completion: {
                self.messagesCollectionView.reloadData()
            })
        }

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
   
    private func fetchUser() {
        //FIXME: Fetch user
//        UserManager.user.getUsers(by: [partnerUserName]) { [weak self] result in
//            switch result {
//            case .success(let users):
//                self?.chatUser = users.first
//                self?.isUserBlocked = self?.chatUser?.blocked ?? false
//            case .failure(let error):
//                self?.showAlert(withTitle: "Error".localized, andMessage: error.localizedDescription, actionHandler: nil)
//                return
//            }
//        }
    }
    
    @objc private func blockUserAction() {
//FIXME: Fix blockUserAction
//        if isUserBlocked {
//            Task {
//                do {
//                    try await UserManager.user.unblockUser(by: userId)
//                    isUserBlocked = false
//                } catch {
//                    showAlert(withTitle: "Error", andMessage: error.localizedDescription, actionHandler: nil)
//                }
//            }
//        } else {
//            self.showReversedConfirmAlert(withTitle: "\("Do you want to block user".localized) @\(userId)?", andMessage: "") { [weak self] in
//                Task {
//                    do {
//                        try await UserManager.user.blockUser(with: self?.userId ?? "")
//                        self?.isUserBlocked = true
//                    } catch {
//                        self?.showAlert(withTitle: "Error", andMessage: error.localizedDescription, actionHandler: nil)
//                    }
//                }
//            }
//        }
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addKeyboardListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: Function
    
    public func removeChatObservers() {
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
            cell.addReactions(reactions: ChatReactionManager.shared.reactionsFor(messageId: message.messageId), isMe: isMe(at: indexPath))
            let buttonSample = ReactionButton(frame: cell.contentView.frame)
            buttonSample.dataSource = self
            buttonSample.delegate = self
            buttonSample.layer.name = message.messageId
            cell.contentView.addSubview(buttonSample)
            return cell
        case .text:
            let cell = messagesCollectionView.dequeueReusableCell(ChatTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            cell.addReactions(reactions: ChatReactionManager.shared.reactionsFor(messageId: message.messageId), isMe: isMe(at: indexPath))
            let buttonSample = ReactionButton(frame: cell.contentView.frame)
            buttonSample.dataSource = self
            buttonSample.delegate = self
            buttonSample.layer.name = message.messageId
            cell.contentView.addSubview(buttonSample)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(ChatMediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            cell.delegate = self
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
        navigationItem.setRightBarButtonItems([settingsButtonItem], animated: true)
        navigationItem.setLeftBarButton(backButtonItem, animated: true)
        navigationItem.title = roomName
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.titleView?.tintColor = .black
        navigationController?.navigationBar.tintColor = .accentColor
        messagesCollectionView.showsVerticalScrollIndicator = false
        
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
        //var mutableMessages = newMessages
        newMessages.forEach {
            messages.append($0)
            
            //            if messages.contains($0), let index = mutableMessages.firstIndex(of: $0) {
            //                mutableMessages.remove(at: index)
            //            } else {
            //                messages.append($0)
            //            }
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
        messageInputBar = SlackInputBar()
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
extension SingleChatViewController: Darkable {
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
extension SingleChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func isMe(at indexPath: IndexPath) -> Bool {
        let message = messages[indexPath.section]
        guard let messageSender = message.sender as? ChatMessageSender else { return false }
        print("MessageSenderId = \(messageSender.senderId) == \(currentSender().senderId)")
        return messageSender.senderId == currentSender().senderId
    }
    
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

        //Fixme: Set avatar
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
//            if let avatarURL = URL(string: chatUserInfo?.avatarUrl ?? "-") {
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

extension SingleChatViewController {
    private func loadMore() {
        isLoadingMore = true
        refreshControl.beginRefreshing()

        let messageId = self.messages.last?.messageId ?? "-"
        conversation.loadMessagesStart(fromId: messageId,
                                       count: 20,
                                       searchDirection: .up,
                                       completion: { messages, error in
            self.refreshControl.endRefreshing()
            self.isLoadingMore = false
            if error != nil {
                print("Errors \(error?.errorDescription ?? "")")
            } else {
                let messageKitMessages = messages?.compactMap { msg -> ChatMessage? in
                    if let text = (msg.body as? AgoraChatTextMessageBody)?.text,
                       let messageData = text.data(using: .utf8) {
                        return try? JSONDecoder().decode(ChatMessage.self, from: messageData)
                    } else {
                        return nil
                    }
                }
                self.insert(newMessages: messageKitMessages ?? [])
            }
        })
    }
    
    func prefetchChat(completion: @escaping () -> Void) {
        guard !isLoadingMore else { return }
        isLoadingMore = true
                
        conversation.loadMessagesStart(fromId: nil,
                                       count: 20,
                                       searchDirection: .up,
                                       completion: { messages, error in
            self.isLoadingMore = false
            if error != nil {
                print("Errors \(error?.errorDescription ?? "")")
            } else {
                let messageKitMessages = messages?.compactMap { msg -> ChatMessage? in
                    if let text = (msg.body as? AgoraChatTextMessageBody)?.text,
                       let messageData = text.data(using: .utf8) {
                        var message = try? JSONDecoder().decode(ChatMessage.self, from: messageData)
                        message?.messageId = msg.messageId
                        return message
                    } else {
                        if let imageBody = msg.body as? AgoraChatImageMessageBody {
                            let chatImage = ChatImage(url: URL(string: imageBody.remotePath), size: imageBody.size)
                            var message = ChatMessage(with: msg.messageId, kind: .photo(chatImage), sender: ChatMessageSender(senderId: msg.from))
                            return message
                        }
                        if let videoMessageBody = msg.body as? AgoraChatVideoMessageBody {
                            let chatVideo = ChatImage(url: URL(string: videoMessageBody.thumbnailRemotePath ?? ""), size: videoMessageBody.thumbnailSize)
                            var message = ChatMessage(with: msg.messageId, kind: .video(chatVideo), sender: ChatMessageSender(senderId: msg.from))
                            message.messageId = msg.messageId
                            return message
                        }
                        return nil
                    }
                }
                self.insert(newMessages: messageKitMessages ?? [])
                completion()
            }
        })
    }
    
    func sendCmdMessage(action: CmdMessageAction) {
        guard let agoraCmdMessage = AgoraSDKHelper.initCmdMessage(nil, to: chatId, chatType: .chat, action: action, messageExt: nil) else { return }
        AgoraChatClient.shared().chatManager.send(agoraCmdMessage, progress: {_ in }) { [weak self] message, error in
            if let error = error {
                self?.presentOkAlert("Failed to send message. Error code: \(error.code) Error description: \(error.errorDescription ?? "-" )")
                return
            }
        }
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension SingleChatViewController: InputBarAccessoryViewDelegate {
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = messageInputBarTextWhileSending
        inputBar.inputTextView.placeholder = messageInputBarPlaceholderText
        
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
                    
                    guard let agoraMessage = AgoraSDKHelper.initMessage(dataString, to: chatId, chatType: .chat, messageExt: nil) else { return }
                    AgoraChatClient.shared()
                    AgoraChatClient.shared().chatManager.send(agoraMessage, progress: {_ in }) { [weak self] message, error in
                        if let error = error {
                            self?.presentOkAlert("Failed to send message. Error code: \(error.code) Error description: \(error.errorDescription ?? "-" )")
                            return
                        }
                        innerChatMessage.messageId = message?.messageId ?? ""
                        self?.insertMessage(innerChatMessage, shouldScroll: true)
                        self?.sendCmdMessage(action: .stop)
                        inputBar.sendButton.stopAnimating()
                    }
                }
            }
        }
                
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        let currentText = inputBar.inputTextView.text
        sendCmdMessage(action: .typing)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) { [weak self] in
            if inputBar.inputTextView.text == currentText {
                self?.sendCmdMessage(action: .stop)
            }
        }
    }
}

// MARK: - GIfInputBarAccessoryViewDelegate

extension SingleChatViewController: SlackInputBarAccessoryViewDelegate {
    func didPressCameraButtonWith(_ inputBar: InputBarAccessoryView) {
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        DispatchQueue.main.async {
            self.imagePicker?.presentCamera()
        }
    }
    
    func didPressMediaButtonWith(_ inputBar: InputBarAccessoryView) {
        imagePicker = ImagePicker(presentationController: self, delegate: self, mediaTypes: [.photo, .video], allowsEditing: false)
        DispatchQueue.main.async {
            self.imagePicker?.presentGallery()
        }
    }
    
    func didPressGifButtonWith(_ inputBar: InputBarAccessoryView) {
        let giphy = GiphyViewController()
        giphy.mediaTypeConfig = [.gifs, .stickers, .text, .emoji]
        giphy.theme = GPHTheme(type: .light)
        giphy.showConfirmationScreen = true
        giphy.delegate = self
        present(giphy, animated: true, completion: nil)
    }
}

// MARK: - GiphyDelegate
extension SingleChatViewController: GiphyDelegate {
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
            
            guard let agoraMessage = AgoraSDKHelper.initMessage(dataString, to: chatId, chatType: .chat, messageExt: nil) else { return }
            
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

}

// MARK: - AgoraRtmChannelDelegate
extension SingleChatViewController: AgoraChatManagerDelegate {
    public func messagesDidReceive(_ aMessages: [AgoraChatMessage]) {
        let messageKitMessages = aMessages.compactMap { msg -> ChatMessage? in
            if let text = (msg.body as? AgoraChatTextMessageBody)?.text,
               let messageData = text.data(using: .utf8) {
                var message = try? JSONDecoder().decode(ChatMessage.self, from: messageData)
                message?.messageId = msg.messageId
                return message
            } else {
                if let imageBody = msg.body as? AgoraChatImageMessageBody {
                    let chatImage = ChatImage(url: URL(string: imageBody.remotePath), size: imageBody.size)
                    var message = ChatMessage(with: msg.messageId, kind: .photo(chatImage), sender: ChatMessageSender(senderId: msg.from))
                    return message
                }
                if let videoMessageBody = msg.body as? AgoraChatVideoMessageBody {
                    let chatVideo = ChatImage(url: URL(string: videoMessageBody.thumbnailRemotePath ?? ""), size: videoMessageBody.thumbnailSize)
                    var message = ChatMessage(with: msg.messageId, kind: .video(chatVideo), sender: ChatMessageSender(senderId: msg.from))
                    return message
                }
                return nil
            }
        }
        
        insert(newMessages: messageKitMessages)
    }
    
    public func cmdMessagesDidReceive(_ aCmdMessages: [AgoraChatMessage]) {
        guard let message = aCmdMessages.first, let body = message.body as? AgoraChatCmdMessageBody else { return }
        let action = CmdMessageAction(rawValue: body.action)
        
        switch action {
        case .typing, .stop:
            let isUserTyping = body.action == CmdMessageAction.typing.rawValue
            messagesCollectionView.setTypingIndicatorViewHidden(!isUserTyping)
            messagesCollectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.messagesCollectionView.scrollToLastItem()
            }
        case .updatedReaction:
            ChatReactionManager.shared.fetchReactions(messageIds: self.messages.compactMap({ $0.messageId }), completion: {
                self.messagesCollectionView.reloadData()
            })
        case .none:
            return
        }
        
    }
}

private extension SingleChatViewController {

    @objc func keyboardWillShow(_ notification: NSNotification) {
        self.messagesCollectionView.scrollToLastItem()
    }

    @objc func keyboardWillHide(_ notification: NSNotification) { }
}

// MARK: Private Constant
private extension SingleChatViewController {
    var messageInputBarPlaceholderText: String { "Add to the discussion..." }
    var messageInputBarTextWhileSending: String { "Sending..." }
    var enablesTextChatSettingTitle: String { "Text chat" }
    var enablesTextChatSettingDescription: String { "Allow people to chat in the room`s discussion area." }
    var chatSettingsSavedMessage: String { "Chat settings were saved successfully" }
    var chatDisabledByHostMessage: String { "Chat disabled by host" }
}

// MARK: - Image Picker Delegate

extension SingleChatViewController: ImagePickerDelegate {
    public func didSelect(image: UIImage?) {
        ProgressHUD.show()
        guard let agoraMessage = AgoraSDKHelper.initImageMessage(image, to: chatId, chatType: .chat, messageExt: nil) else { return }
        AgoraChatClient.shared().chatManager.send(agoraMessage, progress: {_ in }) { [weak self] message, error in
            ProgressHUD.dismiss()
            if let error = error {
                self?.presentOkAlert("Failed to send message. Error code: \(error.errorDescription ?? "-" )")
                return
            } else {
                if let message = message, let imageBody = message.body as? AgoraChatImageMessageBody {
                    let chatImage = ChatImage(url: URL(string: imageBody.remotePath), size: imageBody.size)
                    var innerMessage = ChatMessage(with: message.messageId, kind: .photo(chatImage), sender: ChatMessageSender(senderId: message.from))
                    self?.insertMessage(innerMessage, shouldScroll: true)
                }
            }
        }
    }
    
    public func didSelectVideo(with url: URL?) {
        ProgressHUD.show()
        guard let agoraMessage = AgoraSDKHelper.initVideoMessage(url, to: chatId, chatType: .chat, messageExt: nil) else { return }
        AgoraChatClient.shared().chatManager.send(agoraMessage, progress: {value in
            print("progress = \(value)")
        }) { [weak self] message, error in
            ProgressHUD.dismiss()
            if let error = error {
                self?.presentOkAlert("Failed to send message. Error code: \(error.errorDescription ?? "-" )")
                return
            } else {
                if let message = message, let videoMessageBody = message.body as? AgoraChatVideoMessageBody {
                    let chatVideo = ChatImage(url: URL(string: videoMessageBody.thumbnailRemotePath ?? ""), size: videoMessageBody.thumbnailSize)
                    var innerMessage = ChatMessage(with: message.messageId, kind: .video(chatVideo), sender: ChatMessageSender(senderId: message.from))

                    self?.insertMessage(innerMessage, shouldScroll: true)
                }
            }
        }
    }
}

extension SingleChatViewController: MessageCellDelegate {
    public func didTapImage(in cell: MessageCollectionViewCell) {
                if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messages[indexPath.section]
            switch message.kind {
            case .photo(let mediaItem):
                guard let url = mediaItem.url else { return }
//                let images = [LightboxImage(imageURL: url)]
//                let controller = LightboxController(images: images)
//                controller.dynamicBackground = true
//                present(controller, animated: true, completion: nil)
            case .video(let mediaItem):
                guard let videoURL = mediaItem.url else { return }
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            default: return
            }
        }
    }
}

extension SingleChatViewController: ReactionButtonDataSource {
    
    public func numberOfOptions(in selector: ReactionButton) -> Int {
        ChatReactionManager.shared.reactionsDataset.count
    }
    
    public func ReactionSelector(_ selector: ReactionButton, viewForIndex index: Int) -> UIView {
        return UIImageView(image: ChatReactionManager.shared.reactionsDataset[index].imageName.textToImage())
    }
    
    public func ReactionSelector(_ selector: ReactionButton, nameForIndex index: Int) -> String {
        return ""
    }
    
}

extension SingleChatViewController: ReactionButtonDelegate {
    public func ReactionSelector(_ sender: ReactionButton, didSelectedIndex index: Int) {
        print(sender.layer.name ?? "")
        ChatReactionManager.shared.sendReaction(with: index, to: sender.layer.name ?? "") { isAdded in
            self.sendCmdMessage(action: .updatedReaction)
            ChatReactionManager.shared.fetchReactions(messageIds: self.messages.compactMap({ $0.messageId }), completion: {
                self.messagesCollectionView.reloadData()
            })
        }
    }
}
