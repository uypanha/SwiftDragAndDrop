//
//  TodoDragAndDropTableView.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 4/18/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import SwiftDragAndDrop

class TodoDragAndDropTableView: DragAndDropTableView, DragAndDropTableViewDataSource, DragAndDropTableViewDelegate {
    
    var title = ""
    var data: ColumnDataItem!
    
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
    func tableView(_ tableView: UITableView, indexPathOf dataItem: AnyObject) -> IndexPath? {
        guard let candidate = dataItem as? DataItem else { return nil }
        
        for (i, item) in data.items.enumerated() {
            if candidate != item { continue }
            return IndexPath(item: i, section: 0)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, dataItemAt indexPath: IndexPath) -> AnyObject? {
        return data.items[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, moveDataItem from: IndexPath, to: IndexPath) {
        let fromDataItem: DataItem = data.items[from.item]
        data.items.remove(at: from.item)
        data.items.insert(fromDataItem, at: to.item)
    }
    
    func tableView(_ tableView: UITableView, insert dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        if let di = dataItem as? DataItem {
            data.items.insert(di, at: indexPath.item)
        }
    }
    
    func tableView(_ tableView: UITableView, deleteDataItemAt indexPath: IndexPath) {
        data.items.remove(at: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DragTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        if (tableView as? DragAndDropTableView)?.isDraggingCell(at: indexPath) == true {
            cell.isHidden = true
        }
        cell.title = self.data.items[indexPath.row].indexes
        cell.color = self.data.items[indexPath.row].colour
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.title
    }
    
    func tableViewDidBeginDragging(_ tableView: UITableView, at indexPath: IndexPath) {
        print("tableViewDidBeginDragging")
    }
    
    func tableViewDidFinishDragging(_ tableView: UITableView) {
        print("tableViewDidFinishDragging")
    }
    
    func tableView(_ tableView: UITableView, didDropAt indexPath: IndexPath) {
        print("didDropAt: \(indexPath)")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeightsDictionary[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = cellHeightsDictionary[indexPath] {
            return height
        }
        return UITableViewAutomaticDimension
    }
}

extension TodoDragAndDropTableView: DraggableItemViewDelegate {
    
    func representationImage() -> UIView? {
        return self
    }
    
    func didBeginDragging() {
        self.isHidden = true
    }
    
    func didFinishedDragging() {
        self.isHidden = false
    }
}
