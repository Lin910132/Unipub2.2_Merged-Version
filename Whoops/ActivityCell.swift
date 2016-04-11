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
    var imgString = ""
    var data = NSDictionary()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func SetUpVeiw() {
        
        let imgArray = imgString.componentsSeparatedByString(",") as NSArray

        if (imgArray.count > 0){
            var imgUrl = imgArray[0] as! String
            imgUrl = FileUtility.getUrlImage() + imgUrl;
            activityImg.setImage(imgUrl,placeHolder: UIImage(named: "Logoo.png"));
        }
        //activityImg.image = UIImage(named: "Logoo")
    }
    
}
