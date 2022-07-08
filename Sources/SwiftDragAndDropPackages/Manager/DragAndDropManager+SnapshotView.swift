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
    
    func createSnapshotView(_ recogniser : UILongPressGestureRecognizer) {
        self.removeColumnSnapshitView()
        self.removeRowSnapshotView()
        
        createRowSnapshotView(recogniser)
        if self.rowBundle != nil { return }
        
        createColumnSnapshotView(recogniser)
    }
    
    fileprivate func createColumnSnapshotView(_ recogniser : UILongPressGestureRecognizer) {
        if let dragAndDrop = self.scrollView as? DragAndDropPagingScrollViewDelegate {
            
            let touchPointInView = recogniser.location(in: self.scrollView)
            
            guard dragAndDrop.dragAndDropView(canDragAt: touchPointInView) == true else { return }
            guard var representation = dragAndDrop.dragAndDropView(representationImageAt: touchPointInView) else { return }
            
            representation.frame = self.canvas.convert(representation.frame, from: scrollView)
            representation.layer.masksToBounds = false
            representation.layer.opacity = Float(snapshotOpacity)
            representation.layer.transform = CATransform3DMakeScale(columnSnapShotScale, columnSnapShotScale, 1)
            
            representation.layer.shadowColor = shadowColor.cgColor
            representation.layer.shadowOpacity = Float(shadowOpacity)
            representation.layer.shadowRadius = shadowRadius
            representation.layer.shadowOffset = shadowOffset
            if let decoredView = dragAndDrop.dragAndDropView(stylingRepresentationView: representation) {
                representation = decoredView
            }
            
            let pointOnCanvas = recogniser.location(in: self.canvas)
            let offset = CGPoint(x: pointOnCanvas.x - representation.frame.origin.x, y: 0)
            
            if let dataItem: AnyObject = dragAndDrop.dragAndDropView(dataItemAt: touchPointInView), let viewColumn = viewColumn(at: touchPointInView) {
                
                self.removeRowSnapshotView()
                self.columnBundle = ColumnReorderBundle(
                    offset: offset,
                    draggingView: viewColumn,
                    snapshotView: representation,
                    dataItem : dataItem
                )
                
                guard let bundle = self.columnBundle else { return }
                self.canvas.addSubview(bundle.snapshotView)
                return
            }
        }
    }
    
    fileprivate func createRowSnapshotView(_ recogniser : UILongPressGestureRecognizer) {
        
        func createSnapshot(representation: UIView, touchPointInView: CGPoint, view: UIView) -> Bool {
            var representation = representation
            if let draggable = view as? DraggableViewDelegate {
                representation.frame = self.canvas.convert(representation.frame, from: view)
                representation.layer.masksToBounds = false
                representation.layer.opacity = Float(snapshotOpacity)
                representation.layer.transform = CATransform3DMakeScale(rowSnapShotScale, rowSnapShotScale, 1)
                
                representation.layer.shadowColor = shadowColor.cgColor
                representation.layer.shadowOpacity = Float(shadowOpacity)
                representation.layer.shadowRadius = shadowRadius
                representation.layer.shadowOffset = shadowOffset
                if let decoredView = draggable.draggableView(stylingRepresentationView: representation) {
                    representation = decoredView
                }
                
                let pointOnCanvas = recogniser.location(in: self.canvas)
                let offset = CGPoint(x: pointOnCanvas.x - representation.frame.origin.x, y: pointOnCanvas.y - representation.frame.origin.y)
                
                if let dataItem: AnyObject = draggable.draggableView(dataItemAt: touchPointInView) {
                    
                    self.removeRowSnapshotView()
                    self.rowBundle = RowReorderBundle(
                        offset: offset,
                        sourceDraggableView: view,
                        destinationDroppableView : view is DroppableViewDelegate ? view : nil,
                        snapshotView: representation,
                        dataItem : dataItem
                    )
                    
                    guard let bundle = self.rowBundle else { return false }
                    self.canvas.addSubview(bundle.snapshotView)
                    return true
                }
            }
            return false
        }
        
        if let collectionView = self.scrollView as? UICollectionView {
            print("Content Size = \(collectionView.contentSize)")
            var touchPointInView = recogniser.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: touchPointInView) {
                if let view = self.tableViews[indexPath.row] {
                    if let draggable = view as? DraggableViewDelegate {
                        touchPointInView = recogniser.location(in: view)
                        touchPointInView.x = view.frame.width / 2
                        guard draggable.draggableView(canDragAt: touchPointInView) == true else { return }
                        guard let representation = draggable.draggableView(representationImageAt: touchPointInView) else { return }
                        if createSnapshot(representation: representation, touchPointInView: touchPointInView, view: view) {
                            return
                        }
                    }
                }
            }
        } else {
            for view in tableViews where view is DraggableViewDelegate  {
                
                if let draggable = view.value as? DraggableViewDelegate {
                    let touchPointInView = recogniser.location(in: view.value)
                    
                    guard draggable.draggableView(canDragAt: touchPointInView) == true else { continue }
                    
                    guard let representation = draggable.draggableView(representationImageAt: touchPointInView) else { continue }
                    if createSnapshot(representation: representation, touchPointInView: touchPointInView, view: view.value) {
                        return
                    }
                }
            }
        }
    }
    
    func removeColumnSnapshitView() {
        guard let columnBundle = self.columnBundle else { return }
        columnBundle.snapshotView.removeFromSuperview()
        
        self.columnBundle = nil
    }
    
    func removeRowSnapshotView() {
        guard let rowBundle = self.rowBundle else { return }
        rowBundle.snapshotView.removeFromSuperview()
        
        self.rowBundle = nil
    }
    
    func updateRowSnapshotViewPosition(_ pointOnCanvas: CGPoint) {
        guard let bundle = self.rowBundle else { return }
        
        var repImgFrame = bundle.snapshotView.frame
        repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundle.offset.x, y: pointOnCanvas.y - bundle.offset.y);
        bundle.snapshotView.frame = repImgFrame
    }
    
    func updateColumnSnapshotViewPosition(_ pointOnCanvas: CGPoint) {
        guard let bundle = self.columnBundle else { return }
        
        var repImgFrame = bundle.snapshotView.frame
        repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundle.offset.x, y: repImgFrame.origin.y);
        bundle.snapshotView.frame = repImgFrame
    }
    
    func animateSnapshotViewIn() {
        guard let snapshotView = self.rowBundle?.snapshotView ?? self.columnBundle?.snapshotView else { return }
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = self.snapshotOpacity
        opacityAnimation.duration = self.animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = 0
        shadowAnimation.toValue = self.shadowOpacity
        shadowAnimation.duration = self.animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = 1
        transformAnimation.toValue = self.rowBundle != nil ? self.rowSnapShotScale : self.columnSnapShotScale
        transformAnimation.duration = self.animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
    }
    
    func animateSnapshotViewOut() {
        guard let snapshotView = self.rowBundle?.snapshotView ?? self.columnBundle?.snapshotView else { return }
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = snapshotOpacity
        opacityAnimation.toValue = 1
        opacityAnimation.duration = animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = shadowOpacity
        shadowAnimation.toValue = 0
        shadowAnimation.duration = animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = self.rowBundle != nil ? self.rowSnapShotScale : self.columnSnapShotScale
        transformAnimation.toValue = 1
        transformAnimation.duration = animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
        
        snapshotView.layer.opacity = 1
        snapshotView.layer.shadowOpacity = 0
        snapshotView.layer.transform = CATransform3DIdentity
    }
    
    public func viewColumn(at point: CGPoint) -> UIView? {
        if self.columnViews.count > 0 {
            for index in 0...(self.columnViews.count - 1) {
                if self.columnViews[index]?.frame.contains(point) == true { return self.columnViews[index] }
            }
        }
        return nil
    }
}
