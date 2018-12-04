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

// MARK: DropableViewDelegate
extension DragAndDropTableView: DroppableViewDelegate {
    
    public func droppableViewCellRect() -> CGRect? {
        if let index = draggingIndexPath {
            return self.rectForRow(at: index)
        }
        
        return nil
    }
    
    public func droppableView(canDropAt rect : CGRect) -> Bool {
        return (self.indexPathForCellOverlappingRect(rect) != nil) && self.isDroppable
    }
    
    public func droppableView(willMove item: AnyObject, inRect rect: CGRect) -> Void {
        
        // its guaranteed to have a data source
        let dragDropDataSource = self.dataSource as! DragAndDropTableViewDataSource
        
        if let _ = dragDropDataSource.tableView(self, indexPathOf: item) {
            // if data item exists
            return
        }
        
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            dragDropDataSource.tableView(self, insert: item, atIndexPath: indexPath)
            self.draggingIndexPath = indexPath
            self.insertRows(at: [indexPath], with: .fade)
        }
    }
    
    public func droppableView(didMove item : AnyObject, inRect rect : CGRect) -> Void {
        
        let dragDropDataSource = self.dataSource as! DragAndDropTableViewDataSource // guaranteed to have a ds
        
        if  let existingIndexPath = dragDropDataSource.tableView(self, indexPathOf: item),
            let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            if indexPath.item != existingIndexPath.item {
                
                dragDropDataSource.tableView(self, moveDataItem: existingIndexPath, to: indexPath)
                self.draggingIndexPath = indexPath
                self.moveRow(at: existingIndexPath, to: indexPath)
            }
        }
        
    }
    
    public func droppableView(autoScroll displayLink: CADisplayLink?, lastAutoScroll timeStamp: CFTimeInterval?, snapshotView rect: CGRect) -> Bool {
        guard let display = displayLink, let lasScrollTimeStamp = timeStamp else {
            return false
        }
        return self.handleDisplayLinkUpdate(autoScroll: display, lastAutoScroll: lasScrollTimeStamp, snapshotView: rect)
    }
    
    public func droppableView(didMoveOut item : AnyObject) -> Void {
        
        guard let dragDropDataSource = self.dataSource as? DragAndDropTableViewDataSource,
            let existngIndexPath = dragDropDataSource.tableView(self, indexPathOf: item) else {
                return
        }
        
        dragDropDataSource.tableView(self, deleteDataItemAt: existngIndexPath)
        self.deleteRows(at: [existngIndexPath], with: .fade)
        
        if let idx = self.draggingIndexPath {
            if let cell = self.cellForRow(at: idx) {
                if cell is DraggableTableCell {
                    (cell as? DraggableTableCell)?.cellDidFinishedDragging()
                } else {
                    cell.isHidden = false
                }
            }
        }
        
        self.draggingIndexPath = nil
    }
    
    public func droppableView(dropData item : AnyObject, atRect : CGRect) -> Void {
        
        if let index = draggingIndexPath {
            (self.delegate as? DragAndDropTableViewDelegate)?.tableView(self, didDropAt: index)
        } else if let indexPath = (dataSource as? DragAndDropTableViewDataSource)?.tableView(self, indexPathOf: item) {
            (self.delegate as? DragAndDropTableViewDelegate)?.tableView(self, didDropAt: indexPath)
        }
        
        self.draggingIndexPath = nil
        self.reloadData()
    }
}
