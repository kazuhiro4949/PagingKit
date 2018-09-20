//
//  TagMenuCell.swift
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
                options: UIView.AnimationOptions(rawValue: 0),
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
