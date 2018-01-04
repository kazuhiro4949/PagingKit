//
//  TitleLabelMenuViewCell.swift
//  PagingKit
//
//  Created by kahayash on 2018/01/04.
//  Copyright © 2018年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

public class TitleLabelMenuViewCell: PagingMenuViewCell {
    public var focusColor = UIColor.pk.focusRed
    public var normalColor = UIColor.black
    
    public let titleLabel = { () -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    
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
            anchorLabel(from: titleLabel, to: self, attribute: .leading),
            anchorLabel(from: self, to: titleLabel, attribute: .trailing),
            anchorLabel(from: self, to: titleLabel, attribute: .bottom)
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
    private func anchorLabel(from fromItem: Any, to toItem: Any, attribute: NSLayoutAttribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: fromItem,
            attribute: attribute,
            relatedBy: .equal,
            toItem: toItem,
            attribute: attribute,
            multiplier: 1,
            constant: 8
        )
    }
 }

