//
//  OverlayMenuCell.swift
//  iOS Sample
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

public class OverlayMenuCell: PagingMenuViewCell {
    
    public weak var referencedMenuView: PagingMenuView?
    public weak var referencedFocusView: PagingMenuFocusView?
    
    public var hightlightTextColor: UIColor? {
        set {
            highlightLabel.textColor = newValue
        }
        get {
            return highlightLabel.textColor
        }
    }
    
    public var normalTextColor: UIColor? {
        set {
            titleLabel.textColor = newValue
        }
        get {
            return titleLabel.textColor
        }
    }
    
    public static let sizingCell = OverlayMenuCell()
    
    let maskInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    
    let textMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let highlightLabel = UILabel()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addConstraints()
        highlightLabel.mask = textMaskView
        highlightLabel.textColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addConstraints()
        highlightLabel.mask = textMaskView
        highlightLabel.textColor = .white
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        textMaskView.bounds = bounds.inset(by: maskInsets)
    }
    
    public func configure(title: String) {
        titleLabel.text = title
        highlightLabel.text = title
    }
    
    public func updateMask(animated: Bool = true) {
        guard let menuView = referencedMenuView, let focusView = referencedFocusView else {
            return
        }
        
        setFrame(menuView, maskFrame: focusView.frame, animated: animated)
    }
    
    func setFrame(_ menuView: PagingMenuView, maskFrame: CGRect, animated: Bool) {
        textMaskView.frame = menuView.convert(maskFrame, to: highlightLabel).inset(by: maskInsets)
        
        if let expectedOriginX = menuView.getExpectedAlignmentPositionXIfNeeded() {
            textMaskView.frame.origin.x += expectedOriginX
        }
    }
    
    public func calculateWidth(from height: CGFloat, title: String) -> CGFloat {
        configure(title: title)
        var referenceSize = UIView.layoutFittingCompressedSize
        referenceSize.height = height
        let size = systemLayoutSizeFitting(referenceSize, withHorizontalFittingPriority: UILayoutPriority.defaultLow, verticalFittingPriority: UILayoutPriority.defaultHigh)
        return size.width
    }
}

extension OverlayMenuCell {
    private func addConstraints() {
        addSubview(titleLabel)
        addSubview(highlightLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        highlightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [titleLabel, highlightLabel].forEach {
            let trailingConstraint = NSLayoutConstraint(
                item: self,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: $0,
                attribute: .trailing,
                multiplier: 1,
                constant: 16)
            let leadingConstraint = NSLayoutConstraint(
                item: $0,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 16)
            let bottomConstraint = NSLayoutConstraint(
                item: self,
                attribute: .top,
                relatedBy: .equal,
                toItem: $0,
                attribute: .top,
                multiplier: 1,
                constant: 8)
            let topConstraint = NSLayoutConstraint(
                item: $0,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: 8)
            
            addConstraints([topConstraint, bottomConstraint, trailingConstraint, leadingConstraint])
        }
    }
}
