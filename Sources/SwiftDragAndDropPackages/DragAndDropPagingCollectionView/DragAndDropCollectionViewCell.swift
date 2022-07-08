//
//  DragAndDropCollectionViewCell.swift
//  SwiftDragAndDrop
//
//  Created by Panha Uy on 1/7/22.
//  Copyright © 2022 Phanha Uy. All rights reserved.
//

import UIKit

public class DragAndDropCollectionViewCell: UICollectionViewCell {
    
    var view: UIView?
    var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
}

// MARK: - Preparations & Tools
extension DragAndDropCollectionViewCell {
    
    func setUpLayout() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.stackView = .init(frame: .init())
        self.stackView.axis = .vertical
        
        self.contentView.addSubview(self.stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                           options: [],
                                                           metrics: nil,
                                                           views: ["childView": stackView!]))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                           options: [],
                                                           metrics: nil,
                                                           views: ["childView": stackView!]))
    }
    
    func setContentView(_ view: UIView) {
        self.removeAllSubViews()
        self.view = view
        self.stackView.addArrangedSubview(view)
        self.contentView.layoutIfNeeded()
    }
    
    func removeAllSubViews() {
        self.stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    }
}
