//
//  PagingMenuView.swift
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

public struct PagingKitProxy<Base: Any> {
    let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public extension NSObjectProtocol {
    public static var pk: PagingKitProxy<Self.Type> {
        return PagingKitProxy(self)
    }
    
    public var pk: PagingKitProxy<Self> {
        return PagingKitProxy(self)
    }
}

extension PagingKitProxy where Base == UIColor.Type {
    var focusRed: UIColor {
        return UIColor(
            red: 0.9137254902,
            green: 0.3490196078,
            blue: 0.3137254902,
            alpha: 1
        )
    }
}
