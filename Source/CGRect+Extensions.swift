//
//  CGRect+Extensions.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 9/11/18.
//  Copyright © 2018 Karmadust. All rights reserved.
//

import UIKit

public extension CGRect {
    
    public var area: CGFloat {
        return self.size.width * self.size.height
    }
    
    public var volum: CGFloat {
        return 100
    }
}
