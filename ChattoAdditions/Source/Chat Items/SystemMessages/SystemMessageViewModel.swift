/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import Foundation

public protocol SystemMessageViewModelProtocol: TextMessageViewModelProtocol {
    var attributedString: NSAttributedString { get }
}

public class SystemMessageViewModel: SystemMessageViewModelProtocol {
    private var _text: String
    public var text: String {
        get {
            var t = _text
            if let title = title {
                t = "\(title)\n\n\(t)"
            }
            if let ctaText = ctaText {
                t = t.stringByAppendingString("\n\n\(ctaText)")
            }
            return t
        }
        set { _text = newValue }
    }
    public let title: String?
    public let ctaText: String?
    public let ctaURLString: String?
    public var attributedString: NSAttributedString {
        var string = NSMutableAttributedString()
        if #available(iOS 8.2, *) {
            string = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor(red: 78.0 / 255.0, green: 81.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)])
            if let title = title {
                var range = NSString(string: text).rangeOfString(title)
                if range.location != NSNotFound {
                    string.setAttributes([NSFontAttributeName:UIFont.systemFontOfSize(10, weight: UIFontWeightMedium), NSForegroundColorAttributeName: UIColor(red: 78.0 / 255.0, green: 81.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)], range: range)
                }
            }
            if let ctaText = ctaText, let ctaURLString = ctaURLString {
                var range2 = NSString(string: text).rangeOfString(ctaText)
                if range2.location != NSNotFound {
                    string.addAttribute(NSLinkAttributeName, value: ctaURLString, range: range2)
                    string.enumerateAttributesInRange(range2, options: .Reverse, usingBlock: { (attributes, range, stop) in
                        if let _ = attributes[NSLinkAttributeName] {
                            string.removeAttribute(NSFontAttributeName, range: range)
                            string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14, weight: UIFontWeightMedium), range: range2)
                        }
                    })
                }
            }
        } else {
            // Fallback on earlier versions
        }
        return string
    }
    public let messageViewModel: MessageViewModelProtocol

    public init(text: String, title:String?, ctaText:String?, ctaURLString:String?, messageViewModel: MessageViewModelProtocol) {
        self._text = text
        self.title = title
        self.ctaText = ctaText
        self.ctaURLString = ctaURLString
        self.messageViewModel = messageViewModel
    }
}

public class SystemMessageViewModelDefaultBuilder: ViewModelBuilderProtocol {
    public init() { }

    let messageViewModelBuilder = MessageViewModelDefaultBuilder()

    public func createViewModel(model: SystemMessageModel) -> SystemMessageViewModel {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(model)
        let systemMessageViewModel =  SystemMessageViewModel(text: model.text, title: model.title, ctaText: model.ctaText, ctaURLString: model.ctaURLString, messageViewModel: messageViewModel)
        return systemMessageViewModel
    }
}
