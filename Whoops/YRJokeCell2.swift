//
//  YRJokeCell2.swift
//  Whoop
//
//  Created by djx on 15/5/22.
//  Copyright (c) 2015年 Li Jiatan. All rights reserved.
//

import UIKit

var textYpostion:CGFloat = 0;
var isTop:Bool=false;
var bottomHeight:CGFloat = 30; //最小值为16

protocol YRJokeCellDelegate
{
    
    func sendEmail(strTo:String, strSubject:String, strBody:String);
}

protocol YRRefreshMainDelegate
{
    
    func refreshMain();
    func FaveBtnClicked(cell:YRJokeCell2)
}

protocol YRRefreshCommentDelegate
{
    
    func refreshCommentByFavor();
}

protocol YRRefreshUniversityDelegate
{
    
    func refreshUniversityByFavor();
}

protocol YRRefreshMyRepliesDelegate
{
    
    func refreshMyRepliesByFavor();
}




class YRJokeCell2: UITableViewCell
{
        
    
    var delegate:YRJokeCellDelegate?
    var refreshMainDelegate:YRRefreshMainDelegate?
    var refreshCommentDelegate:YRRefreshCommentDelegate?
    var refreshUniversityDelete:YRRefreshUniversityDelegate?
    var refreshMyRepliesDelegate:YRRefreshMyRepliesDelegate?
    var data = NSDictionary()
    var postId:String = ""
    var likeNum:UILabel!
    var likeButton:UIButton!
    var unlikeButton:UIButton!
    var favButton:UIButton!
    var isFaveFlag:Bool=false
    var imageDataArray = NSMutableArray()
    
    var imgList = [UIImageView]()
    
    
    let baseTagValue = 1000
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setCellUp()
    {
        for view : AnyObject in self.subviews
        {
            view.removeFromSuperview();
        }
        self.imgList.removeAll(keepCapacity: false)
        
        if(self.data.count <= 0)
        {
            return ;
        }
        
        
        
//        var rec = UIScreen.mainScreen().bounds.width;
        
        self.backgroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0);
        //背景图片
        let ivBack = UIImageView(frame:CGRectMake(0, 7, UIScreen.mainScreen().bounds.width, 187));
        ivBack.backgroundColor = UIColor.whiteColor();
        ivBack.layer.shadowOffset = CGSizeMake(10, 10);
        ivBack.layer.shadowColor = UIColor(red:237.0/255.0 , green:237.0/255.0, blue:237.0/255.0 , alpha: 1.0).CGColor;
        ivBack.userInteractionEnabled = true;
        self.addSubview(ivBack);
        
        //收藏按钮
        let fav = UIButton(frame:CGRectMake(3, 3, 24, 24));
        //fav.backgroundColor = UIColor.redColor();
        let isFavor = data.stringAttributeForKey("isFavor") as String;
        if isFavor == "favor" {
            isFaveFlag = true
            fav.setImage(UIImage(named:"starB1"), forState: UIControlState.Normal);
        }else{
            isFaveFlag = false
            fav.setImage(UIImage(named:"star"), forState: UIControlState.Normal);
        }
        fav.addTarget(self, action: "btnFavClick:", forControlEvents: UIControlEvents.TouchUpInside);
        self.favButton = fav;
        ivBack.addSubview(self.favButton);
        
