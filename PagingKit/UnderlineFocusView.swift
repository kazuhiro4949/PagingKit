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

public class UnderlineFocusView: UIView {
    let view = UIView()
    let underlineLayer = CALayer()
    public var underlineColor = UIColor.pk.focusRed
    public var underlineHeight = CGFloat(4)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        underlineLayer.backgroundColor = underlineColor.cgColor
        layer.addSublayer(underlineLayer)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        underlineLayer.backgroundColor = underlineColor.cgColor
        layer.addSublayer(underlineLayer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let underlineFrame = layer.bounds.divided(atDistance: underlineHeight, from: .maxYEdge).slice
        underlineLayer.frame = underlineFrame
    }
}
