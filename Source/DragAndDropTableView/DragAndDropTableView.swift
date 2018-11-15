//
//  DragAndDropTableView.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 9/11/18.
//  Copyright © 2018 Mäd. All rights reserved.
//

import UIKit

// MARK: - DragAndDropTableViewDataSource

/**
 The datasource of a `DragAndDropTableView` must adopt the `DragAndDropTableViewDataSource` protocol. This protocol defines methods for handling the drag and drop of rows.
 */
public protocol DragAndDropTableViewDataSource: UITableViewDataSource {
    
//    func numberOfDraggableCells(in tableView: UITableView) -> Int
    func tableView(_ tableView: UITableView, indexPathOf dataItem: AnyObject) -> IndexPath?
    func tableView(_ tableView: UITableView, dataItemAt indexPath: IndexPath) -> AnyObject
    
    func tableView(_ tableView: UITableView, moveDataItem from: IndexPath, to: IndexPath) -> Void
    func tableView(_ tableView: UITableView, insert dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void
    func tableView(_ tableView: UITableView, deleteDataItemAt indexPath: IndexPath) -> Void
    
    /* optional */  func tableView(_ tableView: UITableView, cellIsDraggableAt indexPath: IndexPath) -> Bool
    /* optional */  func tableView(_ tableView: UITableView, cellIsDroppableAt indexPath: IndexPath) -> Bool
    /* optional */ func tableView(_ tableView: UITableView, stylingRepresentation view: UIView) -> UIView?
}

public extension DragAndDropTableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellIsDraggableAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellIsDroppableAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, stylingRepresentation view: UIView) -> UIView? {
        return view
    }
}

/**
 The delegate of a `DragAndDropTableView` must adopt the `DragAndDropTableViewDelegate` protocol. This protocol defines methods for handling the drag and drop of rows.
 */
public protocol DragAndDropTableViewDelegate: UITableViewDelegate {
    
    func tableViewDidBeginDragging(_ tableView: UITableView, at indexPath: IndexPath)
    
    func tableViewDidFinishDragging(_ tableView: UITableView)
    
    func tableView(_ tableView: UITableView, didDropAt indexPath: IndexPath)
    
}

public extension DragAndDropTableViewDelegate {
    
    func tableViewDidBeginDragging(_ tableView: UITableView, at indexPath: IndexPath){}
    
    func tableViewDidFinishDragging(_ tableView: UITableView){}
    
    func tableView(_ tableView: UITableView, didDropAt indexPath: IndexPath){}
}

public class DragAndDropTableView: UITableView, DragAndDropDelegate {
    
    // MARK: - Public interface
    
     /// Whether droppable is enabled.
    public var isDroppable: Bool = true
    
    public var draggingIndexPath : IndexPath?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    public func indexPathForCellOverlappingRect( _ rect : CGRect) -> IndexPath? {
        var overlappingArea : CGFloat = 0.0
        var cellCandidate : UITableViewCell?
        let dataSource = self.dataSource as? DragAndDropTableViewDataSource
        
        var lastIndexPath = IndexPath(row: 0, section: 0)
        if self.visibleCells.count > 0 {
            lastIndexPath = self.indexPath(for: self.visibleCells[self.visibleCells.count - 1]) ?? lastIndexPath
        }
        
        let visibleCells = self.visibleCells
        if visibleCells.count == 0 {
            return lastIndexPath
        }
        
        if  rect.origin.y > self.contentSize.height {
            if dataSource?.tableView(self, cellIsDroppableAt: lastIndexPath) == true {
                return lastIndexPath
            }
            return nil
        }
        
        visibleCells.filter {
            // Workaround for an iOS 11 bug.
            
            // When adding a row using UITableView.insertRows(...), if the new
            // row's frame will be partially or fully outside the table view's
            // bounds, and the new row is not the first row in the table view,
            // it's inserted without animation.
            
            let cellOverlapsTopBounds = $0.frame.minY < self.bounds.minY + 5
            let cellIsFirstCell = self.indexPath(for: $0) == IndexPath(row: 0, section: 0)
            
            return !cellOverlapsTopBounds || cellIsFirstCell
        }.forEach { visible in
            let intersection = visible.frame.intersection(rect)
            if (intersection.width * intersection.height) > overlappingArea {
                overlappingArea = intersection.width * intersection.height
                cellCandidate = visible
            }
        }
        
        if let cellRetrieved = cellCandidate, let indexPath = self.indexPath(for: cellRetrieved), dataSource?.tableView(self, cellIsDroppableAt: indexPath) == true {
            return self.indexPath(for: cellRetrieved)
        }
        return nil
    }
}
