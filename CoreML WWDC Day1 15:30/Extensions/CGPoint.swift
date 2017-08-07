//
//  CGPoint.swift
//  CoreML WWDC Day1 15:30
//
//  Created by Marius Ilie on 07/08/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
