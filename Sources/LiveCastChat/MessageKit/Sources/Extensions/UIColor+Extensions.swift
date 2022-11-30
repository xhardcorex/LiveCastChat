/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import UIKit

internal extension UIColor {

    private static func colorFromAssetBundle(named: String) -> UIColor {
        guard let color = UIColor(named: named, in: Bundle.module, compatibleWith: nil) else {
            fatalError(MessageKitError.couldNotFindColorAsset)
        }
        return color
    }
    
    static func generateColorFor(text: String) -> UIColor{
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars{
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);
        let color = UIColor(red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0, green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0, blue: CGFloat((finalHash & 0xFF)) / 255.0, alpha: 1.0)
        return color
    }
    

    // This is the main app color that can be changed in Assets file and color set named "AccentColor"
    
    static var accentColor: UIColor { colorFromAssetBundle(named: "AccentColor") }
    
    // Chat colors
    
    static var incomingMessageBackground: UIColor { colorFromAssetBundle(named: "incomingMessageBackground")  }

    static var outgoingMessageBackground: UIColor { colorFromAssetBundle(named: "outgoingMessageBackground") }
    
    static var incomingMessageLabel: UIColor { colorFromAssetBundle(named: "incomingMessageLabel") }
    
    static var outgoingMessageLabel: UIColor { colorFromAssetBundle(named: "outgoingMessageLabel") }
    
    static var incomingAudioMessageTint: UIColor { colorFromAssetBundle(named: "incomingAudioMessageTint") }
    
    static var outgoingAudioMessageTint: UIColor { colorFromAssetBundle(named: "outgoingAudioMessageTint") }

    static var collectionViewBackground: UIColor { colorFromAssetBundle(named: "collectionViewBackground") }

    static var typingIndicatorDot: UIColor { colorFromAssetBundle(named: "typingIndicatorDot") }
    
    static var avatarViewBackground: UIColor { colorFromAssetBundle(named: "avatarViewBackground") }
    
    static var label: UIColor { colorFromAssetBundle(named: "label") }
    
}
