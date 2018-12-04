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

/**
 A`UITableViewCell` must adopt the `DraggableTableCell` protocol if the cell want to representation another view as snapshot instead of cell view. This protocol defines methods for handling the representationImage, how cell look like of being dragging and after it's dropped.
 */
public protocol DraggableTableCell {
    
    func representationImage() -> UIView?
    
    func cellDidBeginDragging()
    
    func cellDidFinishedDragging()
    
}

// MARK: - DraggableViewDelegate
extension DragAndDropTableView: DraggableViewDelegate {
    
    public func draggableView(dragData item: AnyObject) {
        guard let dragDropDataSource = self.dataSource as? DragAndDropTableViewDataSource else {
            return
        }
        
        guard let existngIndexPath = dragDropDataSource.tableView(self, indexPathOf: item) else {
            return
        }
        
        dragDropDataSource.tableView(self, deleteDataItemAt: existngIndexPath)
        self.deleteRows(at: [existngIndexPath], with: .fade)
    }
    
    public func draggableView(stylingRepresentationView view: UIView) -> UIView? {
        guard let datasource = self.dataSource as? DragAndDropTableViewDataSource else {
            return nil
        }
        return datasource.tableView(self, stylingRepresentation: view)
    }
    
    public func draggableView(canDragAt point : CGPoint) -> Bool {
        if let dataSource = self.dataSource as? DragAndDropTableViewDataSource,
            let indexPathOfPoint = self.indexPathForRow(at: point) {
            return dataSource.tableView(self, cellIsDraggableAt: indexPathOfPoint)
        }
        
        return false
    }
    
    public func draggableView(representationImageAt point : CGPoint) -> UIView? {
        guard let indexPath = self.indexPathForRow(at: point) else {
            return nil
        }
        
        guard let cell = self.cellForRow(at: indexPath) else {
            return nil
        }
        
        let cellView: UIView = (cell as? DraggableTableCell)?.representationImage() ?? cell
        
        UIGraphicsBeginImageContextWithOptions(cellView.bounds.size, false, 0)
        cellView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cellView.frame.width, height: cellView.frame.height)
        imageView.center = cell.center
        
        return imageView
    }
    
    public func draggableView(dataItemAt point : CGPoint) -> AnyObject? {
        
        guard let indexPath = self.indexPathForRow(at: point) else {
            return nil
        }
        
        guard let dragDropDS = self.dataSource as? DragAndDropTableViewDataSource else {
            return nil
        }
        
        return dragDropDS.tableView(self, dataItemAt: indexPath)
    }
    
    public func draggableView(didBeginDraggingAt point : CGPoint) -> Void {
        
        self.draggingIndexPath = self.indexPathForRow(at: point)
        if let indexToReload = self.draggingIndexPath {
            if let cell = self.cellForRow(at: indexToReload) {
                if cell is DraggableTableCell {
                    (cell as? DraggableTableCell)?.cellDidBeginDragging()
                } else {
                    cell.isHidden = true
                }
            }
            
            (self.delegate as? DragAndDropTableViewDelegate)?.tableViewDidBeginDragging(self, at: indexToReload)
        }
    }
    
    public func draggableViewDidFinishDragging(_ isDroppedOnSource: Bool) {
        
        if let idx = self.draggingIndexPath {
            if let cell = self.cellForRow(at: idx) {
                if cell is DraggableTableCell {
                    (cell as? DraggableTableCell)?.cellDidFinishedDragging()
                } else {
                    cell.isHidden = false
                }
            }
            
            if isDroppedOnSource {
                (self.delegate as? DragAndDropTableViewDelegate)?.tableView(self, didDropAt: idx)
            }
        }
        
        (self.delegate as? DragAndDropTableViewDelegate)?.tableViewDidFinishDragging(self)
        self.draggingIndexPath = nil
    }
}
