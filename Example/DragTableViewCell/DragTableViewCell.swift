//
//  DragTableViewCell.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/13/18.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class DragTableViewCell: UITableViewCell, NibLoadableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var title: String = "" {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    
    var color: UIColor? {
        didSet {
            self.contentView.backgroundColor = self.color
        }
    }
}
