//
//  PostTableViewCell.swift
//  Whoops
//
//  Created by Li Jiatan on 2/27/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var PostImage: UIImageView!
    @IBOutlet weak var TimePosted: UILabel!    
    @IBOutlet weak var Replies: UILabel!
    @IBOutlet weak var ContentLable: UILabel!
    var data :NSDictionary!
    var imgWidth :CGFloat!
    var largeImageURL:String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.imageViewTapped(_:)))
        self.PostImage.addGestureRecognizer(tap)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let content = self.data.stringAttributeForKey("content")
        imgWidth = self.PostImage.width()
        let height = content.stringHeightWith(17, width: imgWidth)
        self.ContentLable.setHeight(height)
        self.ContentLable.text = content
   
        //self.ContentLable.numberOfLines = 4
        //self.ContentLable.sizeToFit()
        
        let imgSrc = self.data.stringAttributeForKey("image") as NSString
        if imgSrc.length == 0 {
            self.PostImage.hidden = true
            self.TimePosted.setY(self.ContentLable.bottom()+15)
            self.Replies.setY(self.ContentLable.bottom()+15)
        }
        else
        {
            let imageId = self.data.stringAttributeForKey("id") as NSString
            let prefiximageId = imageId.substringToIndex(5)
            let imagURL = "http://pic.qiushibaike.com/system/pictures/\(prefiximageId)/\(imageId)/small/\(imgSrc)"
            self.PostImage!.hidden = false
            self.PostImage!.setImage(imagURL,placeHolder: UIImage(named: "avatar.jpg"))
            self.largeImageURL = "http://pic.qiushibaike.com/system/pictures/\(prefiximageId)/\(imageId)/medium/\(imgSrc)"
            self.PostImage.setY(self.ContentLable.bottom()+5)
            self.TimePosted.setY(self.PostImage.bottom()+15)
                self.Replies.setY(self.PostImage.bottom()+15)

        }
        
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        let content = data.stringAttributeForKey("content")
        let height = content.stringHeightWith(17,width: 300)
        let imgSrc = data.stringAttributeForKey("image") as NSString
        if imgSrc.length == 0
        {
            return 59.0 + height + 60.0
        }
        return 59.0 + height + 5.0 + 188.0 + 60.0
    }
    
    func imageViewTapped(sender:UITapGestureRecognizer)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("imageViewTapped", object:self.largeImageURL)
        
    }

}
