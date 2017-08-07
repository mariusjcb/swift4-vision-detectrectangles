//
//  CGRect.swift
//  CoreML WWDC Day1 15:30
//
//  Created by Marius Ilie on 07/08/2017.
//  Copyright © 2017 Marius Ilie. All rights reserved.
//

import CoreGraphics

extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}
