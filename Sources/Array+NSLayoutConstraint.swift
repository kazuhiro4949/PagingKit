//
//  Array+NSLayoutConstraint.swift
//  PagingKit
//
//  Copyright (c) 2017 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

extension Array where Element == NSLayoutConstraint.Attribute {
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
