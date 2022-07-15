//
// Copyright (c) 2019 Panha Uy
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

// MARK: - Row Tools
extension DragAndDropManager {
    
    @discardableResult func updateDestinationRow() -> Bool {
        guard let bundle = self.rowBundle else { return false }
        
        let pointOnDetectedView = self.canvas.convert(bundle.snapshotView.center, to: self.viewToDetect)
        var draggingFrame = bundle.snapshotView.frame
        draggingFrame.origin = CGPoint(x: pointOnDetectedView.x - bundle.offset.x, y: pointOnDetectedView.y - bundle.offset.y)
        
        var overlappingAreaMAX: CGFloat = 0.0
        var mainOverView: UIView?
//        print("Dragging Frame == X:\(draggingFrame.origin.x)")
        
        if let collectionView = self.scrollView as? UICollectionView {
            // If scrollView is Collectionview
            if let indexPath = collectionView.indexPathForItem(at: pointOnDetectedView) {
                mainOverView = self.tableViews[indexPath.row]
            }
        } else {
            for view in self.tableViews where view.value is DraggableViewDelegate  {
                let viewFrameOnCanvas = self.convertRectToCanvas(view.value.frame, fromView: view.value)
                
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
                    mainOverView = view.value
                }
            }
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
        guard let bundle = self.rowBundle else { return }
        
        if mainOverView != bundle.destinationDroppableView { // if it is the first time we are entering
            (bundle.destinationDroppableView as! DroppableViewDelegate).droppableView(didMoveOut: bundle.dataItem)
            droppable.droppableView(willMove: bundle.dataItem, inRect: rect)
        }
        
        // set the view the dragged element is over
        self.rowBundle?.destinationDroppableView = mainOverView
        droppable.droppableView(didMove: bundle.dataItem, inRect: rect)
    }
    
    func updateDestinationAutoScroll() -> Bool {
        guard let bundle = self.rowBundle else { return false }
        
        if let droppable = bundle.destinationDroppableView as? DroppableViewDelegate {
            return droppable.droppableView(autoScroll: autoScrollDisplayLink, lastAutoScroll: lastAutoScrollTimeStamp, snapshotView: bundle.snapshotView.frame)
        }
        
        return false
    }
    
    func updateRowSnapshotViewOut(destinationView: UIView, completion: @escaping () -> Void) {
        guard let bundle = self.rowBundle else { return }
        
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

// MARK: - Columns Tools
extension DragAndDropManager {
    
    @discardableResult func updateDestinationColumn() -> Bool {
        guard let bundle = self.columnBundle else { return false }
        
        let pointOnDetectedView = self.canvas.convert(bundle.snapshotView.center, to: self.viewToDetect)
        var draggingFrame = bundle.snapshotView.frame
        draggingFrame.origin = CGPoint(x: pointOnDetectedView.x - bundle.offset.x, y: pointOnDetectedView.y - bundle.offset.y)
        
        var overlappingAreaMAX: CGFloat = 0.0
        var mainOverView: UIView?

        for index in self.columnViews.keys.sorted(by: <) {
            let view = self.columnViews[index]!
            let viewFrameOnCanvas = self.convertRectToCanvas(view.frame, fromView: view)
            
            let overlappingAreaCurrent = draggingFrame.intersection(viewFrameOnCanvas).area
            
            if overlappingAreaCurrent > overlappingAreaMAX {
                overlappingAreaMAX = overlappingAreaCurrent
                mainOverView = view
            }
        }
        
        if let dragAndDrop = self.scrollView as? DragAndDropPagingDelegate {
            if let overView = mainOverView {
                let rect = viewToDetect.convert(draggingFrame, to: self.viewToDetect)
                if dragAndDrop.dragAndDropView(canDropAt: rect) {
                    updateReoderColumns(dragAndDrop, overView, at: rect)
                }
            }
        }
        
        return false
    }
    
    fileprivate func updateReoderColumns(_ dragAndDrop: DragAndDropPagingDelegate, _ mainOverView: UIView?, at rect: CGRect) {
        
        guard let bundle = self.columnBundle else { return }
        if bundle.draggingView == mainOverView { return }
        
        dragAndDrop.dragAndDropView(willMove: bundle.dataItem, inRect: rect)
    }
    
    func updateColumnSnapshotViewOut(completion: @escaping () -> Void) {
        guard let bundle = self.columnBundle else { return }
        
        if let dragAndDrop = self.scrollView as? DragAndDropPagingDelegate {
            if let columnRectInView = dragAndDrop.draggingViewRect() {
                let viewRect = viewToDetect.convert(columnRectInView, to: self.canvas)
                let viewRectCenter = CGPoint(x: viewRect.midX, y: viewRect.midY)
                
                // If no values change inside a UIView animation block, the completion handler is called immediately.
                // This is a workaround for that case.
                if bundle.snapshotView.center == viewRectCenter {
                    bundle.snapshotView.center.y += 0.1
                }
                
                UIView.animate(
                    withDuration: animationDuration,
                    animations: {
                        bundle.snapshotView.center = viewRectCenter
                }, completion: { _ in
                    completion()
                })
                return
            }
        }
        completion()
    }
}
