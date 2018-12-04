//
// Copyright (c) 2018 Phanha UY
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

extension DragAndDropTableView {
    
    func autoScrollVelocity(_ rect: CGRect) -> CGFloat {
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = UIEdgeInsetsInsetRect(self.frame, self.safeAreaInsets)
            //self.frame.inset(by: self.safeAreaInsets)
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(self.frame, self.scrollIndicatorInsets)
            // self.frame.inset(by: self.scrollIndicatorInsets)
        }
        
        let distanceToTop = max(rect.minY - safeAreaFrame.minY, 0)
        let distanceToBottom = max(safeAreaFrame.maxY - rect.maxY, 0)
        
        if distanceToTop < autoScrollThreshold {
            return mapValue(distanceToTop, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: -autoScrollMinVelocity, max: -autoScrollMaxVelocity)
        }
        if distanceToBottom < autoScrollThreshold {
            return mapValue(distanceToBottom, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: autoScrollMinVelocity, max: autoScrollMaxVelocity)
        }
        return 0
    }
    
    func handleDisplayLinkUpdate(autoScroll displayLink: CADisplayLink, lastAutoScroll timeStamp: CFTimeInterval, snapshotView rect: CGRect) -> Bool {
        let scrollVelocity = autoScrollVelocity(rect)
        
        if scrollVelocity != 0 {
            let elapsedTime = displayLink.timestamp - timeStamp
            let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
            
            let contentOffset = self.contentOffset
            self.contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y + CGFloat(scrollDelta))
            
            let contentInset: UIEdgeInsets
            if #available(iOS 11, *) {
                contentInset = self.adjustedContentInset
            } else {
                contentInset = self.contentInset
            }
            
            let minContentOffset = -contentInset.top
            let maxContentOffset = self.contentSize.height - self.bounds.height + contentInset.bottom
            
            self.contentOffset.y = min(self.contentOffset.y, maxContentOffset)
            self.contentOffset.y = max(self.contentOffset.y, minContentOffset)
            return true
        }
        
        return false
    }
}
