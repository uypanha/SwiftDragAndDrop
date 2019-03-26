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

public protocol DragAndDropDelegate {
    
    func dragAndDropViewBeginUpdate(_ update: () -> Void, _ finished: @escaping () -> Void)
    
    func dragAndDropViewEndUpdate()
    
}

public extension DragAndDropDelegate where Self: UITableView {
    
    func dragAndDropViewBeginUpdate(_ update: () -> Void, _ finished: @escaping () -> Void) {
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                update()
            }) { _ in
                finished()
            }
            self.layer.removeAllAnimations()
        } else {
            self.beginUpdates()
        }
    }
    
    func dragAndDropViewEndUpdate() {
        guard #available(iOS 11.0, *) else {
            // Fallback on earlier versions backward of iOS 11
            self.endUpdates()
            return
        }
    }
}

public protocol DraggableViewDelegate {
    
    var draggingIndexPath : IndexPath? { get set }
    
    func draggableView(canDragAt point : CGPoint) -> Bool
    
    func draggableView(representationImageAt point : CGPoint) -> UIView?
    
    func draggableView(stylingRepresentationView view: UIView) -> UIView?
    
    func draggableView(dataItemAt point : CGPoint) -> AnyObject?
    
    func draggableView(dragData item : AnyObject) -> Void
    
    /* optional */ func draggableView(didBeginDraggingAt point: CGPoint) -> Void
    
    /* optional */ func draggableViewDidFinishDragging(_ isDroppedOnSource: Bool)
    
    /* optional */ func isDraggingCell(at indexPath: IndexPath) -> Bool
}

extension DraggableViewDelegate {
    
    public func draggableView(didBeginDraggingAt point : CGPoint) -> Void {}
    
    public func draggableViewDidFinishDragging(_ isDroppedOnSource: Bool) {}
    
    public func isDraggingCell(at indexPath: IndexPath) -> Bool {
        return draggingIndexPath?.item == indexPath.item
    }
}


public protocol DroppableViewDelegate {
    
    func droppableView(canDropAt rect: CGRect) -> Bool
    
    func droppableView(willMove item: AnyObject, inRect rect: CGRect) -> Void
    
    func droppableView(autoScroll displayLink: CADisplayLink?, lastAutoScroll timeStamp: CFTimeInterval?, snapshotView rect: CGRect) -> Bool
    
    func droppableView(didMove item : AnyObject, inRect rect : CGRect) -> Void
    
    func droppableView(didMoveOut item : AnyObject) -> Void
    
    func droppableView(dropData item : AnyObject, atRect : CGRect) -> Void
    
    func droppableViewCellRect() -> CGRect?
}

public class DragAndDropManager: NSObject {
    
    var canvas : UIView
    var scrollView: UIScrollView? = nil
    var views : [UIView]
    
    var viewToDetect: UIView {
        get {
            if let view = self.scrollView {
                return view
            }
            return self.canvas
        }
    }
    
    var autoScrollDisplayLink: CADisplayLink?
    var lastAutoScrollTimeStamp: CFTimeInterval?
    
    /// The duration of the cell selection animation.
    public var animationDuration: TimeInterval = 0.2
    
    /// The opacity of the selected cell.
    public var cellOpacity: CGFloat = 1
    
    /// The scale factor for the selected cell.
    public var cellScale: CGFloat = 1
    
    /// The shadow color for the selected cell.
    public var shadowColor: UIColor = .black
    
    /// The shadow opacity for the selected cell.
    public var shadowOpacity: CGFloat = 0.3
    
    /// The shadow radius for the selected cell.
    public var shadowRadius: CGFloat = 10
    
    /// The shadow offset for the selected cell.
    public var shadowOffset = CGSize(width: 0, height: 3)
    
    /// Whether or not autoscrolling is enabled
    public var autoScrollEnabled = true
    
