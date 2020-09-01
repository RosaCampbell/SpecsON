//
//  csvFilesTableViewCell.swift
//  GraphTutorial
//
//  Created by Rosa Campbell on 27/08/20.
//  Copyright © 2020 Campbell. All rights reserved.
//

import UIKit

class csvFilesTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet var deviceLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!

    var device: String? {
        didSet {
            deviceLabel.text = device
        }
    }

    var dateTime: String? {
        didSet {
            dateTimeLabel.text = dateTime
        }
    }

}
