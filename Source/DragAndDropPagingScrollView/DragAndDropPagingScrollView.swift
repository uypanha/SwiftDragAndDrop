//
//  DragAndDropPagingScrollView.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 4/10/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

protocol DragAndDropPagingScrollViewDataSource {
    
    func scrollView(_ scrollView: UIScrollView, indexOf dataItem: AnyObject) -> IndexPath?
    func scrollView(_ scrollView: UIScrollView, dataItemAt index: Int) -> AnyObject?
    
    func scrollView(_ scrollView: UIScrollView, moveDataItem from: Int, to: Int) -> Void
    
    /* optional */  func scrollView(_ scrollView: UIScrollView, columnIsDraggableAt index: Int) -> Bool
    /* optional */  func scrollView(_ scrollView: UIScrollView, columnIsDroppableAt index: Int) -> Bool
    /* optional */  func scrollView(_ scrollView: UIScrollView, stylingRepresentation view: UIView) -> UIView?
}

extension DragAndDropPagingScrollViewDataSource {
    func scrollView(_ scrollView: UIScrollView, columnIsDraggableAt index: Int) -> Bool {
        return true
    }
    
    func scrollView(_ scrollView: UIScrollView, columnIsDroppableAt index: Int) -> Bool {
        return true
    }
    
    func scrollView(_ scrollView: UIScrollView, stylingRepresentation view: UIView) -> UIView? {
        return view
    }
}

class DragAndDropPagingScrollView: UIScrollView {
    
    
}
