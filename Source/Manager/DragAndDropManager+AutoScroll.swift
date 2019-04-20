//
// Copyright (c) 2019 Phanha UY
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

extension DragAndDropManager {
    
    func autoScrollVelocity() -> CGFloat {
        
        guard let scrollView = self.scrollView, let snapshotView = rowBundle?.snapshotView ?? columnBundle?.snapshotView else { return 0 }
        
        guard autoScrollEnabled else { return 0 }
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = scrollView.frame.inset(by: scrollView.safeAreaInsets)
        } else {
            safeAreaFrame = scrollView.frame.inset(by: scrollView.scrollIndicatorInsets)
        }
        
        let distanceToLeft = max(snapshotView.frame.minX - safeAreaFrame.minX, 0)
        let distanceToRight = max(safeAreaFrame.maxX - snapshotView.frame.maxX, 0)
        
        if distanceToLeft < autoScrollThreshold {
            return mapValue(distanceToLeft, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: -autoScrollMinVelocity, max: -autoScrollMaxVelocity)
        }
        if distanceToRight < autoScrollThreshold {
            return mapValue(distanceToRight, inRangeWithMin: autoScrollThreshold, max: 0, toRangeWithMin: autoScrollMinVelocity, max: autoScrollMaxVelocity)
        }
        return 0
    }
    
    func activateAutoScrollDisplayLink(_ recogniser: UILongPressGestureRecognizer) {
        autoScrollDisplayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLinkUpdate))
        autoScrollDisplayLink?.add(to: .main, forMode: .default)
        lastAutoScrollTimeStamp = nil
    }
    
    func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastAutoScrollTimeStamp = nil
    }
    
    @objc func handleDisplayLinkUpdate(_ displayLink: CADisplayLink) {
        guard let scrollView = scrollView else { return }
        
        if updateDestinationAutoScroll() {
            if self.rowBundle != nil {
                updateDestinationRow()
            } else if columnBundle != nil {
                updateDestinationColumn()
            }
        } else {
            if let lastAutoScrollTimeStamp = lastAutoScrollTimeStamp {
                let scrollVelocity = autoScrollVelocity()
                
                if scrollVelocity != 0 {
                    let elapsedTime = displayLink.timestamp - lastAutoScrollTimeStamp
                    let scrollDelta = CGFloat(elapsedTime) * scrollVelocity
                    
                    let contentOffset = scrollView.contentOffset
                    scrollView.contentOffset = CGPoint(x: contentOffset.x + CGFloat(scrollDelta), y: contentOffset.y)
                    
                    let contentInset: UIEdgeInsets
                    if #available(iOS 11, *) {
                        contentInset = scrollView.adjustedContentInset
                    } else {
                        contentInset = scrollView.contentInset
                    }
                    
                    let minContentOffset = -contentInset.left
                    let maxContentOffset = scrollView.contentSize.width - scrollView.bounds.width + contentInset.right
                    
                    scrollView.contentOffset.x = min(maxContentOffset, scrollView.contentOffset.x)
                    scrollView.contentOffset.x = max(minContentOffset, scrollView.contentOffset.x)
                    
                    if self.rowBundle != nil {
                        updateDestinationRow()
                    } else if columnBundle != nil {
                        updateDestinationColumn()
                    }
                }
            }
        }
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
}
