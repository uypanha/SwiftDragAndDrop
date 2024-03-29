//
//  CollectionViewController.swift
//  SwiftDragAndDropSample
//
//  Created by Panha Uy on 5/7/22.
//

import UIKit
import SwiftDragAndDrop

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: DragAndDropPagingCollectionView!
    private var indexOfCellBeforeDragging = 0
    
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
    
    var columnData: [ColumnDataItem] = []
    
    var dragAndDropManager : DragAndDropManager?
    var views = [Int: UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DragAndDrop UICollectionView"
        // Makging scroll paging when it's phone
        self.collectionView.paging = UIDevice.current.userInterfaceIdiom == .phone
        
        var index = 0
        titles.forEach { (title) in
            let limit = ((index + 1) % 2) == 0 ? 15 : 0
            var dataItems = [DataItem]()
            if limit > 0 {
                dataItems = (0...limit).map({ (i) -> DataItem in
                    return DataItem("\(i)", UIColor.randomColor())
                })
            }
            columnData.append(ColumnDataItem("\(index)", title: title, items: dataItems))
            index += 1
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        self.prepareCollectionView()
        self.dragAndDropManager = DragAndDropManager(canvas: self.collectionView, tableViews: self.views)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        self.collectionView.pageWidth = self.view.frame.width - 60
        self.collectionView.padding = 30
    }
}

extension CollectionViewController: DragAndDropPagingCollectionViewDataSource {
    
    func collectionView(_ collectionView: DragAndDropPagingCollectionView, dataItemAt index: Int) -> AnyObject? {
        return self.columnData[index]
    }
    
    func numberOfColumns(in collectionView: DragAndDropPagingCollectionView) -> Int {
        return self.columnData.count
    }
    
    func collectionView(_ collectionView: DragAndDropPagingCollectionView, viewForColumnAt index: Int) -> UIView {
        let tableView = DragAndDropTableViewCell()
        tableView.title = columnData[index].title
        tableView.data = columnData[index].items
        self.views[index] = tableView
        self.dragAndDropManager?.setSubViews(self.views)
        return tableView
    }
    
    func collectionView(_ collectionView: DragAndDropPagingCollectionView, moveDataItem from: Int, to: Int) {
        let item = self.columnData[to]
        self.columnData[to] = self.columnData[from]
        self.columnData[from] = item
    }
}

extension CollectionViewController: DragAndDropCollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDropAt index: Int) {
    }
    
    func collectionViewDidBeginDragging(_ collectionView: UICollectionView, at index: Int) {
    }
    
    func collectionViewDidFinishDragging(_ collectionView: UICollectionView) {
        self.views.removeAll()
        self.collectionView.reloadData()
    }
}

// MARK: - Preparations
extension CollectionViewController {
    
    fileprivate func prepareCollectionView() {
        self.collectionView.pagingDelegate = self
        self.collectionView.pagingDatasource = self
    }
    
    private func calculateSectionInset() -> CGFloat {
        return 20
    }
}

class DragAndDropTableViewCell: DragAndDropTableView {
    
    var title: String = ""
    var data = [DataItem]()
    
    init() {
        super.init(frame: .init(), style: .plain)
        
        // Initialization code
        self.dataSource = self
        self.delegate = self
        self.prepareTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension DragAndDropTableViewCell {
    
    private func prepareTableView() {
        self.register(DragTableViewCell.self)
        self.tableFooterView = UIView()
    }
}

extension DragAndDropTableViewCell: DragAndDropTableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.title
    }
    
    func numberOfDraggableCells(in tableView: UITableView) -> Int {
        if data.count > 0 {
            return self.data.count - 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, indexPathOf dataItem: AnyObject) -> IndexPath? {
        guard let candidate = dataItem as? DataItem else { return nil }
        
        for (i, item) in data.enumerated() {
            if candidate != item { continue }
            return IndexPath(item: i, section: 0)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, dataItemAt indexPath: IndexPath) -> AnyObject? {
        return data[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, moveDataItem from: IndexPath, to: IndexPath) {
        let fromDataItem: DataItem = data[from.item]
        data.remove(at: from.item)
        data.insert(fromDataItem, at: to.item)
    }
    
    func tableView(_ tableView: UITableView, insert dataItem: AnyObject, atIndexPath indexPath: IndexPath) {
        if let di = dataItem as? DataItem {
            data.insert(di, at: indexPath.item)
        }
    }
    
    func tableView(_ tableView: UITableView, deleteDataItemAt indexPath: IndexPath) {
        data.remove(at: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DragTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.title = self.data[indexPath.row].indexes
        cell.color = self.data[indexPath.row].colour
        
        if (tableView as? DragAndDropTableView)?.isDraggingCell(at: indexPath) == true {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellIsDraggableAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellIsDroppableAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DragAndDropTableViewCell: DraggableItemViewDelegate {
    
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

extension UIColor {
    
    class func randomColor(randomAlpha randomApha:Bool = false)->UIColor{
        
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let alphaValue = randomApha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1;
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
        
    }
}
