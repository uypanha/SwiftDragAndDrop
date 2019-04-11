//
//  DragAndDropPagingScrollView+DragAndDrop.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 4/11/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

// MARK: - DraggableViewDelegate
extension DragAndDropPagingScrollView: DragAndDropPagingScrollViewDelegate {
    
    public func draggingViewRect() -> CGRect? {
        if let index = self.draggingIndex, index < self.columnViews.count {
            return self.columnViews[index].frame
        }
        return nil
    }
    
    public func dragAndDropView(didBeginDraggingAt point: CGPoint) {
        self.draggingIndex = self.indexForColumn(at: point)
        if let indexToReload = self.draggingIndex {
            if indexToReload < self.columnViews.count {
                let view = columnViews[indexToReload]
                if view is DraggableItemViewDelegate {
                    (view as? DraggableItemViewDelegate)?.cellDidBeginDragging()
                } else {
                    view.isHidden = true
                }
            }
//            (self.delegate as? DragAndDropTableViewDelegate)?.tableViewDidBeginDragging(self, at: indexToReload)
        }
    }
    
    public func dragAndDropViewDidFinishDragging() {
        if let indexToReload = self.draggingIndex {
            let view = columnViews[indexToReload]
            if view is DraggableItemViewDelegate {
                (view as? DraggableItemViewDelegate)?.cellDidFinishedDragging()
            } else {
                view.isHidden = false
            }
            //            if isDroppedOnSource {
            //                (self.delegate as? DragAndDropTableViewDelegate)?.tableView(self, didDropAt: idx)
            //            }
        }
        
//        (self as? DragAndDropTableViewDelegate)?.tableViewDidFinishDragging(self)
        self.draggingIndex = nil
    }
    
    public func dragAndDropView(dragData item: AnyObject) {
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
        
        let columnView: UIView = (view as? DraggableItemViewDelegate)?.representationImage() ?? view
        
        UIGraphicsBeginImageContextWithOptions(columnView.bounds.size, false, 0)
        columnView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: columnView.frame.origin.x, y: columnView.frame.origin.y, width: columnView.frame.width, height: columnView.frame.height)
        imageView.center = view.center
        
        return imageView
    }
    
    public func dragAndDropView(canDragAt point: CGPoint) -> Bool {
        if let datasource = self.datasource, let indexOfPoint = self.indexForColumn(at: point) {
            return datasource.scrollView(self, columnIsDraggableAt: indexOfPoint)
        }
        
        return false
    }
    
    public func indexForColumn(at point: CGPoint) -> Int? {
        if self.columnViews.count > 0 {
            for index in 0...(self.columnViews.count - 1) {
                if self.columnViews[index].frame.contains(point) { return index }
            }
        }
        return nil
    }
}
