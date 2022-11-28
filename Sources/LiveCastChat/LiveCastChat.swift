import AgoraChat
import UIKit

// MARK: - Callbacks

typealias FollowAction  = ((() -> Void) -> Void)?
typealias ReturnAction  = () -> Void
typealias ReturnString  = (String) -> Void
typealias ReturnInteger = (Int) -> Void
typealias ReturnFlag    = (Bool) -> Void
typealias ReturnDate    = (Date) -> Void
typealias ReturnFloat    = (Float) -> Void


public struct LiveCastChat {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}