    // MARK: - Internal Bundle
    struct ReorderBundle {
        var offset : CGPoint = CGPoint.zero
        var sourceDraggableView : UIView
        var destinationDroppableView : UIView?
        var snapshotView : UIView
        var dataItem : AnyObject
    }
    
    var bundle : ReorderBundle?
    
    lazy var reorderGestureRecognizer: UILongPressGestureRecognizer = {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DragAndDropManager.updateForLongPress(_:)))
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.3
        return gestureRecognizer
    }()
    
    public init(canvas : UIView, tableViews : [UIView]) {
        
        guard let superView = canvas.superview else {
            fatalError("Canvas must be inside a view")
        }
        if let scrollView = canvas as? UIScrollView {
            self.scrollView = scrollView
        }
        self.canvas = superView
        self.views = tableViews
        
        super.init()
        
        self.canvas.isMultipleTouchEnabled = false
        self.canvas.addGestureRecognizer(self.reorderGestureRecognizer)
    }
    
    public func append(element tableView: UIView) {
        self.views.append(tableView)
    }
    
    // MARK: - Reordering
    func beginReorder(_ recogniser : UILongPressGestureRecognizer) {
        createSnapshotViewForCell(recogniser)
        animateSnapshotViewIn()
        if self.scrollView != nil {
            activateAutoScrollDisplayLink(recogniser)
        }
        
        guard let bundle = self.bundle else { return }
        let sourceDraggable : DraggableViewDelegate = bundle.sourceDraggableView as! DraggableViewDelegate
        let pointOnSourceDraggable = recogniser.location(in: bundle.sourceDraggableView)
        sourceDraggable.draggableView(didBeginDraggingAt: pointOnSourceDraggable)
    }
    
    func updateReorder(_ recogniser: UIGestureRecognizer) {
        guard let _ = self.bundle else { return }
        
        let pointOnCanvas = recogniser.location(in: recogniser.view)
        updateSnapshotViewPosition(pointOnCanvas)
        updateDestinationRow()
    }
    
    func endReorder(_ recogniser: UIGestureRecognizer) {
        guard let bundle = self.bundle else { return }
        
        let pointOnDetectedView = recogniser.location(in: self.viewToDetect)
        let sourceDraggable : DraggableViewDelegate = bundle.sourceDraggableView as! DraggableViewDelegate
        var destinationView = bundle.sourceDraggableView
        var droppable: DroppableViewDelegate? = nil
        
        // if we are actually dropping over a new view.
        if bundle.sourceDraggableView != bundle.destinationDroppableView {
            
            if let droppableDelegate = bundle.destinationDroppableView as? DroppableViewDelegate {
                sourceDraggable.draggableView(dragData: bundle.dataItem)
                
                droppable = droppableDelegate
                destinationView = bundle.destinationDroppableView!
            }
        }
        
        animateSnapshotViewOut()
        updateSnapshotViewOut(destinationView: destinationView) {
            var isDropppedOnSource = true
            if droppable != nil {
                // Update the frame of the representation image
                var draggingFrame = bundle.snapshotView.frame
                draggingFrame.origin = CGPoint(x: pointOnDetectedView.x - bundle.offset.x, y: pointOnDetectedView.y - bundle.offset.y)
                let rect = self.viewToDetect.convert(draggingFrame, to: bundle.destinationDroppableView)
                droppable?.droppableView(dropData: bundle.dataItem, atRect: rect)
                isDropppedOnSource = false
            }
            
            sourceDraggable.draggableViewDidFinishDragging(isDropppedOnSource)
            self.removeSnapshotView()
        }
        clearAutoScrollDisplayLink()
    }
    
    // MARK: Helper Methods
    func convertRectToCanvas(_ rect : CGRect, fromView view : UIView) -> CGRect {
        
        var r = rect
        var v = view
        
        while v != self.canvas {
            
            guard let sv = v.superview else { break; }
            
            r.origin.x += sv.frame.origin.x
            r.origin.y += sv.frame.origin.y
            
            v = sv
        }
        
        return r
    }
}
