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

import UIKit
//
//public typealias TextMessageCollectionViewCellStyleProtocol = TextBubbleViewStyleProtocol

public final class SystemMessageCollectionViewCell: BaseMessageCollectionViewCell<SystemBubbleView> {

    public static func sizingCell() -> SystemMessageCollectionViewCell {
        let cell = SystemMessageCollectionViewCell(frame: CGRect.zero)
        cell.viewContext = .Sizing
        return cell
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public override func layoutSubviews() {
        accessoryTimestamp = nil
        super.layoutSubviews()
        let layoutModel = self.calculateLayout(availableWidth: self.contentView.bounds.width)
        self.bubbleView.bma_rect = layoutModel.bubbleViewFrame
        self.bubbleView.preferredMaxLayoutWidth = layoutModel.preferredMaxWidthForBubble
        self.bubbleView.layoutIfNeeded()
    }
    
    // MARK: Subclassing (view creation)

    override func createBubbleView() -> SystemBubbleView {
        return SystemBubbleView()
    }

    public override func performBatchUpdates(updateClosure: () -> Void, animated: Bool, completion: (() -> Void)?) {
        super.performBatchUpdates({ () -> Void in
            self.bubbleView.performBatchUpdates(updateClosure, animated: false, completion: nil)
        }, animated: animated, completion: completion)
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        return self.calculateLayout(availableWidth: size.width).size
    }
    
    private func calculateLayout(availableWidth availableWidth: CGFloat) -> MessageLayoutModelProtocol {
        
        let parameters = BaseMessageLayoutModelParameters(
            containerWidth: availableWidth,
            horizontalMargin: self.layoutConstants.horizontalMargin,
            horizontalInterspacing: self.layoutConstants.horizontalInterspacing,
            failedButtonSize: self.failedIcon.size,
            maxContainerWidthPercentageForBubbleView: self.layoutConstants.maxContainerWidthPercentageForBubbleView,
            bubbleView: self.bubbleView,
            isIncoming: self.messageViewModel.isIncoming,
            isFailed: self.messageViewModel.showsFailedIcon
        )
        var layoutModel = SystemMessageLayoutModel()
        layoutModel.calculateLayout(parameters: parameters)
        return layoutModel
    }


    // MARK: Property forwarding

    override public var viewContext: ViewContext {
        didSet {
            self.bubbleView.viewContext = self.viewContext
        }
    }

    public var systemMessageViewModel: SystemMessageViewModelProtocol! {
        didSet {
            self.messageViewModel = self.systemMessageViewModel
            self.bubbleView.systemMessageViewModel = self.systemMessageViewModel
        }
    }

    public var systemMessageStyle: TextMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.bubbleView.style = self.systemMessageStyle
        }
    }

    override public var selected: Bool {
        didSet {
            self.bubbleView.selected = self.selected
        }
    }

    public var layoutCache: NSCache! {
        didSet {
            self.bubbleView.layoutCache = self.layoutCache
        }
    }
}

protocol MessageLayoutModelProtocol {
    var size:CGSize { get }
    var failedViewFrame:CGRect { get }
    var bubbleViewFrame:CGRect { get }
    var preferredMaxWidthForBubble: CGFloat { get }
    mutating func calculateLayout(parameters parameters: BaseMessageLayoutModelParameters)
}

struct SystemMessageLayoutModel:MessageLayoutModelProtocol {
    private (set) var size = CGSize.zero
    private (set) var failedViewFrame = CGRect.zero
    private (set) var bubbleViewFrame = CGRect.zero
    private (set) var preferredMaxWidthForBubble: CGFloat = 0
    
    mutating func calculateLayout(parameters parameters: BaseMessageLayoutModelParameters) {
        let containerWidth = parameters.containerWidth
        let isIncoming = parameters.isIncoming
        let isFailed = parameters.isFailed
        let failedButtonSize = parameters.failedButtonSize
        let bubbleView = parameters.bubbleView
        let horizontalMargin = parameters.horizontalMargin
        let horizontalInterspacing = parameters.horizontalInterspacing
        
        let preferredWidthForBubble = containerWidth - 74
        var bubbleSize = bubbleView.sizeThatFits(CGSize(width: preferredWidthForBubble, height: CGFloat.max))
        bubbleSize = CGSize(width: preferredWidthForBubble, height: bubbleSize.height+10)
        let containerRect = CGRect(origin: CGPoint.zero, size: CGSize(width: containerWidth, height: bubbleSize.height))
        
        
        self.bubbleViewFrame = bubbleSize.bma_rect(inContainer: containerRect, xAlignament: .Center, yAlignment: .Center, dx: 0, dy: 0)
        self.failedViewFrame = failedButtonSize.bma_rect(inContainer: containerRect, xAlignament: .Center, yAlignment: .Center, dx: 0, dy: 0)
        
        // Adjust horizontal positions
        
        var currentX: CGFloat = 0
        currentX += (containerWidth - bubbleSize.width) / 2
        self.bubbleViewFrame.origin.x = currentX
        
        self.size = containerRect.size
        self.preferredMaxWidthForBubble = preferredWidthForBubble
    }
}

