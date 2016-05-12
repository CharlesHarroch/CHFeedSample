//
//  CHFeedTableViewCell.swift
//  CHFeedSample
//
//  Created by Charles HARROCH on 03/05/2016.
//  Copyright © 2016 Charles HARROCH. All rights reserved.
//

import UIKit

class CHFeedTableViewCell: UITableViewCell {

    @IBOutlet weak var feedTitle : UILabel!
    @IBOutlet weak var feedImage : UIImageView!
    @IBOutlet weak var container : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        
        container.layer.borderColor = Constants.Color.lightGrayCellBorder.CGColor
        container.layer.borderWidth = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        feedImage?.image = nil
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
