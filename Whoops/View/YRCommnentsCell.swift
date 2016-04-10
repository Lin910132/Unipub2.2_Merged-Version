//
//  YRCommnentsCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-7.
//  Copyright (c) 2014y YANGReal. All rights reserved.
//

import UIKit

class YRCommnentsCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet var floorLabel: UILabel!
 
    
    var likeClick:Bool = true
    var likeHot = Int()
    var data :NSDictionary!
    var index = NSIndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        floorLabel.text = String(index.row + 1) + " " + "floor".localized()
        
        let rawMessage = self.data.stringAttributeForKey("content")
        let floorStr = "@@floor@@"
        var convertedMsg : String = rawMessage
        
        if (rawMessage.containsString(floorStr)){
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(floorStr, withString: "floor".localized())
        }
        
        let content = convertedMsg
        
        let width = self.contentLabel.width()
        let height = content.stringHeightWith(17,width:width)
        
        //Set position of lable. The width is set in YrCommentsCell.xib
        self.contentLabel.numberOfLines = 0
        self.contentLabel.setHeight(height)
        self.contentLabel.text = content
        
        self.createdDate.text = self.data.stringAttributeForKey("createDateLabel") as String
        
        if self.data.stringAttributeForKey("likeNum") == NSNull(){
            self.likeHot = 0
        } else {
            self.likeHot = Int(self.data.stringAttributeForKey("likeNum"))!
        }
        
        
        
       
        
    }

    /*
    @IBAction func likeImageClick(){
        /*let myalert = UIAlertView()
        myalert.title = "准备好了吗"
        myalert.message = "准备好开始了吗？"
        myalert.addButtonWithTitle("Ready, go!")
        myalert.show()*/
        let id = self.data.stringAttributeForKey("id")
        var like = self.data.stringAttributeForKey("likeNum")

            let url = FileUtility.getUrlDomain() + "comment/like?id=\(id)&uid=\(FileUtility.getUserId())"
            YRHttpRequest.requestWithURL(url,completionHandler:{ data in
                
                if data as! NSObject == NSNull()
                {
                    UIView.showAlertView("提示",message:"加载失败")
                    return
                }
                var result:Int = data["result"] as! Int
                
                
            })
            
        
    }
    
    @IBAction func unlikeImageClick(){
        
        let id = self.data.stringAttributeForKey("id")
        var dislike = self.data.stringAttributeForKey("dislikeNum")
            let url = FileUtility.getUrlDomain() + "comment/unlike?id=\(id)&uid=\(FileUtility.getUserId())"
            YRHttpRequest.requestWithURL(url,completionHandler:{ data in
                
                if data as! NSObject == NSNull()
                {
                    UIView.showAlertView("提示",message:"加载失败")
                    return
                }
                var result:Int = data["result"] as! Int
                                
            })
            

    }*/

    
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        let rawMessage = data.stringAttributeForKey("content")
        let floorStr = "@@floor@@"
        var convertedMsg : String = rawMessage
        
        if (rawMessage.containsString(floorStr)){
            convertedMsg = rawMessage.stringByReplacingOccurrencesOfString(floorStr, withString: "floor".localized())
        }
        
        let content = convertedMsg
        
        let mainWidth = UIScreen.mainScreen().bounds.width
        //let content = data.stringAttributeForKey("content")
        let height = content.stringHeightWith(17,width:mainWidth-80)
        return 45.0 + height + 24.0
    }

    
}
