//
//  LikeViewCell.swift
//  Whoop
//
//  Created by Li Jiatan on 4/16/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit

class LikeViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    var data = NSDictionary()


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupSubviews(){
        //super.layoutSubviews()
        if(self.data.count <= 0)
        {
            return ;
        }
        
        let content = self.data.stringAttributeForKey("msg")
        let width = self.title.width()
        let height = content.stringHeightWith(17,width:width)
        
        self.title.setHeight(height)
        self.title.text = content
        
        self.content.hidden = true
        //if self.data.stringAttributeForKey("msg") != NSNull() {
        //    self.title.text = self.data.stringAttributeForKey("msg")
        //}
        //self.title.text = "You have a msg!!"
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        let mainWidth = UIScreen.mainScreen().bounds.width
        let content = data.stringAttributeForKey("msg")
        let height = content.stringHeightWith(17,width:mainWidth-80)
        return 60.0 + height
    }
    
}
