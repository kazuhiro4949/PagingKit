//
//  TitleLabelMenuViewCell.swift
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


/// Basic style of cell
/// - center text
/// - emphasize text to focus color
public class TitleLabelMenuViewCell: PagingMenuViewCell {

    ///  The text color when selecred
    public var focusColor = UIColor.pk.focusRed {
        didSet {
            if isSelected {
                titleLabel.textColor = focusColor
            }
        }
    }
    
    /// The normal text color.
    public var normalColor = UIColor.black {
        didSet {
            if !isSelected {
                titleLabel.textColor = normalColor
            }
        }
    }
    
    public var labelWidth: CGFloat {
        return titleLabel.bounds.width
    }
    
    public let titleLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
    public func calcIntermediateLabelSize(with leftCell: TitleLabelMenuViewCell, percent: CGFloat) -> CGFloat {
        let diff = (labelWidth - leftCell.labelWidth) * percent
        return leftCell.labelWidth + diff
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        backgroundColor = .white
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints([
            anchorLabel(from: titleLabel, to: self, attribute: .top),
            anchorLabel(from: titleLabel, to: self, attribute: .leading, .greaterThanOrEqual),
            anchorLabel(from: self, to: titleLabel, attribute: .trailing, .greaterThanOrEqual),
            anchorLabel(from: self, to: titleLabel, attribute: .bottom),
            anchorLabel(from: titleLabel, to: self, 0, attribute: .centerX)
        ])
    }
    
    override public var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = focusColor
            } else {
                titleLabel.textColor = normalColor
            }
        }
    }
    
    
    /// syntax sugar of NSLayoutConstraint for titleLabel (Because this library supports iOS8, it cannnot use NSLayoutAnchor.)
    private func anchorLabel(from fromItem: Any, to toItem: Any, _ constant: CGFloat = 8, attribute: NSLayoutConstraint.Attribute, _ relatedBy: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: fromItem,
            attribute: attribute,
            relatedBy: relatedBy,
            toItem: toItem,
            attribute: attribute,
            multiplier: 1,
            constant: constant
        )
    }
 }