        //设置图片
        let imageStr = data.stringAttributeForKey("image") as NSString;
        let imgArray = imageStr.componentsSeparatedByString(",") as NSArray;
        let height:CGFloat = 160; //图片区域的高度
        let offset:CGFloat = 5; //图片偏移区
        let xPositon:CGFloat = 5;
        let yPosition:CGFloat = 30;
        var width:CGFloat;
        width = (CGFloat)(ivBack.frame.size.width - 55); //图片区域的宽度
        
        
        
        
        if(imgArray.count > 0 && imageStr.length > 0)
        {
            isTop = false;
            if (imgArray.count == 1)
            {
                //只有一张图片,高度应该小于宽度，以高度为准，靠左显示
                //var imgView = UIImageView(frame:CGRectMake((width - height)/2, yPosition, height, height));
                let imgView = UIImageView(frame: CGRectMake(xPositon, yPosition, height, height))
                let maskLayer = CAShapeLayer()
                let path = CGPathCreateWithRect(imgView.bounds, nil)
                maskLayer.path = path
                imgView.layer.mask = maskLayer
                
                imgView.contentMode = UIViewContentMode.ScaleAspectFill;
                imgView.userInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
                imgView.addGestureRecognizer(tap)
                
                self.imgList.append(imgView)
                
                imgView.tag = baseTagValue
                
                ivBack.addSubview(imgView);
                let imgUrl = imgArray.objectAtIndex(0) as! NSString;
                if(imgUrl.length <= 0)
                {
                    imgView.image = UIImage(named: "Logoo.png");
                }
                else
                {
                    let imagURL = FileUtility.getUrlImage() + (imgUrl as String);
                    imgView.setImage(imagURL,placeHolder: UIImage(named: "Logoo.png"));
                }
                
                textYpostion = height + yPosition;
                
            }
            else if(imgArray.count == 2)
            {
                //2张图片
                var widthTmp:CGFloat;
                widthTmp = (CGFloat)(width - offset)/2;
                var imgWidth:CGFloat;
                imgWidth = height>widthTmp ? widthTmp:height;
                var index = 0
                for imgUrl in imgArray
                {
                    var x:CGFloat;
                    x = xPositon + CGFloat(index * Int(imgWidth + offset));
                    let imgView = UIImageView(frame:CGRectMake(x, yPosition, imgWidth, imgWidth));
                    
                    let maskLayer = CAShapeLayer()
                    let path = CGPathCreateWithRect(imgView.bounds, nil)
                    maskLayer.path = path
                    imgView.layer.mask = maskLayer
                    
                    imgView.contentMode = UIViewContentMode.ScaleAspectFill;
                    self.imgList.append(imgView)
                    imgView.userInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
                    imgView.addGestureRecognizer(tap)
                    let imagURL = FileUtility.getUrlImage() + (imgUrl as! String)
                    imgView.tag = index;
                    imgView.setImage(imagURL,placeHolder: UIImage(named: "Logoo.png"))
                    imgView.tag = baseTagValue + index
                    index++;
                    ivBack.addSubview(imgView);
                    
                }
                
                textYpostion = imgWidth + yPosition;
            }
            else if(imgArray.count == 4){
                var widthTmp:CGFloat;
                widthTmp = (CGFloat)(width - offset)/2;
                var imgWidth:CGFloat;
                imgWidth = height>widthTmp ? widthTmp:height;
                var index = 0
                for imgUrl in imgArray
                {
                    var x:CGFloat;
                    x = xPositon + CGFloat(index%2 * Int(imgWidth + offset));
                    var y:CGFloat;
                    y = yPosition + CGFloat(index/2 * Int(widthTmp + offset));
                    
                    let imgView = UIImageView(frame:CGRectMake(x, y, imgWidth, imgWidth));
                    let maskLayer = CAShapeLayer()
                    let path = CGPathCreateWithRect(imgView.bounds, nil)
                    maskLayer.path = path
                    imgView.layer.mask = maskLayer
                    
                    imgView.contentMode = UIViewContentMode.ScaleAspectFill;
                    self.imgList.append(imgView)
                    imgView.userInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
                    imgView.addGestureRecognizer(tap)
                    let imagURL = FileUtility.getUrlImage() + (imgUrl as! String)
                    imgView.tag = index;
                    imgView.setImage(imagURL,placeHolder: UIImage(named: "Logoo.png"))
                    
                    imgView.tag = baseTagValue + index
                    index++;
                    ivBack.addSubview(imgView);
                }
                
                textYpostion = yPosition + CGFloat(2 * Int(imgWidth + offset));
            }
            else if(imgArray.count >= 3)
            {
                //3张图片及以上
                var widthTmp:CGFloat;
                widthTmp = (CGFloat)(width - 2*offset)/3;
                var index = 0
                for imgUrl in imgArray
                {
                    var x:CGFloat;
                    x = xPositon + CGFloat(index%3 * Int(widthTmp + offset));
                    var y:CGFloat;
                    y = yPosition + CGFloat(index/3 * Int(widthTmp + offset));
                    let imgView = UIImageView(frame:CGRectMake(x , y, widthTmp, widthTmp));
                    
                    let maskLayer = CAShapeLayer()
                    let path = CGPathCreateWithRect(imgView.bounds, nil)
                    maskLayer.path = path
                    imgView.layer.mask = maskLayer
                    
                    imgView.contentMode = UIViewContentMode.ScaleAspectFill;
                    self.imgList.append(imgView)
                    imgView.userInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
                    imgView.addGestureRecognizer(tap)
                    let imagURL = FileUtility.getUrlImage() + (imgUrl as! String)
                    imgView.tag = index;
                    imgView.setImage(imagURL,placeHolder: UIImage(named: "Logoo.png"))
                    imgView.tag = baseTagValue + index
                    index++;
                    ivBack.addSubview(imgView);
                }
                
                if(index > 3)
                {
                    textYpostion = yPosition + CGFloat(2 * Int(widthTmp + offset));
                }
                else
                {
                    textYpostion = yPosition + CGFloat(Int(widthTmp + offset));
                }
                
            }
        }
        else
        {
            isTop = true;
            textYpostion = 138;
        }
        
