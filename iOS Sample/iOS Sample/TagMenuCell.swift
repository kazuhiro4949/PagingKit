//
//  TagMenuCell.swift
//  iOS Sample
//
//  Created by kahayash on 2017/07/15.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class TagMenuCell: PagingMenuViewCell {
    static let sizingCell = UINib(nibName: "TagMenuCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! TagMenuCell
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titieLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    func focus(percent: CGFloat, animated: Bool = false) {
        contentViewTopConstraint.constant = 6 * (1 - percent) + 2
        if animated {
            UIView.perform(
                .delete,
                on: [],
                options: UIViewAnimationOptions(rawValue: 0),
                animations: { [weak self] in
                    self?.setNeedsLayout()
                    self?.layoutIfNeeded()
                },
                completion: { (finish) in }
            )
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 6, height: 6)
        )
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = contentView.bounds
        shapeLayer.path = path.cgPath
        contentView.layer.mask = shapeLayer
    }
}
