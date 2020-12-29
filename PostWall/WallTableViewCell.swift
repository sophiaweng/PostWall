//
//  WallTableViewCell.swift
//  PostWall
//
//  Created by 翁淑惠 on 2020/12/23.
//

import UIKit

class WallTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var imgImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
