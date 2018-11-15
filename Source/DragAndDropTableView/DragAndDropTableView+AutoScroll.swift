//
//  DragAndDropTableView+AutoScroll.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/7/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

extension DragAndDropTableView {
    
    func autoScrollVelocity(_ rect: CGRect) -> CGFloat {
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = self.frame.inset(by: self.safeAreaInsets)
        } else {
            safeAreaFrame = self.frame.inset(by: self.scrollIndicatorInsets)
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
