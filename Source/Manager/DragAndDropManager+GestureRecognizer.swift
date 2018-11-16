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
