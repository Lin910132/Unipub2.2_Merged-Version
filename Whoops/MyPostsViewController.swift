//
//  MyPostsViewController.swift
//  Whoops
//
//  Created by Li Jiatan on 2/27/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MessageUI

class MyPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate,YRRefreshViewDelegate,YRJokeCellDelegate{

    var dataArray = NSMutableArray()
    let identifier = "cell"
    var page:Int = 1
    var refreshView: YRRefreshView?
    var uid = String()
    var stopLoading:Bool = false
    
    @IBOutlet weak var PostTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadData()
        //self.title = "Profile"
        //uid = FileUtility.getUserId()
        //self.uid = "1"
        //self.addRefreshControl()
        // Do any additional setup after loading the view.
    }
    

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Post".localized()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageViewTapped:", name: "imageViewTapped", object: nil)
        //self.page = 1
        //loadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        
    }
    
    func imageViewTapped(noti:NSNotification)
    {
        
        let imageURL = noti.object as! String
        let imgVC = YRImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = imageURL
        self.navigationController?.pushViewController(imgVC, animated: true)
        
        
    }
    
    func setupViews(){
        let nib = UINib(nibName:"YRJokeCell", bundle: nil)
        
        self.PostTableView.registerNib(nib, forCellReuseIdentifier: identifier)
        //var arr =  NSBundle.mainBundle().loadNibNamed("YRRefreshView" ,owner: self, options: nil) as Array
        //self.refreshView = arr[0] as? YRRefreshView
        //self.refreshView?.delegate = self
        //self.PostTableView.tableFooterView = self.refreshView
        
        self.addRefreshControl()
    }
    
    func addRefreshControl(){
        
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "actionRefreshHandler:", forControlEvents: UIControlEvents.ValueChanged)
        refresh.tintColor = UIColor.whiteColor()
        self.PostTableView.addSubview(refresh)
    }
    
    func actionRefreshHandler(sender:UIRefreshControl){
        
        page = 1
        self.stopLoading = false
        let url = "http://104.131.91.181:8080/whoops/post/listByUid?uid=\(FileUtility.getUserId())&pageNum=1"
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps",message:"Loading Failed")
                sender.endRefreshing()
                return
            }
            
            let arr = data["data"] as! NSArray
            
            self.dataArray = NSMutableArray()
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
                
            }
            self.PostTableView.reloadData()
            //self.refreshView!.stopLoading()
            
            sender.endRefreshing()
            
        })
    }
    
    
    func loadData(){
        let url = urlString()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                let myAltert=UIAlertController(title: "Alert".localized(), message: "Refresh Failed".localized(), preferredStyle: UIAlertControllerStyle.Alert)
                myAltert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(myAltert, animated: true, completion: nil)
                return
            }
            
            let arr = data["data"] as! NSArray
            if self.page == 1 {
                self.dataArray = NSMutableArray()
            }
            
            if (arr.count == 0){
                self.stopLoading = true
            }else{
                self.stopLoading = false
            }
            
            for data : AnyObject  in arr
            {
                var isExist:Bool = false
                for item in self.dataArray
                {
                    let oldId = data["id"] as! Int
                    let newId = item["id"] as! Int
                    if  oldId == newId
                    {
                        isExist = true
                    }
                }
                if isExist == false {
                    self.dataArray.addObject(data)
                }
                
            }

            self.PostTableView.reloadData()
            //self.refreshView!.stopLoading()
        })
    }
    
    func urlString() ->String{
        //return "http://m2.qiushibaike.com/article/list/latest?count=20&page=\(page)"
        self.uid = FileUtility.getUserId()
        return "http://104.131.91.181:8080/whoops/post/listByUid?uid=\(self.uid)&pageNum=\(self.page)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let index = indexPath.row
        
        let data = self.dataArray[index] as! NSDictionary
        var cell :YRJokeCell2? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRJokeCell2
        if cell == nil{
            cell = YRJokeCell2(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.data = data
        cell?.category = 3
        cell?.postViewController = self
        cell?.rowIndex = indexPath
        cell!.setCellUp()
        cell!.delegate = self;
        cell!.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
        
        if (indexPath.row == dataArray.count-1)&&(!stopLoading){
            page++
            loadData()
        }
        
        return cell!
        

    }
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        self.page++
        loadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRJokeCell2.cellHeightByData(data)
    }
    
     /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
     {
        var postComment = segue.destinationViewController as MyPostCommentViewController
        if let indexPath = self.PostTableView.indexPathForSelectedRow()
        {
            var comment = self.dataArray[indexPath.row] as NSDictionary
            postComment.jokeId = comment.stringAttributeForKey("id")

        }
    }*/
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
        commentsVC.jokeId = data.stringAttributeForKey("id")
        commentsVC.hidesBottomBarWhenPushed = true
        commentsVC.postController = self
        commentsVC.rowIndex = indexPath
        commentsVC.category = 3
        PostTableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    
    func sendEmail(strTo:String, strSubject:String, strBody:String)
    {
        let controller = MFMailComposeViewController();
        controller.mailComposeDelegate = self;
        controller.setSubject(strSubject);
        var toList: [String] = [String]()
        toList.append(strTo)
        controller.setToRecipients(toList)
        controller.setMessageBody(strBody, isHTML: false);
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(controller, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.".localized(), delegate: self, cancelButtonTitle: "OK".localized())
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.PostTableView.reloadData()
    }
 
    func changeButtonState(tbIndex:Int, rIndex:NSIndexPath, key:String, value:String){
        let data:NSMutableDictionary = NSMutableDictionary(dictionary: dataArray[rIndex.row] as! [NSObject : AnyObject])
        var bChanged = false
        if (key == "isFavor"){
            data.setValue(value, forKey: key)
            bChanged = true
        }
        else if (key == "isLike"){
            data.setValue(value, forKey: key)
            bChanged = true
        }
        else if (key == "likeNum"){
            if (value == "0"){
                data.setValue(NSNull(), forKey: key)
            }
            else {
                data.setValue(value, forKey: key)
            }
            bChanged = true
        }
        
        if (bChanged == true){
            let newData:NSDictionary = NSDictionary(dictionary: data)
            dataArray.replaceObjectAtIndex(rIndex.row, withObject: newData)
        }
        
        self.PostTableView.reloadRowsAtIndexPaths([rIndex], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
