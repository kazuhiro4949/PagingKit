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
    
    let maskInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    
    let textMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    @IBOutlet var highlightLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!    

    override func awakeFromNib() {
        super.awakeFromNib()
        highlightLabel.mask = textMaskView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textMaskView.bounds = bounds.inset(by: maskInsets)
    }
    
    func setFrame(_ menuView: PagingMenuView, maskFrame: CGRect, animated: Bool) {
        textMaskView.frame = menuView.convert(maskFrame, to: highlightLabel).inset(by: maskInsets)
    }
}
