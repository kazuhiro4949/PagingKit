//
//  PagingKitProxy.swift
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

/**
 Use `PagingKitProxy` proxy as customization point for constrained protocol extensions.
 based on: https://github.com/ReactiveX/RxSwift/issues/826
 */
public struct PagingKitProxy<Base: Any> {
    /// Base object to extend.
    let base: Base
    
    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

public extension NSObjectProtocol {
    /// PagingKitProxy extensions for class.
    static var pk: PagingKitProxy<Self.Type> {
        return PagingKitProxy(self)
    }
    
    /// PagingKitProxy extensions for instance.
    var pk: PagingKitProxy<Self> {
        return PagingKitProxy(self)
    }
}

extension PagingKitProxy where Base == UIColor.Type {
    /// color theme to show focusing
    public var focusRed: UIColor {
        return UIColor(
            red: 0.9137254902,
            green: 0.3490196078,
            blue: 0.3137254902,
            alpha: 1
        )
    }
}

extension PagingKitProxy where Base == UIView.Type {
    /// call this function to catch completion handler of layoutIfNeeded()
    ///
    /// - Parameters:
    ///   - layout: method which has layoutIfNeeded()
    ///   - completion: completion handler of layoutIfNeeded()
    func catchLayoutCompletion(layout: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0, animations: {
            layout()
        }) { (finish) in
            completion(finish)
        }
    }
    
    
    /// perform system like animation
    ///
    /// - Parameters:
    ///   - animations: animation Handler
    ///   - completion: completion Handler
    func performSystemAnimation(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.perform(
            .delete,
            on: [],
            options: UIView.AnimationOptions(rawValue: 0),
            animations: animations,
            completion: completion
        )
    }
}
