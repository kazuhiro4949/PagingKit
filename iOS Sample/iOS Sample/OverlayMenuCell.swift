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
    
    let textMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let highlightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .center
        return label
    }()
    
    @IBOutlet weak var textLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        textLabel.isHidden = true
        addSubview(titleLabel)
        highlightLabel.mask = textMaskView
        addSubview(highlightLabel)
        
        do {
            titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
        
        do {
            highlightLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            highlightLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            highlightLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            highlightLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textMaskView.bounds = bounds.inset(by: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
    }
    
    private func layoutMaskLayer(frame: CGRect) {
        textMaskView.frame = frame.inset(by: UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8))
    }
    
    
    func setFrame(_ view: UIView, frame: CGRect, animated: Bool) {
        textMaskView.isHidden = false
        let convertedFrame = view.convert(frame, to: highlightLabel)
        
        CATransaction.setDisableActions(!animated)
        layoutMaskLayer(frame: convertedFrame)
        CATransaction.setDisableActions(false)
    }
}
