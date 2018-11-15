//
//  ScrollViewController.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/13/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var titles = ["Backlog", "To Do", "In Progress", "Fixed", "Done", "Released", "Bug of Release"]
    var slides:[UIView] = []
    private var indexOfCellBeforeDragging = 0
    
    var dragAndDropManager : DragAndDropManager?
    var data  = [[DataItem]]()
    
    fileprivate var pageWidth: CGFloat {
        get {
            return scrollView.frame.width - 40
        }
    }
    fileprivate let spacingWidth: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var index = 0
        titles.forEach { (title) in
            let limit = ((index + 1) % 2) == 0 ? 15 : 0
            var dataItems = [DataItem]()
            if limit > 0 {
                dataItems = (0...limit).map({ (i) -> DataItem in
                    return DataItem("\(i)", UIColor.randomColor())
                })
            }
            data.append(dataItems)
            index += 1
        }
        
        scrollView.delegate = self
        
        // Do any additional setup after loading the view.
        self.removeAllSubView()
        self.slides = self.createSlides()
        setupSlideScrollView(slides: slides)
        self.dragAndDropManager = DragAndDropManager(canvas: self.scrollView, tableViews: self.slides)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.prepareSlideViews()
    }
}

extension ScrollViewController {
    
    func setupSlideScrollView(slides : [UIView]) {
        slides.forEach { slide in
            scrollView.addSubview(slide)
        }
        self.prepareSlideViews()
    }
    
    func prepareSlideViews() {
        let pageHeight = scrollView.frame.height
        
        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(slides.count) + (spacingWidth * CGFloat(slides.count - 1)), height: pageHeight)
        
        for i in 0 ..< self.slides.count {
            self.slides[i].frame = CGRect(x: (pageWidth + spacingWidth) * CGFloat(i), y: 0, width: pageWidth, height: pageHeight)
        }
    }
    
    func removeAllSubView() {
        scrollView.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }
    
    func totalSafeArea() -> CGFloat {
        var topSafeArea: CGFloat
        var bottomSafeArea: CGFloat
        
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        
        return topSafeArea + bottomSafeArea
    }
    
    func createSlides() -> [UIView] {
        var index = 0
        return titles.map({ title -> DragAndDropTableView in
            let tableView = TodoDragAndDropTableView()
            self.prepareTableView(tableView: tableView)
            tableView.title = title
            tableView.data = data[index]
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

extension ScrollViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        if scrollView == scrollView {
            let maxIndex = slides.count - 1
            let targetX: CGFloat = scrollView.contentOffset.x + velocity.x * 60.0
            var targetIndex = Int(round(Double(targetX / (pageWidth + spacingWidth))))
            var additionalWidth: CGFloat = 0
            var isOverScrolled = false
            
            if targetIndex <= 0 {
                targetIndex = 0
            } else {
                additionalWidth = 20
            }
            
            if targetIndex > maxIndex {
                targetIndex = maxIndex
                isOverScrolled = true
            }
            
            let velocityX = velocity.x
            var newOffset = CGPoint(x: (CGFloat(targetIndex) * (self.pageWidth + self.spacingWidth)) - additionalWidth, y: 0)
            if velocityX == 0 {
                // when velocityX is 0, the jumping animation will occured
                // if we don't set targetContentOffset.pointee to new offset
                if !isOverScrolled &&  targetIndex == maxIndex {
                    newOffset.x = scrollView.contentSize.width - scrollView.frame.width
                }
                targetContentOffset.pointee = newOffset
            }
            
            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(
                withDuration: 0.3, delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocityX,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = newOffset
                    scrollView.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

class TodoDragAndDropTableView: DragAndDropTableView, DragAndDropTableViewDataSource, DragAndDropTableViewDelegate {
    
    var title = ""
    var data = [DataItem]()
    
    var cellHeightsDictionary: [IndexPath: CGFloat] = [:]
    
    func tableView(_ tableView: UITableView, indexPathOf dataItem: AnyObject) -> IndexPath? {
        guard let candidate = dataItem as? DataItem else { return nil }
        
        for (i, item) in data.enumerated() {
            if candidate != item { continue }
            return IndexPath(item: i, section: 0)
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, dataItemAt indexPath: IndexPath) -> AnyObject {
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
            cell.isHidden = true
        }
        cell.title = self.data[indexPath.row].indexes
        cell.color = self.data[indexPath.row].colour
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
        return UITableView.automaticDimension
    }
}
