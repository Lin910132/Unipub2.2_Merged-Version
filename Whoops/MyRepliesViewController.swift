//
//  MyRepliesViewController.swift
//  Whoops
//
//  Created by Li Jiatan on 3/8/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit
import MessageUI


class MyRepliesViewController: UITableViewController,MFMailComposeViewControllerDelegate, YRRefreshViewDelegate,YRJokeCellDelegate,YRRefreshMyRepliesDelegate {
    
    let identifier = "cell"
    var dataArray = NSMutableArray()
    var page :Int = 1
    var refreshView:YRRefreshView?
    var uid = String()
    var stopLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Replies"
        setupViews()
        loadData()
    }
    
    
    func refreshMyRepliesByFavor(){
        let fresh:UIRefreshControl = UIRefreshControl()
        self.actionRefreshHandler(fresh)

    }
    func setupViews()
    {
        let nib = UINib(nibName:"YRJokeCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        
        //var arr =  NSBundle.mainBundle().loadNibNamed("YRRefreshView" ,owner: self, options: nil) as Array
        //self.refreshView = arr[0] as? YRRefreshView
        //self.refreshView!.delegate = self
        //self.tableView.tableFooterView = self.refreshView
        
        addRefreshControll()
    }
    
    func addRefreshControll()
    {
        let fresh:UIRefreshControl = UIRefreshControl()
        fresh.addTarget(self, action: "actionRefreshHandler:", forControlEvents: UIControlEvents.ValueChanged)
        fresh.tintColor = UIColor.whiteColor()
        self.tableView.addSubview(fresh)
    }
    
    func actionRefreshHandler(sender: UIRefreshControl)
    {
        page = 1
        self.stopLoading = false
        let url = "http://104.131.91.181:8080/whoops/post/listByCommentAndUid?uid=\(FileUtility.getUserId())&pageNum=1"
       // self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps".localized(), message: "Loading Failed".localized())
                sender.endRefreshing()
                return
            }
            
            let arr = data["data"] as! NSArray
            
            self.dataArray = NSMutableArray()
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
                
            }
            self.tableView!.reloadData()
            //self.refreshView!.stopLoading()
            
            sender.endRefreshing()
        })
    }
    
    func loadData()
    {
        let url = urlString()
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps".localized(), message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            if self.page == 1 {
                self.dataArray = NSMutableArray()
            }
            //self.page++
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
            self.tableView!.reloadData()
            //self.refreshView!.stopLoading()
            
        })
        
    }
    
    func urlString()->String
    {
        
        self.uid = FileUtility.getUserId()
        return "http://104.131.91.181:8080/whoops/post/listByCommentAndUid?uid=\(self.uid)&pageNum=\(page)"
    }
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        //refreshView.startLoading()
        loadData()
    }

    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageViewTapped:", name: "imageViewTapped", object: nil)
        self.navigationItem.title = "My Replies".localized()
        //self.page = 1
        //loadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        let data = self.dataArray[index] as! NSDictionary
        var cell :YRJokeCell2? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRJokeCell2
        if cell == nil{
            cell = YRJokeCell2(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.data = data
        cell?.category = 4
        cell?.replyController = self
        cell?.rowIndex = index
        cell!.setCellUp()
        cell!.delegate = self;
        cell!.refreshMyRepliesDelegate = self
        cell!.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
        
        if (indexPath.row == dataArray.count-1)&&(!self.stopLoading){
            page++
            loadData()
        }
        
        return cell!

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
        commentsVC.jokeId = data.stringAttributeForKey("id")
        commentsVC.hidesBottomBarWhenPushed = true
        commentsVC.replyController = self
        commentsVC.rowIndex = index
        commentsVC.category = 2
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRJokeCell2.cellHeightByData(data)
    }

    func imageViewTapped(noti:NSNotification)
    {
        
        let imageURL = noti.object as! String
        let imgVC = YRImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = imageURL
        self.navigationController?.pushViewController(imgVC, animated: true)
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
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email".localized(), message: "Your device could not send e-mail.  Please check e-mail configuration and try again.".localized(), delegate: self, cancelButtonTitle: "OK".localized())
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func changeButtonState(tbIndex:Int, rIndex:Int, key:String, value:String){
        let data:NSMutableDictionary = NSMutableDictionary(dictionary: dataArray[rIndex] as! [NSObject : AnyObject])
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
            dataArray.replaceObjectAtIndex(rIndex, withObject: newData)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
}
