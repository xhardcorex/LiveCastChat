import AgoraChat
import UIKit
import GiphyUISDK
import ProgressHUD
import ReactionButton

// MARK: - Callbacks

public typealias FollowAction  = ((() -> Void) -> Void)?
public typealias ReturnAction  = () -> Void
public typealias ReturnString  = (String) -> Void
public typealias ReturnInteger = (Int) -> Void
public typealias ReturnFlag    = (Bool) -> Void
public typealias ReturnDate    = (Date) -> Void
public typealias ReturnFloat    = (Float) -> Void


public struct LiveCastChat {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}
