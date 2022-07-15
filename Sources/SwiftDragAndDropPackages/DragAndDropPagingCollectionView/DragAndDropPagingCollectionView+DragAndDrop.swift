//
//  DragAndDropPagingCollectionView+DragAndDrop.swift
//  SwiftDragAndDrop
//
//  Created by Panha Uy on 15/7/22.
//  Copyright © 2022 Panha Uy. All rights reserved.
//

import UIKit

// MARK: - DraggableViewDelegate
extension DragAndDropPagingCollectionView: DragAndDropPagingDelegate {
    
    public func draggingViewRect() -> CGRect? {
        if let index = self.draggingIndex, let rect = self.layoutAttributesForItem(at: .init(row: index, section: 0))?.frame {
            return rect
        }
        return nil
    }

    
    public func dragAndDropView(stylingRepresentationView view: UIView) -> UIView? {
        guard let datasource = self.pagingDatasource else { return view }
        return datasource.collectionView(self, stylingRepresentation: view)
    }
    
    public func dragAndDropView(representationImageAt point: CGPoint) -> UIView? {
        guard let index = self.indexPathForItem(at: point) else { return nil }
        let cellAttributes = self.layoutAttributesForItem(at: index)
        
        if let view = self.columnViews[index.row] {
            let columnView: UIView = (view as? DraggableItemViewDelegate)?.representationImage() ?? view
            
            let frame = cellAttributes?.frame ?? columnView.frame
            let center = cellAttributes?.center ?? columnView.center
            let width = columnView.frame.width
            let height = columnView.frame.height * (width / columnView.frame.width)
            
            UIGraphicsBeginImageContextWithOptions(columnView.bounds.size, false, 0)
            columnView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: height)
            imageView.center = center
            
            return imageView
        }
        
        return nil
    }
    
    public func dragAndDropView(didBeginDraggingAt point: CGPoint) {
        self.draggingIndex = self.indexPathForItem(at: point)?.row
        if let indexToReload = self.draggingIndex {
            if let view = self.columnViews[indexToReload] {
                if let draggableItemDelegate = view as? DraggableItemViewDelegate {
                    draggableItemDelegate.didBeginDragging()
                } else {
                    view.isHidden = true
                }
            }
            
            self.pagingDelegate?.collectionViewDidBeginDragging(self, at: indexToReload)
        }
    }
    
    public func dragAndDropViewDidFinishDragging() {
        if let indexToReload = self.draggingIndex {
            let view = self.columnViews[indexToReload]
            if let draggable = view as? DraggableItemViewDelegate {
                draggable.didFinishedDragging()
            } else {
                view?.isHidden = false
            }
            self.pagingDelegate?.collectionView(self, didDropAt: indexToReload)
        }
        self.pagingDelegate?.collectionViewDidFinishDragging(self)
        self.draggingIndex = nil
    }
    
    public func dragAndDropView(dataItemAt point: CGPoint) -> AnyObject? {
        guard let datasource = self.pagingDatasource else { return nil }
        guard let index = self.indexPathForItem(at: point)?.row else { return nil }
        return datasource.collectionView(self, dataItemAt: index)
    }
    
    public func dragAndDropView(canDragAt point: CGPoint) -> Bool {
        if let datasource = self.pagingDatasource, let indexOfPoint = self.indexPathForItem(at: point)?.row {
            return datasource.collectionView(self, columnIsDraggableAt: indexOfPoint)
        }
        return false
    }
    
    public func dragAndDropView(canDropAt rect: CGRect) -> Bool {
        return self.indexForViewOverlappingRect(rect) != nil
    }
    
    public func dragAndDropView(willMove item: AnyObject, inRect rect: CGRect) {
        if let fromIndex = self.draggingIndex, let toIndex = self.indexForViewOverlappingRect(rect) {
            if fromIndex != toIndex {
                self.pagingDatasource?.collectionView(self, moveDataItem: fromIndex, to: toIndex)
                self.draggingIndex = toIndex
                self.moveItem(at: .init(row: fromIndex, section: 0), to: .init(row: toIndex, section: 0))
            }
        }
    }
    
    public func indexForViewOverlappingRect( _ rect : CGRect) -> Int? {
        
        let columnCount = self.pagingDatasource?.numberOfColumns(in: self) ?? 0
        let lastIndex = columnCount == 0 ? columnCount : columnCount - 1
        
        if columnCount == 0 {
            return lastIndex
        }
        
        if rect.origin.x > self.contentSize.width {
            if self.pagingDatasource?.collectionView(self, columnIsDroppableAt: lastIndex) == true {
                return lastIndex
            }
            return nil
        }
        
        if let index = self.indexPathForItem(at: rect.origin)?.row {
            if self.pagingDatasource?.collectionView(self, columnIsDroppableAt: index) == true {
                return index
            }
            return nil
        }
        
        return nil
    }
}
