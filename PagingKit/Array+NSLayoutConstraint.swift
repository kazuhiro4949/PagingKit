//
//  Array+NSLayoutConstraint.swift
//  PagingKit
//
//  Created by kahayash on 2017/10/31.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import Foundation

extension Array where Element == NSLayoutAttribute {
    /// anchor same attributes between fromView and toView
    /// convert to "view1.attr1 = view2.attr2 * multiplier + constant"
    /// - Parameters:
    ///   - from: view1
    ///   - to: view2
    /// - Returns: NSLayoutAttributes
    func anchor(from fromView: UIView, to toView: UIView) -> [NSLayoutConstraint] {
        return map {
            NSLayoutConstraint(
                item: fromView,
                attribute: $0,
                relatedBy: .equal,
                toItem: toView,
                attribute: $0,
                multiplier: 1,
                constant: 0
            )
        }
    }
}
