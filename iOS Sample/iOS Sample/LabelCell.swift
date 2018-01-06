//
//  LabelCell.swift
//  iOS Sample
//
//  Created by kahayash on 2018/01/06.
//  Copyright © 2018年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class LabelCell: PagingMenuViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override public var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = UIColor.pk.focusRed
            } else {
                titleLabel.textColor = .black
            }
        }
    }
}
