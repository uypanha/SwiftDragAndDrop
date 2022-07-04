//
//  DragAndDropPagingCollectionView.swift
//  SwiftDragAndDrop
//
//  Created by Panha Uy on 1/7/22.
//  Copyright © 2022 Phanha Uy. All rights reserved.
//

import UIKit

/**
 The datasource of a `DragAndDropView` must adopt the `DragAndDropPagingCollectionViewDataSource` protocol. This protocol defines methods for handling the drag and drop of rows.
 */
public protocol DragAndDropPagingCollectionViewDataSource {
    
    func numberOfColumns(in collectionView: DragAndDropPagingCollectionView) -> Int
    
    func collectionView(_ collectionView: DragAndDropPagingCollectionView, viewForColumnAt index: Int) -> UIView
}

open class DragAndDropPagingCollectionView: UICollectionView {
    
    open var pagingDelegate: DragAndDropPagingCollectionViewDataSource?
    
    public lazy var pageWidth: CGFloat = { [unowned self] in
        return self.frame.width - 40
    }()
    public lazy var spacingWidth: CGFloat = 0
    public var padding: CGFloat = 20
    
    public var columnViews: [UIView] = []
    private var indexOfCellBeforeDragging = 0
    
    public init() {
        super.init(frame: .init(), collectionViewLayout: UICollectionViewFlowLayout())
        
        setUpViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpViews()
    }
    
    open override func reloadData() {
        self.columnViews.removeAll()
        super.reloadData()
    }
    
    private func collumnView(at indexPath: IndexPath) -> UIView {
        if indexPath.row > (self.columnViews.count - 1) {
            if let view = self.pagingDelegate?.collectionView(self, viewForColumnAt: indexPath.row) {
                self.columnViews.insert(view, at: indexPath.row)
            }
        }
        return self.columnViews[indexPath.row]
    }
}

// MARK: - Preparations & Tools
extension DragAndDropPagingCollectionView {
    
    private func setUpViews() {
        self.register(DragAndDropCollectionViewCell.self, forCellWithReuseIdentifier: "DragAndDropCollectionViewCell")
        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        if #available(iOS 10.0, *) {
            self.isPrefetchingEnabled = true
        }
        self.delegate = self
        self.dataSource = self
        
        if let collectionViewFlowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewFlowLayout.scrollDirection = .horizontal
            collectionViewFlowLayout.minimumLineSpacing = self.spacingWidth
            collectionViewFlowLayout.minimumInteritemSpacing = self.spacingWidth
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DragAndDropPagingCollectionView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: self.padding, bottom: 0, right: self.padding)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset

        // calculate where scrollView should snap to:
        let indexOfMajorCell = self.indexOfMajorCell()

        // calculate conditions:
        let numberOfColumns = self.numberOfItems(inSection: 0)
        let swipeVelocityThreshold: CGFloat = 0.5 // after some trail and error
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < numberOfColumns && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = (self.pageWidth + self.spacingWidth) * CGFloat(snapToIndex)

            // Damping equal 1 => no oscillations => decay animation:
            UIView.animate(
                withDuration: 0.3,
                delay: 0, usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.x,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                }, completion: nil)
        } else {
            // This is a much better way to scroll to a cell:
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionViewLayout.collectionView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.indexOfCellBeforeDragging = indexOfMajorCell()
    }
    
    private func indexOfMajorCell() -> Int {
        let itemCount = self.numberOfItems(inSection: 0)
        let itemWidth = self.pageWidth
        let proportionalOffset = collectionViewLayout.collectionView!.contentOffset.x / itemWidth
        let index = Int(round(proportionalOffset))
        let safeIndex = max(0, min(itemCount, index))
        return safeIndex
    }
}

// MARK: - UICollectionViewDataSource
extension DragAndDropPagingCollectionView: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DragAndDropCollectionViewCell", for: indexPath) as? DragAndDropCollectionViewCell {
            cell.setContentView(self.collumnView(at: indexPath))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            cell.backgroundColor = .red
            return cell
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pagingDelegate?.numberOfColumns(in: self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: self.pageWidth, height: self.frame.height)
    }
}