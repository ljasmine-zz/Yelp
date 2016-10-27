//
//  BusinessCell.swift
//  Yelp
//
//  Created by jasmine_lee on 10/25/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!

    var business : Business! {
        didSet {
            nameLabel.text = business.name

            if let url = business.imageURL {
                thumbImageView.setImageWith(url)
            }
            
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
            ratingImageView.setImageWith(business.ratingImageURL! )
            distanceLabel.text = business.distance

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        thumbImageView.layer.cornerRadius = 5
        thumbImageView.clipsToBounds = true
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
