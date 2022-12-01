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

// MARK: - DraggableViewDelegate
extension DragAndDropPagingScrollView: DragAndDropPagingDelegate {
    
    public func draggingViewRect() -> CGRect? {
        if let index = self.draggingIndex, index < self.columnViews.count {
            return self.columnViews[index]?.frame
        }
        return nil
    }
    
    public func dragAndDropView(didBeginDraggingAt point: CGPoint) {
        self.draggingIndex = self.indexForColumn(at: point)
        if let indexToReload = self.draggingIndex {
            if indexToReload < self.columnViews.count {
                let view = columnViews[indexToReload]
                if view is DraggableItemViewDelegate {
                    (view as? DraggableItemViewDelegate)?.didBeginDragging()
                } else {
                    view?.isHidden = true
                }
            }
            self.pagingDelegate?.scrollViewDidBeginDragging(self, at: indexToReload)
        }
    }
    
    public func dragAndDropViewDidFinishDragging() {
        if let indexToReload = self.draggingIndex {
            let view = columnViews[indexToReload]
            if view is DraggableItemViewDelegate {
                (view as? DraggableItemViewDelegate)?.didFinishedDragging()
            } else {
                view?.isHidden = false
            }
            self.pagingDelegate?.scrollView(self, didDropAt: indexToReload)
        }
        
        self.pagingDelegate?.scrollViewDidFinishDragging(self)
        self.draggingIndex = nil
    }
    
    public func dragAndDropView(dataItemAt point: CGPoint) -> AnyObject? {
        guard let datasource = self.datasource else { return nil }
        guard let index = self.indexForColumn(at: point) else { return nil }
        return datasource.scrollView(self, dataItemAt: index)
    }
    
    public func dragAndDropView(stylingRepresentationView view: UIView) -> UIView? {
        guard let datasource = self.datasource else { return view }
        return datasource.scrollView(self, stylingRepresentation: view)
    }
    
    public func dragAndDropView(representationImageAt point: CGPoint) -> UIView? {
        guard let index = self.indexForColumn(at: point) else { return nil }
        
        guard index < self.columnViews.count else { return nil }
        let view = self.columnViews[index]
        
        let columnView: UIView = (view as? DraggableItemViewDelegate)?.representationImage() ?? view ?? .init()
        
        UIGraphicsBeginImageContextWithOptions(columnView.bounds.size, false, 0)
        columnView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: columnView.frame.origin.x, y: columnView.frame.origin.y, width: columnView.frame.width, height: columnView.frame.height)
        imageView.center = view?.center ?? .init()
        
        return imageView
    }
    
    public func dragAndDropView(canDragAt point: CGPoint) -> Bool {
        if let datasource = self.datasource, let indexOfPoint = self.indexForColumn(at: point) {
            return datasource.scrollView(self, columnIsDraggableAt: indexOfPoint)
        }
        
        return false
    }
    
    public func dragAndDropView(canDropAt rect: CGRect) -> Bool {
        return (self.indexForViewOverlappingRect(rect) != nil)
    }
    
    public func dragAndDropView(willMove item: AnyObject, inRect rect: CGRect) {
        if let fromIndex = self.draggingIndex, let toIndex = self.indexForViewOverlappingRect(rect) {
            if fromIndex != toIndex {
                self.datasource?.scrollView(self, moveDataItem: fromIndex, to: toIndex)
                self.draggingIndex = toIndex
                self.moveColumns(from: fromIndex, to: toIndex)
            }
        }
    }
    
    public func indexForColumn(at point: CGPoint) -> Int? {
        if self.columnViews.count > 0 {
            for index in 0...(self.columnViews.count - 1) {
                if self.movingColumns.contains(where: { (from, to) -> Bool in return index == from }) {
                    return nil
                } else if self.columnViews[index]?.frame.contains(point) == true {
                    return index
                }
            }
        }
        return nil
    }
    
    public func indexForViewOverlappingRect( _ rect : CGRect) -> Int? {
        var overlappingArea : CGFloat = 0.0
        var viewCandidate: UIView?
        
        let indexes = self.columnViews.keys.sorted(by: <)
        let lastIndex: Int = indexes.count > 0 ? (indexes.last ?? 0) : 0
        
        let visibleColumns = self.visibleColumnViews
        if visibleColumns.count == 0 {
            return lastIndex
        }
        
        if  rect.origin.y > self.contentSize.height {
            if self.datasource?.scrollView(self, columnIsDroppableAt: lastIndex) == true {
                return lastIndex
            }
            return nil
        }
        
        visibleColumns.forEach { view in
            let intersection = view.frame.intersection(rect)
            if (intersection.width * intersection.height) > overlappingArea {
                overlappingArea = intersection.width * intersection.height
                viewCandidate = view
            }
        }
        
        if let viewRetreived = viewCandidate {
            for item in self.columnViews {
                if item.value == viewRetreived {
                    return item.key
                }
            }
        }
        return nil
    }
    
    public func moveColumns(from index: Int, to: Int) {
        self.movingColumns.append((index, to))
        self.reloadColumns()
    }
}
