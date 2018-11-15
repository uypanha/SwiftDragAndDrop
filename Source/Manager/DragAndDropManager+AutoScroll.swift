//
//  DragAndDropManager+AutoScroll.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/6/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

extension DragAndDropManager {
    
    func autoScrollVelocity() -> CGFloat {
        
        guard let scrollView = self.scrollView, let snapshotView = bundle?.snapshotView else { return 0 }
        
        guard autoScrollEnabled else { return 0 }
        
        let safeAreaFrame: CGRect
        if #available(iOS 11, *) {
            safeAreaFrame = UIEdgeInsetsInsetRect(scrollView.frame, scrollView.safeAreaInsets)
                //scrollView.frame.inset(by: scrollView.safeAreaInsets)
        } else {
            safeAreaFrame = UIEdgeInsetsInsetRect(scrollView.frame, scrollView.scrollIndicatorInsets)
                //scrollView.frame.inset(by: scrollView.scrollIndicatorInsets)
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
        autoScrollDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        //autoScrollDisplayLink?.add(to: .main, forMode: .default)
        lastAutoScrollTimeStamp = nil
    }
    
    func clearAutoScrollDisplayLink() {
        autoScrollDisplayLink?.invalidate()
        autoScrollDisplayLink = nil
        lastAutoScrollTimeStamp = nil
    }
    
    @objc func handleDisplayLinkUpdate(_ displayLink: CADisplayLink) {
        guard let scrollView = self.scrollView else { return }
        
        if updateDestinationAutoScroll() {
            updateDestinationRow()
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
                    
                    updateDestinationRow()
                }
            }
        }
        lastAutoScrollTimeStamp = displayLink.timestamp
    }
}
