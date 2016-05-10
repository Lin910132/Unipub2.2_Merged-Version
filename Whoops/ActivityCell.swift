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
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var labelBackground: UIView!
    @IBOutlet var ChineseName: UILabel!
    @IBOutlet var EnglishName: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func SetUpVeiw() {
        //self.wftLabel.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        self.bringSubviewToFront(labelBackground)
        self.ChineseName.text = data.stringAttributeForKey("name")
        self.EnglishName.text = data.stringAttributeForKey("remark")
        //let backgroundHeight = self.ChineseName.height() + 10
        self.labelBackground.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        //self.labelBackground.frame = CGRectMake(x(), self.height() - backgroundHeight, width, 50)
        self.labelBackground.setHeight(50)
        let imgArray = imgString.componentsSeparatedByString(",") as NSArray

        if (imgArray.count > 0){
            var imgUrl = imgArray[0] as! String
            imgUrl = FileUtility.getUrlImage() + imgUrl;
            activityImg.setImage(imgUrl,placeHolder: UIImage(named: "Logoo.png"));
        }
        //activityImg.image = UIImage(named: "Logoo")
    }
    
}
