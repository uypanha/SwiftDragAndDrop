//
//  DragAndDropManager+Destination.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/6/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

extension DragAndDropManager {
    
    @discardableResult func updateDestinationRow() -> Bool {
        guard let bundle = self.bundle else { return false }
        
        let pointOnDetectedView = self.canvas.convert(bundle.snapshotView.center, to: self.viewToDetect)
        var draggingFrame = bundle.snapshotView.frame
        draggingFrame.origin = CGPoint(x: pointOnDetectedView.x - bundle.offset.x, y: pointOnDetectedView.y - bundle.offset.y)
        
        var overlappingAreaMAX: CGFloat = 0.0
        var mainOverView: UIView?
        
        var index = 0
        for view in self.views where view is DraggableViewDelegate  {
            let viewFrameOnCanvas = self.convertRectToCanvas(view.frame, fromView: view)
            
            /*                 ┌────────┐   ┌────────────┐
             *                 │       ┌┼───│Intersection│
             *                 │       ││   └────────────┘
             *                 │   ▼───┘│
             * ████████████████│████████│████████████████
             * ████████████████└────────┘████████████████
             * ██████████████████████████████████████████
             */
            
            let overlappingAreaCurrent = draggingFrame.intersection(viewFrameOnCanvas).area
            
            if overlappingAreaCurrent > overlappingAreaMAX {
                overlappingAreaMAX = overlappingAreaCurrent
                mainOverView = view
            }
            index += 1
        }
        
        if let droppable = mainOverView as? DroppableViewDelegate {
            let rect = viewToDetect.convert(draggingFrame, to: mainOverView)
            if droppable.droppableView(canDropAt: rect) {
                
                if let dragAndDropDelegate = mainOverView as? DragAndDropDelegate {
                    dragAndDropDelegate.dragAndDropViewBeginUpdate({
                        updateReorderRows(droppable, mainOverView, at: rect)
                    }) {
                        dragAndDropDelegate.dragAndDropViewEndUpdate()
                    }
                } else {
                    updateReorderRows(droppable, mainOverView, at: rect)
                }
                return true
            }
        }
        return false
    }
    
    fileprivate func updateReorderRows(_ droppable: DroppableViewDelegate, _ mainOverView: UIView?, at rect: CGRect) {
        guard let bundle = self.bundle else { return }
        
        if mainOverView != bundle.destinationDroppableView { // if it is the first time we are entering
            (bundle.destinationDroppableView as! DroppableViewDelegate).droppableView(didMoveOut: bundle.dataItem)
            droppable.droppableView(willMove: bundle.dataItem, inRect: rect)
        }
        
        // set the view the dragged element is over
        self.bundle?.destinationDroppableView = mainOverView
        droppable.droppableView(didMove: bundle.dataItem, inRect: rect)
    }
    
    func updateDestinationAutoScroll() -> Bool {
        guard let bundle = self.bundle else { return false }
        
        if let droppable = bundle.destinationDroppableView as? DroppableViewDelegate {
           return droppable.droppableView(autoScroll: autoScrollDisplayLink, lastAutoScroll: lastAutoScrollTimeStamp, snapshotView: bundle.snapshotView.frame)
        }
        
        return false
    }
    
    func updateSnapshotViewOut(destinationView: UIView, completion: @escaping () -> Void) {
        guard let bundle = self.bundle else { return }
        
        if let droppable = destinationView as? DroppableViewDelegate {
            if let cellRectInView = droppable.droppableViewCellRect() {
                let cellRect = destinationView.convert(cellRectInView, to: self.canvas)
                let cellRectCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                
                // If no values change inside a UIView animation block, the completion handler is called immediately.
                // This is a workaround for that case.
                if bundle.snapshotView.center == cellRectCenter {
                    bundle.snapshotView.center.y += 0.1
                }
                
                UIView.animate(
                    withDuration: animationDuration,
                    animations: {
                        bundle.snapshotView.center = cellRectCenter
                }, completion: { _ in
                        completion()
                })
                return
            }
        }
        completion()
    }
}