        var lbPostion:CGFloat;
        if(isTop)
        {
            lbPostion = yPosition;
            //textYpostion = yPosition;
        }
        else
        {
            lbPostion = textYpostion;
        }
        
        let lableContent = UILabel(frame: CGRectMake(12, lbPostion, ivBack.frame.size.width-6, 1000));
        lableContent.numberOfLines = 0;
        lableContent.textColor = UIColor(red:60.0/255.0 , green:60.0/255.0 , blue: 60.0/255.0, alpha: 1.0);
        lableContent.font = UIFont.systemFontOfSize(17);
        let text = data.stringAttributeForKey("content");
        
        lableContent.text = text as String;
        let size = text.stringHeightWith(17,width:lableContent.frame.size.width) + 20;
        var rect = lableContent.frame as CGRect;
        
        rect.size.height = size+20;
        
        rect.size.width = ivBack.frame.size.width-50
        lableContent.frame = rect;
        ivBack.addSubview(lableContent);
        
        //设置底部数据
        var bottomY = textYpostion + size + 25;
        //var bottomY = textYpostion+size + 5;
        
        if(isTop)
        {
            if(size + 20 + lbPostion > 153)
            {
                bottomY = size + lbPostion + 30;
            }
            else
            {
                bottomY = 153;
            }
            
        }
        
        var rectBack = ivBack.frame as CGRect;
        rectBack.size.height = bottomY + bottomHeight;
        ivBack.frame = rectBack;
        
        //喜欢按钮
        let like = UIButton(frame:CGRectMake(ivBack.frame.size.width-42, ((textYpostion - yPosition)/3 - 34)/2 + yPosition, 34, 34));
        let isLike = data.stringAttributeForKey("isLike") as String;
        if isLike == "1" {
            like.setImage(UIImage(named:"Likefill"), forState: UIControlState.Normal);
        }else{
            like.setImage(UIImage(named:"LikeNew"), forState: UIControlState.Normal);
        }
        like.addTarget(self, action: "btnLikeClick:", forControlEvents: UIControlEvents.TouchUpInside);
        self.likeButton = like
        ivBack.addSubview(self.likeButton);
        
        //喜欢数量
        likeNum = UILabel(frame: CGRectMake(ivBack.frame.size.width-58, (textYpostion - yPosition)/3 + ((textYpostion - yPosition)/3 - 34)/2 + yPosition, 67, 34));
        likeNum.textAlignment = NSTextAlignment.Center;
        likeNum.textColor = UIColor(red:121.0/255.0 , green:122.0/255.0 , blue:124.0/255.0 , alpha: 1.0);
        if (data.stringAttributeForKey("likeNum") == NSNull())
        {
            likeNum.text = "0";
        }
        else
        {
            likeNum.text = data.stringAttributeForKey("likeNum");
        }
        ivBack.addSubview(likeNum);
        
        //不喜欢
        let unlike = UIButton(frame:CGRectMake(ivBack.frame.size.width-42, 2*(textYpostion - yPosition)/3+((textYpostion - yPosition)/3 - 34)/2 + yPosition, 34, 34));
        
        if isLike == "-1" {
            unlike.setImage(UIImage(named:"unlikefill"), forState: UIControlState.Normal);
        }else{
            unlike.setImage(UIImage(named:"unlikeNew"), forState: UIControlState.Normal);
        }
        
