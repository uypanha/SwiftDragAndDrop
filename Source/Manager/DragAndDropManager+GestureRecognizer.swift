//
//  DragAndDropManager+GestureRecognizer.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/6/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

extension DragAndDropManager {
    
    @objc public func updateForLongPress(_ recogniser : UILongPressGestureRecognizer) -> Void {
        switch recogniser.state {
        case .began :
            self.beginReorder(recogniser)
        case .changed :
            self.updateReorder(recogniser)
        case .ended, .cancelled, .failed, .possible:
            self.endReorder(recogniser)
        }
    }
    
}

extension DragAndDropManager: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        for view in self.views where view is DraggableViewDelegate  {
            
            let draggable = view as! DraggableViewDelegate
            
            let touchPointInView = touch.location(in: view)
            
            guard draggable.draggableView(canDragAt: touchPointInView) else { continue }
            if let _ = draggable.draggableView(dataItemAt: touchPointInView) {
                return true
            }
        }
        
        return false
    }
}
