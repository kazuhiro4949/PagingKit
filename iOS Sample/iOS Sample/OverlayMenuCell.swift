//
//  OverlayMenuCell.swift
//  iOS Sample
//
//  Created by kahayash on 2017/07/08.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class OverlayMenuCell: UICollectionViewCell {
    static let sizingCell = UINib(nibName: "OverlayMenuCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! OverlayMenuCell

    @IBOutlet weak var textLabel: UILabel!
    
    var isHighlight: Bool = false {
        didSet {
            if isHighlight {
                black(percent: 0)
            } else {
                black(percent: 1)
            }
        }
    }
    
    func black(percent: CGFloat) {
        let whiteRatio = 1 - percent
        textLabel.textColor = UIColor(white: whiteRatio, alpha: 1)
    }
    
    func highlightWithAnimation(isHighlight: Bool) {
        UIView.transition(with: textLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.textLabel.textColor = isHighlight ? .black : .white
        }, completion: { (_) in
        
        })
    }
}
