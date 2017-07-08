//
//  OverlayFocusView.swift
//  iOS Sample
//
//  Created by kahayash on 2017/07/08.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class OverlayFocusView: UIView {    
    @IBOutlet weak var contentView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }
}
