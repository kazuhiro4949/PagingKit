//
//  UnderlineFocusView.swift
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

/// Basic style of focus view
/// - underline height
/// - underline color
public class UnderlineFocusView: UIView {
    
    /// The color of underline
    public var underlineColor = UIColor.pk.focusRed {
        didSet {
            underlineView.backgroundColor = underlineColor
        }
    }
    
    /// The color of underline
    public var underlineHeight = CGFloat(4) {
        didSet {
            heightConstraint.constant = underlineHeight
        }
    }
    
    public var underlineWidth: CGFloat? = nil {
        didSet {
            if let underlineWidth = underlineWidth {
                widthConstraint.isActive = true
                widthConstraint.constant = underlineWidth
            } else {
                widthConstraint.isActive = false
            }
        }
    }
    
    public var masksToBounds: Bool {
        get { return underlineView.layer.masksToBounds }
        set { underlineView.layer.masksToBounds = newValue }
    }
    
    public var cornerRadius: CGFloat {
        get { return underlineView.layer.cornerRadius }
        set { underlineView.layer.cornerRadius = newValue }
    }
    
    private let widthConstraint: NSLayoutConstraint
    private let heightConstraint: NSLayoutConstraint
    private let underlineView = UIView()
    
    required public init?(coder aDecoder: NSCoder) {
        widthConstraint = NSLayoutConstraint(
            item: underlineView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height, multiplier: 1, constant: 0
        )
        
        heightConstraint = NSLayoutConstraint(
            item: underlineView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height, multiplier: 1, constant: 0
        )
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        widthConstraint = NSLayoutConstraint(
            item: underlineView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height, multiplier: 1, constant: underlineHeight
        )
        
        heightConstraint = NSLayoutConstraint(
            item: underlineView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height, multiplier: 1, constant: underlineHeight
        )
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        addSubview(underlineView)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(heightConstraint)
        addConstraint(widthConstraint)
        widthConstraint.isActive = false
        
        let constraintsA = [.bottom].anchor(from: underlineView, to: self)
        let constraintsB = [.width, .centerX].anchor(from: underlineView, to: self)
        constraintsB.forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        addConstraints(constraintsA + constraintsB)
        underlineView.backgroundColor = underlineColor
    }
}
