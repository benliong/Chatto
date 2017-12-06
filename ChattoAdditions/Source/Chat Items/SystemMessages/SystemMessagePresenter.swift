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

public class SystemMessagePresenter<ViewModelBuilderT, InteractionHandlerT where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ModelT: SystemMessageModelProtocol,
    ViewModelBuilderT.ViewModelT: SystemMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
    InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT>
: BaseMessagePresenter<SystemBubbleView, ViewModelBuilderT, InteractionHandlerT> {
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT

    public init (
        messageModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: SystemMessageCollectionViewCell,
        baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
        textCellStyle: TextMessageCollectionViewCellStyleProtocol,
        layoutCache: NSCache) {
            self.layoutCache = layoutCache
            self.textCellStyle = textCellStyle
            super.init(
                messageModel: messageModel,
                viewModelBuilder: viewModelBuilder,
                interactionHandler: interactionHandler,
                sizingCell: sizingCell,
                cellStyle: baseCellStyle
            )
    }

    let layoutCache: NSCache
    let textCellStyle: TextMessageCollectionViewCellStyleProtocol

    public override class func registerCells(collectionView: UICollectionView) {
        collectionView.registerClass(SystemMessageCollectionViewCell.self, forCellWithReuseIdentifier: "system-message")
    }

    public override func dequeueCell(collectionView collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "system-message"
        return collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
    }

    public override func configureCell(cell: BaseMessageCollectionViewCell<SystemBubbleView>, decorationAttributes: ChatItemDecorationAttributes,  animated: Bool, additionalConfiguration: (() -> Void)?) {
        guard let cell = cell as? SystemMessageCollectionViewCell else {
            assert(false, "Invalid cell received")
            return
        }

        super.configureCell(cell, decorationAttributes: decorationAttributes, animated: animated) { () -> Void in
            self.messageViewModel.showsTail = false
            cell.layoutCache = self.layoutCache
            cell.systemMessageViewModel = self.messageViewModel
            cell.systemMessageStyle = self.textCellStyle
            additionalConfiguration?()
        }
    }

    public override func canShowMenu() -> Bool {
        return true
    }

    public override func canPerformMenuControllerAction(action: Selector) -> Bool {
        return action == "copy:"
    }

    public override func performMenuControllerAction(action: Selector) {
        if action == "copy:" {
            UIPasteboard.generalPasteboard().string = self.messageViewModel.text
        } else {
            assert(false, "Unexpected action")
        }
    }
}