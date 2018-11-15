//
//  AutoScroll+Constant.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/14/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

let autoScrollThreshold: CGFloat = 1
let autoScrollMinVelocity: CGFloat = 60
let autoScrollMaxVelocity: CGFloat = 280

func mapValue(_ value: CGFloat, inRangeWithMin minA: CGFloat, max maxA: CGFloat, toRangeWithMin minB: CGFloat, max maxB: CGFloat) -> CGFloat {
    return (value - minA) * (maxB - minB) / (maxA - minA) + minB
}
