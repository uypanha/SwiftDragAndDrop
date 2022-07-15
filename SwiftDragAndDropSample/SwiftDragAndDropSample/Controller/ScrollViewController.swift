//
//  ScrollViewController.swift
//  SwiftDragAndDropSample
//
//  Created by Panha Uy on 5/7/22.
//

import UIKit
import SwiftDragAndDrop

class ScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: DragAndDropPagingScrollView!
    
    var titles = ["Backlog Short", "Backlog Long Terms", "To Do",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "Bug of Release", "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released",
                  "In Progress", "Fixed", "Done", "Stagging", "Released"]
    
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
            columnData.append(ColumnDataItem("\(index)",title: title, items: dataItems))
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
        
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension ScrollViewController: DragAndDropPagingScrollViewDataSource {
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, stylingRepresentation view: UIView) -> UIView? {
        view.layer.cornerRadius = 10
        return view
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, moveDataItem from: Int, to: Int) {
        let item = self.columnData[to]
        self.columnData[to] = self.columnData[from]
        self.columnData[from] = item
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
        tableView.title = columnData[index].title
        tableView.data = columnData[index]
        tableView.register(DragTableViewCell.self)
        tableView.dataSource = tableView.self
        tableView.delegate = tableView.self
        tableView.backgroundColor = UIColor.white
        return tableView
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, didLoadedViewColumns views: [Int: UIView]) {
        if self.dragAndDropManager == nil {
            self.dragAndDropManager = DragAndDropManager(canvas: self.scrollView, tableViews: views)
            self.dragAndDropManager?.columnSnapShotScale = 0.9
        } else {
            self.dragAndDropManager?.setSubViews(views)
        }
    }
}
