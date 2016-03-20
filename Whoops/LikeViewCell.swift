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
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    @IBOutlet weak var viewMore: UILabel!
    
    
    
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
        
        var imgUrl = self.data.stringAttributeForKey("image")
        if (imgUrl != ""){
            imgUrl = FileUtility.getUrlImage() + (imgUrl as String);
            likeImg.setImage(imgUrl,placeHolder: UIImage(named: "Logoo.png"));
        }else{
            likeImg.hidden = true
        }
        
        let likedString = "Someone liked your post"
        let dislikedString = "Someone disliked your post"
        let repliedString = "Someone replied your post"
        let repliedComment = "Someone replies the post you commented"
        let floorSrting = "@@floor@@"
        let replied = "Someone replied your comment"
        
        var convertedMsg : String
        
        let rawMessage = self.data.stringAttributeForKey("msg")
        convertedMsg = rawMessage
        
        if rawMessage.containsString(likedString){
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(likedString, withString: likedString.localized())
        }else if rawMessage.containsString(dislikedString) {
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(dislikedString, withString: dislikedString.localized())
        }else if rawMessage.containsString(repliedString) {
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(repliedString, withString: repliedString.localized())
        }else if rawMessage.containsString(repliedComment){
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(repliedComment, withString: repliedComment.localized())
        }else if rawMessage.containsString(replied){
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(replied, withString: replied.localized())
        }
        
        let content = convertedMsg
        
        let width = self.title.width()
        let height = content.stringHeightWith(17,width:width)
        
        self.title.setHeight(height)
        self.title.text = content
        
        self.contentLabel.hidden = false
        if self.data.stringAttributeForKey("content") != NSNull() {
            var contentText = self.data.stringAttributeForKey("content")
            if contentText.containsString(floorSrting){
               contentText = contentText.stringByReplacingOccurrencesOfString(floorSrting, withString: "floor".localized())
            }
            contentLabel.text = contentText
        }
        //self.title.text = "You have a msg!!"
        
        viewMore.hidden = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func cellHeightByData(data:NSDictionary, bLast:Bool)->CGFloat
    {
        if (bLast == false){
            let mainWidth = UIScreen.mainScreen().bounds.width
            let content = data.stringAttributeForKey("msg").localized()
            let height = content.stringHeightWith(17,width:mainWidth-80)
            return 60.0 + height
        }
        else {
            return 60.0
        }
    }
    
}
