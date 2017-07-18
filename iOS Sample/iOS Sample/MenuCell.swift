//
//  MenuCell.swift
//  fdaipfdahofdah
//
//  Created by Kazuhiro Hayashi on 7/3/17.
//  Copyright © 2017 Kazuhiro Hayashi. All rights reserved.
//

import UIKit
import PagingKit

class MenuCell: PagingMenuCell {
    static let sizingCell = UINib(nibName: "MenuCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! MenuCell

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
