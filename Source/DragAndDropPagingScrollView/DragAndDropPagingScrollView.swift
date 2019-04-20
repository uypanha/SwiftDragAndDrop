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

/**
 The datasource of a `DragAndDropView` must adopt the `DragAndDropPagingScrollViewDataSource` protocol. This protocol defines methods for handling the drag and drop of rows.
 */
public protocol DragAndDropPagingScrollViewDataSource {
    
    func numberOfColumns(in scrollView: DragAndDropPagingScrollView) -> Int
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, viewForColumnAt index: Int) -> UIView
    func scrollView(_ scrollView: DragAndDropPagingScrollView, indexOf dataItem: AnyObject) -> Int?
    func scrollView(_ scrollView: DragAndDropPagingScrollView, dataItemAt index: Int) -> AnyObject?
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, moveDataItem from: Int, to: Int) -> Void
    
    /* optional */  func scrollView(_ scrollView: DragAndDropPagingScrollView, columnIsDraggableAt index: Int) -> Bool
    /* optional */  func scrollView(_ scrollView: DragAndDropPagingScrollView, columnIsDroppableAt index: Int) -> Bool
    /* optional */  func scrollView(_ scrollView: DragAndDropPagingScrollView, stylingRepresentation view: UIView) -> UIView?
    /* optional */  func scrollView(_ scrollView: DragAndDropPagingScrollView, didLoadedViewColumns views: [UIView])
}

public extension DragAndDropPagingScrollViewDataSource {
    func scrollView(_ scrollView: DragAndDropPagingScrollView, columnIsDraggableAt index: Int) -> Bool {
        return true
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, columnIsDroppableAt index: Int) -> Bool {
        return true
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, stylingRepresentation view: UIView) -> UIView? {
        return view
    }
    
    func scrollView(_ scrollView: DragAndDropPagingScrollView, didLoadedViewColumns views: [UIView]) {}
}

// MARK: - DragAndDropPagingScrollView
open class DragAndDropPagingScrollView: UIScrollView {
    
    // MARK: - Public properties
    open var datasource: DragAndDropPagingScrollViewDataSource? {
        didSet {
            self.reloadData()
        }
    }
    
    public var columnViews: [UIView] = []
    
    public var draggingIndex: Int?
    
    public lazy var pageWidth: CGFloat = { [unowned self] in
        return self.frame.width - 40
    }()
    public lazy var spacingWidth: CGFloat = 8
    
    public var padding: CGFloat = 12
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpScrollView()
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        reloadData()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.prepareSlideViews()
    }
}

// MARK: - Preparations & Tools
public extension DragAndDropPagingScrollView {
    
    func setUpScrollView() {
        self.delegate = self
        self.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
    }
    
    func reloadData() {
        removeAllSubView()
        columnViews = createSlides()
        setupSlideScrollView(slides: columnViews)
        datasource?.scrollView(self, didLoadedViewColumns: columnViews)
    }
    
    func setupSlideScrollView(slides : [UIView]) {
        slides.forEach { slide in
            self.addSubview(slide)
        }
        self.prepareSlideViews()
    }
    
    func prepareSlideViews() {
        let pageHeight = self.frame.height
        
        self.contentSize = CGSize(width: pageWidth * CGFloat(self.columnViews.count) + (spacingWidth * CGFloat(self.columnViews.count - 1)), height: pageHeight)
        
        for i in 0 ..< self.columnViews.count {
            self.columnViews[i].frame = CGRect(x: (pageWidth + spacingWidth) * CGFloat(i), y: 0, width: pageWidth, height: pageHeight)
        }
    }
    
    func createSlides() -> [UIView] {
        var columnViews: [UIView] = []
        if let datasource = self.datasource {
            let numberFoColumns = datasource.numberOfColumns(in: self)
            if numberFoColumns > 0 {
                for index in 0...(numberFoColumns - 1) {
                    columnViews.append(datasource.scrollView(self, viewForColumnAt: index))
                }
            }
        }
        return columnViews
    }
    
    func removeAllSubView() {
        self.subviews.forEach { subView in
            subView.removeFromSuperview()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DragAndDropPagingScrollView: UIScrollViewDelegate {
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        if scrollView == scrollView {
            let maxIndex = self.columnViews.count - 1
            let targetX: CGFloat = scrollView.contentOffset.x + velocity.x * 60.0
            var targetIndex = Int(round(Double(targetX / (pageWidth + spacingWidth))))
            var additionalWidth: CGFloat = 0
            var isOverScrolled = false
            
            if targetIndex <= 0 {
                targetIndex = 0
            } else {
                additionalWidth = padding + spacingWidth
            }
            
            if targetIndex > maxIndex {
                targetIndex = maxIndex
                isOverScrolled = true
            }
            
            let velocityX = velocity.x
            var newOffset = CGPoint(x: (CGFloat(targetIndex) * (self.pageWidth + self.spacingWidth)) - additionalWidth, y: 0)
            if (targetIndex == 0) {
                newOffset.x = -(self.contentInset.left)
            }
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
