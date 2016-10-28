//
//  RadioCell.swift
//  Yelp
//
//  Created by jasmine_lee on 10/27/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class RadioCell: UITableViewCell {

    @IBOutlet weak var radioLabel: UILabel!
    @IBOutlet weak var radioImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
