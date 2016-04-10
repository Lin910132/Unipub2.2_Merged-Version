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
    var imgUrl = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func SetUpVeiw() {
        if (imgUrl != ""){
            imgUrl = FileUtility.getUrlImage() + (imgUrl as String);
            activityImg.setImage(imgUrl,placeHolder: UIImage(named: "Logoo.png"));
        }
        //activityImg.image = UIImage(named: "Logoo")
    }
    
}
