//
//  ActivityCell.swift
//  UniPub
//
//  Created by Li Jiatan on 3/29/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    
    @IBOutlet var activityImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func SetUpVeiw() {
        activityImg.image = UIImage(named: "Logoo")
    }
    
}
