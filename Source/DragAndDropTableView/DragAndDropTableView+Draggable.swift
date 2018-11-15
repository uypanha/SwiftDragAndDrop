//
//  DragAndDropTableView+Draggable.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/7/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

public protocol DraggableTableCell where Self: UITableViewCell {
    func representationImage() -> UIView?
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
        
        UIGraphicsBeginImageContextWithOptions(cellView.bounds.size, cellView.isOpaque, 0)
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
                cell.isHidden = true
            }
            
            (self.delegate as? DragAndDropTableViewDelegate)?.tableViewDidBeginDragging(self, at: indexToReload)
        }
    }
    
    public func draggableViewDidFinishDragging(_ isDroppedOnSource: Bool) {
        
        if let idx = self.draggingIndexPath {
            if let cell = self.cellForRow(at: idx) {
                cell.isHidden = false
            }
            
            if isDroppedOnSource {
                (self.delegate as? DragAndDropTableViewDelegate)?.tableView(self, didDropAt: idx)
            }
        }
        
        (self.delegate as? DragAndDropTableViewDelegate)?.tableViewDidFinishDragging(self)
        self.draggingIndexPath = nil
    }
}
