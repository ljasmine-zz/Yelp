//
//  SwitchCell.swift
//  Yelp
//
//  Created by jasmine_lee on 10/26/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell (_ switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var onSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!

    weak var delegate: SwitchCellDelegate?
     
    override func awakeFromNib() {
        super.awakeFromNib()

        onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func switchValueChanged () {
        if delegate != nil {
            self.delegate?.switchCell?(self, didChangeValue: onSwitch.isOn)
        }

    }
}
