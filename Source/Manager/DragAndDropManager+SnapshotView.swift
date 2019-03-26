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

extension DragAndDropManager {
    
    func createSnapshotViewForCell(_ recogniser : UILongPressGestureRecognizer) {
        self.removeSnapshotView()
        for view in views where view is DraggableViewDelegate  {
            
            if let draggable = view as? DraggableViewDelegate {
                let touchPointInView = recogniser.location(in: view)
                
                guard draggable.draggableView(canDragAt: touchPointInView) == true else { continue }
                
                guard var representation = draggable.draggableView(representationImageAt: touchPointInView) else { continue }
                representation.frame = self.canvas.convert(representation.frame, from: view)
                representation.layer.masksToBounds = false
                representation.layer.opacity = Float(cellOpacity)
                representation.layer.transform = CATransform3DMakeScale(cellScale, cellScale, 1)
                
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
                    
                    self.removeSnapshotView()
                    self.bundle = ReorderBundle(
                        offset: offset,
                        sourceDraggableView: view,
                        destinationDroppableView : view is DroppableViewDelegate ? view : nil,
                        snapshotView: representation,
                        dataItem : dataItem
                    )
                    
                    guard let bundle = self.bundle else { return }
                    self.canvas.addSubview(bundle.snapshotView)
                    return
                }
            }
        }
    }
    
    func removeSnapshotView() {
        guard let bundle = self.bundle else { return }
        bundle.snapshotView.removeFromSuperview()
        
        self.bundle = nil
    }
    
    func updateSnapshotViewPosition(_ pointOnCanvas: CGPoint) {
        guard let bundle = self.bundle else { return }
        
        var repImgFrame = bundle.snapshotView.frame
        repImgFrame.origin = CGPoint(x: pointOnCanvas.x - bundle.offset.x, y: pointOnCanvas.y - bundle.offset.y);
        bundle.snapshotView.frame = repImgFrame
    }
    
    func animateSnapshotViewIn() {
        guard let snapshotView = self.bundle?.snapshotView else { return }
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = self.cellOpacity
        opacityAnimation.duration = self.animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = 0
        shadowAnimation.toValue = self.shadowOpacity
        shadowAnimation.duration = self.animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = 1
        transformAnimation.toValue = self.cellScale
        transformAnimation.duration = self.animationDuration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        snapshotView.layer.add(opacityAnimation, forKey: nil)
        snapshotView.layer.add(shadowAnimation, forKey: nil)
        snapshotView.layer.add(transformAnimation, forKey: nil)
    }
    
    func animateSnapshotViewOut() {
        guard let snapshotView = self.bundle?.snapshotView else { return }
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = cellOpacity
        opacityAnimation.toValue = 1
        opacityAnimation.duration = animationDuration
        
        let shadowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowAnimation.fromValue = shadowOpacity
        shadowAnimation.toValue = 0
        shadowAnimation.duration = animationDuration
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.scale")
        transformAnimation.fromValue = cellScale
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
}
