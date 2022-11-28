//
//  GIfInputBarAccessoryView.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 19.02.2022.
//

import UIKit

protocol GIfInputBarAccessoryViewDelegate : InputBarAccessoryViewDelegate, UIViewController {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
    func inputBar(_ inputBar: InputBarAccessoryView, didPressMoreButtonWith attachments: [AttachmentManager.Attachment])
    func inputBar(_ inputBar: InputBarAccessoryView, didPressGifButtonWith attachments: [AttachmentManager.Attachment])
}

extension GIfInputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        
    }
}


class GIfInputBarAccessoryView: InputBarAccessoryView {
    // MARK: Constant
    
    // MARK: Private Constant
    private let defaultAnimationDuration: TimeInterval = 0.15
    
    // MARK: Variable
    override var middleContentViewPadding: UIEdgeInsets {
        get {
            return lazyMiddleContentViewPadding
        }
        set {
            lazyMiddleContentViewPadding = newValue
        }
    }
    
    override var shouldManageSendButtonEnabledState: Bool {
        get {
            return false
        }
        set {
            // custom config...
        }
    }
    
    // MARK: Private Variable
    private var shouldCallMoreEventInsteadOfSend = false {
        didSet {
            if self.shouldCallMoreEventInsteadOfSend {
//                self.sendButton.image = Images.threeHorizontalDots
            } else {
                let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
                self.sendButton.image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
            }
            
            UIView.animate(withDuration: defaultAnimationDuration, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    private lazy var lazyMiddleContentViewPadding: UIEdgeInsets = {
        let topInset: CGFloat = 5
        let bottomInset: CGFloat = 5
        let leftInset: CGFloat = 15
        let rightInset: CGFloat = 10
        return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }()
    
    private lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var gifButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(5)
                $0.translatesAutoresizingMaskIntoConstraints = false
                
//                $0.image = Images.gif
                $0.tintColor = .accentColor
                
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .lightGray
            }.onDeselected {
                $0.tintColor = .black
            }.onTouchUpInside { [weak self] _ in
                self?.gifEvent()
            }
        return button
    }()
    
    private lazy var gifButton2: InputBarButtonItem = {
        let button = InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(5)
                $0.translatesAutoresizingMaskIntoConstraints = false
                
//                $0.image = Images.gif
//                $0.tintColor = .accentColor
                
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .lightGray
            }.onDeselected {
                $0.tintColor = .black
            }.onTouchUpInside { [weak self] _ in
                self?.gifEvent()
            }
        return button
    }()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Action
    
    // MARK: Private Action
    @objc private func gifEvent() {
        (delegate as? GIfInputBarAccessoryViewDelegate)?.inputBar(self, didPressGifButtonWith: attachmentManager.attachments)
    }
    
    // MARK: Function
    override func didSelectSendButton() {
        if shouldCallMoreEventInsteadOfSend {
            (delegate as? GIfInputBarAccessoryViewDelegate)?.inputBar(self, didPressMoreButtonWith: attachmentManager.attachments)
        } else {
            if attachmentManager.attachments.count > 0 {
                (delegate as? GIfInputBarAccessoryViewDelegate)?.inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
            }
            else {
                delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
            }
        }
    }
    
    @objc
    open override func inputTextViewDidChange() {
        
        let trimmedText = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var shouldUseMoreButton = trimmedText.isEmpty
        if shouldUseMoreButton {
            // The images property is more resource intensive so only use it if needed
            shouldUseMoreButton = inputTextView.images.count < 1
        }
        shouldCallMoreEventInsteadOfSend = shouldUseMoreButton
        
        // Capture change before iterating over the InputItem's
        let shouldInvalidateIntrinsicContentSize = requiredInputTextViewHeight != inputTextView.bounds.height
        
        items.forEach { $0.textViewDidChangeAction(with: self.inputTextView) }
        delegate?.inputBar(self, textViewTextDidChangeTo: trimmedText)
        
        if shouldInvalidateIntrinsicContentSize {
            // Prevent un-needed content size invalidation
            invalidateIntrinsicContentSize()
            if shouldAnimateTextDidChangeLayout {
                inputTextView.layoutIfNeeded()
                UIView.animate(withDuration: defaultAnimationDuration) {
                    self.layoutContainerViewIfNeeded()
                }
            }
        }
    }
    
    func configureUI() {
        leftStackView.addArrangedSubview(gifButton)
        gifButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        leftStackView.addArrangedSubview(gifButton2)
        gifButton2.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

        inputPlugins = [attachmentManager]

        sendButton.isEnabled = true
        shouldCallMoreEventInsteadOfSend = true

        isTranslucent = true
        separatorLine.isHidden = true
        inputTextView.tintColor = .lightGray
        inputTextView.backgroundColor = .clear
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 70)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 10
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        sendButton.imageView?.backgroundColor = .clear
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        sendButton.tintColor = .accentColor
        sendButton.setTitle("", for: .normal)

        // Entire InputBar padding
        padding.bottom = 8

        // or MiddleContentView padding
        middleContentViewPadding.right = -36
    }
    
    // MARK: Private Function
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension GIfInputBarAccessoryView : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func showImagePickerController(sourceType: UIImagePickerController.SourceType){
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = sourceType
        imgPicker.presentationController?.delegate = self
        inputAccessoryView?.isHidden = true
        getViewController()?.present(imgPicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[  UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // self.sendImageMessage(photo: editedImage)
            self.inputPlugins.forEach { _ = $0.handleInput(of: editedImage)}
            
        }
        else if let originImage = info[  UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.inputPlugins.forEach { _ = $0.handleInput(of: originImage)}
            //self.sendImageMessage(photo: originImage)
        }
        getViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        getViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
    }
    
    
    func getViewController() -> UIViewController? {
        return delegate as? UIViewController
    }
}


extension GIfInputBarAccessoryView: AttachmentManagerDelegate {
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        self.shouldCallMoreEventInsteadOfSend = !(manager.attachments.count > 0)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        self.shouldCallMoreEventInsteadOfSend = !(manager.attachments.count > 0)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        self.shouldCallMoreEventInsteadOfSend = !(manager.attachments.count > 0)
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    
    func setAttachmentManager(active: Bool) {
        
        let topStackView = self.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}


extension GIfInputBarAccessoryView: UIAdaptivePresentationControllerDelegate {
    // Swipe to dismiss image modal
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        isHidden = false
    }
}