        unlike.addTarget(self, action: "btnUnLikeClick:", forControlEvents: UIControlEvents.TouchUpInside);
        self.unlikeButton = unlike
        ivBack.addSubview(self.unlikeButton);
        
        
        
        
        let viewBottom = UIView(frame: CGRectMake(0, bottomY, ivBack.frame.size.width, bottomHeight));
        viewBottom.backgroundColor = UIColor(red:244.0/255.0 , green:244.0/255.0 , blue:244.0/255.0 , alpha: 1.0);
        ivBack.addSubview(viewBottom);
        
        let imgTime = UIImageView(frame: CGRectMake(5, (bottomHeight - 16)/2, 16, 16));
        imgTime.image = UIImage(named: "time");
        viewBottom.addSubview(imgTime);
        
        let createDateLabel = UILabel(frame: CGRectMake(25, (bottomHeight - 16)/2, 50, 16));
        createDateLabel.textColor = UIColor(red:149.0/255.0 , green:149.0/255.0 , blue:149.0/255.0 , alpha: 1.0);
        createDateLabel.font = UIFont.systemFontOfSize(13);
        createDateLabel.text = data.stringAttributeForKey("createDateLabel") as String;
        viewBottom.addSubview(createDateLabel);
        
        let imgNick = UIImageView(frame: CGRectMake(75, (bottomHeight - 16)/2, 16, 16));
        imgNick.image = UIImage(named: "ballonHighlight");
        imgNick.userInteractionEnabled = true;
        viewBottom.addSubview(imgNick);
        
        let nickName = UILabel(frame: CGRectMake(97, (bottomHeight - 16)/2, ivBack.frame.width - 180, 16));
        nickName.textColor = UIColor(red:149.0/255.0 , green:149.0/255.0 , blue:149.0/255.0 , alpha: 1.0);
        nickName.font = UIFont.systemFontOfSize(13);
        nickName.text = data.stringAttributeForKey("nickName") as String;
        //if (nickName.text == ""){
        //    nickName.text = "Unknown";
        //}
        viewBottom.addSubview(nickName);
        
        let btnNick = UIButton(frame: CGRectMake(75, (bottomHeight - 16)/2, ivBack.frame.width - 164, 16));
        btnNick.backgroundColor = UIColor.clearColor();
        btnNick.addTarget(self, action: "btnNickClick:", forControlEvents: UIControlEvents.TouchUpInside);
        viewBottom.addSubview(btnNick);
        
        let commentCount = UILabel(frame: CGRectMake(ivBack.frame.width - 80, (bottomHeight - 16)/2, 70, 16));
        commentCount.textColor = UIColor(red:149.0/255.0 , green:149.0/255.0 , blue:149.0/255.0 , alpha: 1.0);
        commentCount.font = UIFont.systemFontOfSize(13);
        commentCount.textAlignment = NSTextAlignment.Center;
        
        var strcommentCount = data.stringAttributeForKey("commentCount") as String
        if strcommentCount == "" || strcommentCount == "0" {
            strcommentCount = "0"+" "+"Reply".localized()
        }else if strcommentCount == "1" {
            strcommentCount = "1"+" "+"Reply".localized()
        }else {
            strcommentCount = "\(strcommentCount)"+" "+"Replies".localized()
        }
        commentCount.text = "\(strcommentCount) ";
        viewBottom.addSubview(commentCount);
        
