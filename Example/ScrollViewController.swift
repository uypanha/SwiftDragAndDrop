//
//  ScrollViewController.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/13/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit
import SwiftDragAndDrop

class ScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: DragAndDropPagingScrollView!
    
    var titles = ["Backlog", "To Do", "In Progress", "Fixed", "Done", "Released", "Bug of Release"]
    
    var dragAndDropManager : DragAndDropManager?
    var columnData: [ColumnDataItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DragAndDrop UIScrollView"
        
        var index = 0
        titles.forEach { (title) in
            let limit = ((index + 1) % 2) == 0 ? 15 : 0
            var dataItems = [DataItem]()
            if limit > 0 {
                dataItems = (0...limit).map({ (i) -> DataItem in
                    return DataItem("\(i)", UIColor.randomColor())
                })
            }
            columnData.append(ColumnDataItem("\(index)", items: dataItems))
            index += 1
        }
        
        // Do any additional setup after loading the view.
        self.scrollView.datasource = self
    }
}

extension ScrollViewController {
    
    func createSlides() -> [UIView] {
        var index = 0
        return titles.map({ title -> DragAndDropTableView in
            let tableView = TodoDragAndDropTableView()
            self.prepareTableView(tableView: tableView)
            tableView.title = title
            tableView.data = columnData[index]
            tableView.register(DragTableViewCell.self)
            tableView.dataSource = tableView.self
            tableView.delegate = tableView.self
            tableView.backgroundColor = UIColor.white
            index += 1
            return tableView
        })
    }
    
    func prepareTableView(tableView: UITableView) {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension ScrollViewController: DragAndDropPagingScrollViewDataSource {
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, stylingRepresentation view: UIView) -> UIView? {
        view.layer.cornerRadius = 10
        return view
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, moveDataItem from: Int, to: Int) {
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, dataItemAt index: Int) -> AnyObject? {
        return columnData[index]
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, indexOf dataItem: AnyObject) -> Int? {
        guard let candidate = dataItem as? ColumnDataItem else { return nil }
        
        for (i, item) in columnData.enumerated() {
            if candidate != item { continue }
            return i
        }
        
        return nil
    }
    
    func numberOfColumns(in scrollView: DragAndDropPagingScrollView) -> Int {
        return self.titles.count
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, viewForColumnAt index: Int) -> UIView {
        let tableView = TodoDragAndDropTableView()
        self.prepareTableView(tableView: tableView)
        tableView.title = titles[index]
        tableView.data = columnData[index]
        tableView.register(DragTableViewCell.self)
        tableView.dataSource = tableView.self
        tableView.delegate = tableView.self
        tableView.backgroundColor = UIColor.white
        return tableView
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, didLoadedViewColumns views: [UIView]) {
        self.dragAndDropManager = DragAndDropManager(canvas: self.scrollView, tableViews: views)
    }
}

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
