//
//  ContentTableViewCell.swift
//  iOS Sample
//
//  Created by kahayash on 2017/10/13.
//  Copyright © 2017年 Kazuhiro Hayashi. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(data: (emoji: String, name: String)) {
        emojiLabel.text = data.emoji
        nameLabel.text = data.name
    }
}
