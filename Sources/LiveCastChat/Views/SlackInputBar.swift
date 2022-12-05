//
//  SlackInputBar.swift
//  Example
//
//  Created by Nathan Tannar on 2018-06-06.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//

import UIKit

public protocol SlackInputBarAccessoryViewDelegate : InputBarAccessoryViewDelegate, UIViewController {
    func didPressCameraButtonWith(_ inputBar: InputBarAccessoryView)
    func didPressMediaButtonWith(_ inputBar: InputBarAccessoryView)
    func didPressGifButtonWith(_ inputBar: InputBarAccessoryView)
}


open class SlackInputBar: InputBarAccessoryView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        let items = [
            makeButton(named: "camera").onTextViewDidChange { button, textView in
                button.isEnabled = textView.text.isEmpty
            }.onSelected { _ in
                    //$0.tintColor = .systemBlue
                    (self.delegate as? SlackInputBarAccessoryViewDelegate)?.didPressCameraButtonWith(self)
            },
            makeButton(named: "photo").onSelected { _ in
                //$0.tintColor = .systemBlue
                (self.delegate as? SlackInputBarAccessoryViewDelegate)?.didPressMediaButtonWith(self)
            },
            makeButton(named: "gif", isSystemImage: false).onSelected { _ in
                //$0.tintColor = .systemBlue
                (self.delegate as? SlackInputBarAccessoryViewDelegate)?.didPressGifButtonWith(self)
            },
            .flexibleSpace,
            sendButton
                .configure {
                    $0.layer.cornerRadius = 8
                    $0.layer.borderWidth = 1.5
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.setTitleColor(.white, for: .normal)
                    $0.setTitleColor(.white, for: .highlighted)
                    $0.setSize(CGSize(width: 52, height: 30), animated: false)
                }.onDisabled {
                    $0.layer.borderColor = $0.titleColor(for: .disabled)?.cgColor
                    $0.backgroundColor = .clear
                }.onEnabled {
                    $0.backgroundColor = .systemBlue
                    $0.layer.borderColor = UIColor.clear.cgColor
                }.onSelected {
                    // We use a transform becuase changing the size would cause the other views to relayout
                    $0.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }.onDeselected {
                    $0.transform = CGAffineTransform.identity
            }
        ]
        items.forEach { $0.tintColor = .accentColor }
        
        // We can change the container insets if we want
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        inputTextView.frame.size.width = UIScreen.main.bounds.width
        
        let maxSizeItem = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate)
                $0.tintColor = .darkGray
                $0.setSize(CGSize(width: 20, height: 20), animated: false)
            }.onSelected {
                let oldValue = $0.inputBarAccessoryView?.shouldForceTextViewMaxHeight ?? false
                $0.image = oldValue ? UIImage(named: "icons8-expand")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "icons8-collapse")?.withRenderingMode(.alwaysTemplate)
                self.setShouldForceMaxTextViewHeight(to: !oldValue, animated: true)
        }
        rightStackView.alignment = .top
        setStackViewItems([maxSizeItem], forStack: .right, animated: false)
        setRightStackViewWidthConstant(to: 20, animated: false)
        
        setLeftStackViewWidthConstant(to: 0, animated: false)
        setStackViewItems(items, forStack: .bottom, animated: false)
        shouldAnimateTextDidChangeLayout = true
    }
    
    private func makeButton(named: String, isSystemImage: Bool = true) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                if isSystemImage {
                    $0.image = UIImage(systemName: named, withConfiguration: UIImage.SymbolConfiguration(scale: .large))?.withRenderingMode(.alwaysTemplate)
                } else {
                    $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                }
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected { _ in
             //   $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }
}
