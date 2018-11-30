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
import PagingKit

class OverlayMenuCell: PagingMenuViewCell {
    static let sizingCell = UINib(nibName: "OverlayMenuCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! OverlayMenuCell
    let maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    
    let highlightTextLayer: CATextLayer = {
        let layer = CATextLayer()
        let font = UIFont.systemFont(ofSize: 16)
        layer.font = font
        layer.fontSize = font.pointSize
        layer.foregroundColor = UIColor.white.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.alignmentMode = .center
        return layer
    }()
    
    let baseTextLayer: CATextLayer = {
        let layer = CATextLayer()
        let font = UIFont.systemFont(ofSize: 16)
        layer.font = font
        layer.fontSize = font.pointSize
        layer.foregroundColor = UIColor.black.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.alignmentMode = .center
        return layer
    }()
    
    @IBOutlet weak var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel.isHidden = true
        maskLayer.isHidden = true
        layer.addSublayer(baseTextLayer)
        highlightTextLayer.mask = maskLayer
        layer.addSublayer(highlightTextLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let string = highlightTextLayer.string as? NSString, let font = highlightTextLayer.font as? UIFont {
            let stringBounds = string.boundingRect(with: CGSize(width: .max, height: .min), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
            highlightTextLayer.frame = stringBounds
            highlightTextLayer.frame.origin.y = (bounds.height - stringBounds.height) / 2
            highlightTextLayer.frame.origin.x = (bounds.width - stringBounds.width) / 2
        }
        if let string = baseTextLayer.string as? NSString, let font = baseTextLayer.font as? UIFont {
            let stringBounds = string.boundingRect(with: CGSize(width: .max, height: .min), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
            baseTextLayer.frame = stringBounds
            baseTextLayer.frame.origin.y = (bounds.height - stringBounds.height) / 2
            baseTextLayer.frame.origin.x = (bounds.width - stringBounds.width) / 2
        }
        
        maskLayer.bounds = bounds.inset(by: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
        maskLayer.path = UIBezierPath(roundedRect: maskLayer.bounds, cornerRadius: bounds.height / 2).cgPath
        
    }
    
    private func layoutMaskLayer(frame: CGRect) {
        maskLayer.frame = frame.inset(by: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
        maskLayer.path = UIBezierPath(roundedRect: maskLayer.bounds, cornerRadius: bounds.height / 2).cgPath
    }
    
    func setFrame(_ view: UIView, animated: Bool) {
        maskLayer.isHidden = false
        let convertedFrame = view.layer.convert(view.bounds, to: highlightTextLayer)
        
        CATransaction.setDisableActions(!animated)
        layoutMaskLayer(frame: convertedFrame)
        CATransaction.setDisableActions(false)
    }
}
