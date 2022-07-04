//
// Copyright (c) 2019 Phanha UY
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
    var views = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DragAndDrop UICollectionView"
        
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
    
    func numberOfColumns(in collectionView: DragAndDropPagingCollectionView) -> Int {
        return self.columnData.count
    }
    
    func collectionView(_ collectionView: DragAndDropPagingCollectionView, viewForColumnAt index: Int) -> UIView {
        let tableView = DragAndDropTableViewCell()
        tableView.data = columnData[index].items
        self.views.insert(tableView, at: index)
        self.dragAndDropManager?.setSubViews(self.views)
        return tableView
    }
}

// MARK: - Preparations
extension CollectionViewController {
    
    fileprivate func prepareCollectionView() {
        self.collectionView.pagingDelegate = self
    }
    
    private func calculateSectionInset() -> CGFloat {
        return 20
    }
    
//    private func configureCollectionViewLayoutItemSize() {
//        let inset: CGFloat = calculateSectionInset() // This inset calculation is some magic so the next and the previous cells will peek from the sides. Don't worry about it
//        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
//        collectionViewLayout.itemSize = CGSize(width: self.collectionView.frame.width - (inset * 2), height: collectionView.frame.height)
//    }
    
//    private func indexOfMajorCell() -> Int {
//        let itemWidth = collectionViewLayout.itemSize.width
//        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
//        let index = Int(round(proportionalOffset))
//        let safeIndex = max(0, min(9/*dataSource.count - 1*/, index))
//        return safeIndex
//    }
}

//extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return titles.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: DragCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DragCollectionViewCell", for: indexPath) as! DragCollectionViewCell
//        if !self.views.contains(cell.tableView) {
//            self.views.append(cell.tableView)
//
//            self.dragAndDropManager = DragAndDropManager(canvas: self.collectionView, tableViews: self.views)
//        }
//        cell.data = columnData[indexPath.section].items
//        cell.reloadData()
//        return cell
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.indexOfCellBeforeDragging = indexOfMajorCell()
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        // Stop scrollView sliding:
//        targetContentOffset.pointee = scrollView.contentOffset
//
//        // calculate where scrollView should snap to:
//        let indexOfMajorCell = self.indexOfMajorCell()
//
//        // calculate conditions:
//        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
//        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < titles.count /*dataSource.count*/ && velocity.x > swipeVelocityThreshold
//        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
//        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
//        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
//
//        if didUseSwipeToSkipCell {
//
//            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
//            let toValue = collectionViewLayout.itemSize.width * CGFloat(snapToIndex)
//
//            // Damping equal 1 => no oscillations => decay animation:
//            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
//                scrollView.contentOffset = CGPoint(x: toValue, y: 0)
//                scrollView.layoutIfNeeded()
//            }, completion: nil)
//
//        } else {
//            // This is a much better way to scroll to a cell:
//            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
//            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
//    }
//}

class DragAndDropTableViewCell: DragAndDropTableView {
    
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

//class DragCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var tableView: DragAndDropTableView!
//
//    var data = [DataItem]()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        // Initialization code
//        self.tableView.dataSource = self
//        self.tableView.delegate = self
//
//        self.prepareTableView()
//    }
//
//    func reloadData() {
//        self.tableView.reloadData()
//    }
//}

extension DragAndDropTableViewCell {
    
    private func prepareTableView() {
        self.register(DragTableViewCell.self)
        self.tableFooterView = UIView()
    }
}

extension DragAndDropTableViewCell: DragAndDropTableViewDataSource, UITableViewDelegate {
    
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
        if (tableView as? DragAndDropTableView)?.isDraggingCell(at: indexPath) == true {
            cell.backgroundColor = .green
        }
        cell.title = self.data[indexPath.row].indexes
        cell.color = self.data[indexPath.row].colour
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellIsDraggableAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellIsDroppableAt indexPath: IndexPath) -> Bool {
        return true
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