        postId = self.data.stringAttributeForKey("id") as String    }
    
    func btnNickClick(sender:UIButton)
    {
        let nick = self.data.stringAttributeForKey("nickName") as NSString;
        if(YRJokeCell2.judgeNum(nick))
        {
            let telStr = NSString(format:"tel:%@",nick);
            let url = NSURL(string: telStr as String);
            UIApplication.sharedApplication().openURL(url!);
        }
        else if(YRJokeCell2.judgeEmail(nick))
        {
            if(delegate != nil)
            {
                let content = self.data.stringAttributeForKey("content")
                var subject:String = content
                if content.characters.count > 20 {
                    subject = content.substringToIndex(20)
                    subject = subject + "..."
                }
                subject = "I'm interest in your post in Whoop, that ".localized() + subject
                
                let body:String = "Hi, I'm interest in your post in Whoop, that".localized()+"\"" + content + "\""
                
                delegate?.sendEmail(nick as String,
                    strSubject: subject,
                    strBody:  body)
                
            }
        }
    }
    
    
    
    func btnFavClick(sender:UIButton)
    {
        let url = FileUtility.getUrlDomain() + "favorPost/add?postId=\(postId)&uid=\(FileUtility.getUserId())"
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("WARNING".localized(),message: "Loading Failed".localized())
                return
            }
            
            //let post = data["data"] as! NSDictionary
            //let isFavor = post["isFavor"] as! String;
            
            
            self.refreshMainDelegate?.refreshMain()
            //self.refreshMainDelegate?.FaveBtnClicked(sender.superview?.superview as! YRJokeCell2)
            //self.refreshCommentDelegate?.refreshCommentByFavor()
            //self.refreshUniversityDelete?.refreshUniversityByFavor()
            //self.refreshMyRepliesDelegate?.refreshMyRepliesByFavor()
            
            
        })
        //let isFavor = self.data.stringAttributeForKey("isFavor") as String
        if isFaveFlag == true {
            self.favButton.setImage(UIImage(named:"star"), forState: UIControlState.Normal);
            isFaveFlag = false
        }else{
            self.favButton.setImage(UIImage(named:"starB1"), forState: UIControlState.Normal);
            isFaveFlag = true
        }
        
        
    }
    
    func btnLikeClick(sender:UIButton)
    {
        let url = FileUtility.getUrlDomain() + "post/like?id=\(postId)&uid=\(FileUtility.getUserId())"
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("WARNING",message: "Loading Failed".localized())
                return
            }
            let result:Int = data["result"] as! Int
            self.likeNum!.text = "\(result)"
            let post = data["data"] as! NSDictionary
            let isLike = post["isLike"] as! String;
            if isLike == "1" {
                self.likeButton.setImage(UIImage(named:"Likefill"), forState: UIControlState.Normal);
                self.unlikeButton.setImage(UIImage(named:"unlikeNew"), forState: UIControlState.Normal);
            }else{
                self.likeButton.setImage(UIImage(named:"LikeNew"), forState: UIControlState.Normal);
            }

            
        })
    }
    
    func btnUnLikeClick(sender:UIButton)
    {
        let url = FileUtility.getUrlDomain() + "post/unlike?id=\(postId)&uid=\(FileUtility.getUserId())"
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            let result:Int = data["result"] as! Int
            self.likeNum!.text = "\(result)"
            
            let post = data["data"] as! NSDictionary
            let isLike = post["isLike"] as! String;

            if isLike == "-1" {
                self.unlikeButton.setImage(UIImage(named:"unlikefill"), forState: UIControlState.Normal);
                self.likeButton.setImage(UIImage(named:"LikeNew"), forState: UIControlState.Normal);
            }else{
                self.unlikeButton.setImage(UIImage(named:"unlikeNew"), forState: UIControlState.Normal);
            }

            
        })
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat
    {
        
        //lableContent比背景宽度少6，现在的背景宽度是mainWidth
        let mainWidth = UIScreen.mainScreen().bounds.width
        let lableContent = UILabel(frame: CGRectMake(3, 193, mainWidth-6, 1000));
    
        lableContent.numberOfLines = 0;
        lableContent.font = UIFont.systemFontOfSize(17);
        let text = data.stringAttributeForKey("content");
        let size = text.stringHeightWith(17,width:mainWidth - 6);
        //size = size + 20.0;
        //设置图片
        let imageStr = data.stringAttributeForKey("image") as NSString;
        let imgArray = imageStr.componentsSeparatedByString(",") as NSArray;
        let height:CGFloat = 160; //图片区域的高度
        let offset:CGFloat = 5; //图片偏移区
//        var xPositon:CGFloat = 5;
        let yPosition:CGFloat = 20;
        var width:CGFloat;
        width = (CGFloat)(UIScreen.mainScreen().bounds.width - 55); //图片区域的宽度
        
        
        
        var textTmpYpostion:CGFloat = 0;
        if(imgArray.count > 0 && imageStr.length > 0)
        {
            isTop = false;
            if (imgArray.count == 1)
            {
                //只有一张图片,高度应该小于宽度，以高度为准，居中显示
                
                textTmpYpostion = height + yPosition;
                
            }
            else if(imgArray.count == 2)
            {
                //2张图片
                var widthTmp:CGFloat;
                widthTmp = (CGFloat)(width - offset)/2;
                var imgWidth:CGFloat;
                imgWidth = height>widthTmp ? widthTmp:height;
                
                textTmpYpostion = imgWidth + yPosition;
            }
            else if(imgArray.count == 4){
                var widthTmp:CGFloat;
                widthTmp = (CGFloat)(width - offset)/2;
                var imgWidth:CGFloat;
                imgWidth = height>widthTmp ? widthTmp:height;
                
                textTmpYpostion = yPosition + CGFloat(2 * Int(imgWidth + offset));
            }
            else if(imgArray.count >= 3)
            {
                //3张图片及以上
                var widthTmp:CGFloat;
                widthTmp = (CGFloat)(width - 2*offset)/3;
                var index = 0
                for _ in imgArray
                {
                    index++;
                }
                
                if(index > 3)
                {
                    textTmpYpostion = yPosition + CGFloat(2 * Int(widthTmp + offset));
                }
                else
                {
                    textTmpYpostion = yPosition + CGFloat(Int(widthTmp + offset));
                }
            }
        }
        else
        {
            isTop = true;
            textTmpYpostion = 118;
        }
        
        var lbPostion:CGFloat;
        if(isTop)
        {
            //lbPostion = yPosition ;
            lbPostion = yPosition;
            //textYpostion = yPosition;
        }
        else
        {
            lbPostion = textTmpYpostion;
        }
        
        
        var bottomY = textTmpYpostion + size + 25;
        
        var resut = textTmpYpostion + size + 30 + bottomHeight;
        
        if(isTop)
        {
            if(size + 20 + lbPostion > 133)
            {
                bottomY = size + lbPostion + 20;
            }
            else
            {
                bottomY = 133;
            }
            
            resut = bottomY + bottomHeight;
        }
        
        return resut + 30;
        
    }
    
    class func judgeNum(strInput:NSString)->Bool
    {
        if(strInput.isEqualToString("") || strInput.length <= 0)
        {
            return false;
        }
        var strTmp:NSString;
        strTmp = strInput.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet());
        if(strTmp.length > 0)
        {
            return false;
        }
        return true;
    }
    
    class func judgeEmail(strInput:NSString)->Bool
    {
        if(strInput.isEqualToString("") || strInput.length <= 0)
        {
            return false;
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        
        let email = NSPredicate(format:"SELF MATCHES%@",emailRegex);
        
        return email.evaluateWithObject(strInput);
    }
    
    
    func imageViewTapped(sender:UITapGestureRecognizer)
    {
        
        imageDataArray.removeAllObjects()
        
        for imageView in imgList {
            if imageView.image==nil {
                return
            }
            imageDataArray.addObject(imageView.image!)
        }
        
        
        let imgIndex = (sender.view?.tag)! - baseTagValue
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "imageCellTap", object:nil, userInfo: ["imageArray":imageDataArray, "imageIndex":imgIndex]));
       
        
   /*
        let i:Int = sender.view!.tag
        let image = self.imgList[i].image
        let window = UIApplication.sharedApplication().keyWindow
        let backgroundView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        backgroundView.backgroundColor = UIColor.blackColor()
        backgroundView.alpha = 0
        let imageView = UIImageView(frame: self.imgList[i].frame)
        
        imageView.image = image
        
        //        imageView.tag = i + 1
        backgroundView.addSubview(imageView)
        window?.addSubview(backgroundView)
        let hide = UITapGestureRecognizer(target: self, action: "hideImage:")
        
        
//        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
//        self.backgroundView!.addGestureRecognizer(swipeLeft)
//        
//        var swipeRight = UISwipeGestureRecognizer(target: self, action: "handleSwipe:")
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        self.backgroundView!.addGestureRecognizer(swipeRight)

        
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(hide)
        UIView.animateWithDuration(0.3, animations:{ () in
            let vsize = UIScreen.mainScreen().bounds.size
            imageView.frame = CGRect(x:0.0, y: 0.0, width: vsize.width, height: vsize.height)
            imageView.contentMode = .ScaleAspectFit
            backgroundView.alpha = 1
            }, completion: {(finished:Bool) in })
        
      */
    }
    
    func hideImage(sender: UITapGestureRecognizer){
        let i:Int = sender.view!.tag
        let backgroundView = sender.view as UIView?
        if let view = backgroundView{
            UIView.animateWithDuration(0.1,
                animations:{ () in
                    let imageView = view.viewWithTag(i) as! UIImageView
                    imageView.frame = self.imgList[i].frame
                    imageView.alpha = 0
                    
                },
                completion: {(finished:Bool) in
                    view.alpha = 0
                    view.superview?.removeFromSuperview()
                    view.removeFromSuperview()
            })
        }
    }
    
}
