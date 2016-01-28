//
//  UniversityViewController.swift
//  Whoops
//
//  Created by Li Jiatan on 3/8/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit
import MessageUI



class UniversityViewController: UITableViewController, YRRefreshViewDelegate,MFMailComposeViewControllerDelegate,YRJokeCellDelegate,YRRefreshUniversityDelegate {
    
    let identifier = "cell"
    var dataArray = NSMutableArray()
    var page :Int = 1
    var refreshView:YRRefreshView?
    var currentUniversity = String()
    var schoolId = String()

    @IBOutlet var postBtn: UIBarButtonItem!

    
    @IBAction func showPostButton(sender: AnyObject) {
        
        SchoolObject.schoolId = self.schoolId
        SchoolObject.schoolName = currentUniversity
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("postNavigation")
        //isSchool = true
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentUniversity
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "SendButtonRefresh:",name:"load", object: nil)
        setupViews()
        loadData()
    }
    
    func setupViews()
    {
        
        if (Int64 (schoolId) == 81){
            postBtn.enabled = false
            self.navigationItem.setRightBarButtonItem(nil, animated: true)
        }
        
        if (Int64 (schoolId) > 10000){
            postBtn.enabled = false
            self.navigationItem.setRightBarButtonItem(nil, animated: true)
        }
        
        let nib = UINib(nibName:"YRJokeCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        
        tableView.toLoadMoreAction({ () -> Void in
            self.page++
            self.loadData()
            self.tableView.doneRefresh()
        })
        
        addRefreshControll()
        
        SchoolObject.result = self.schoolId
        SchoolObject.schoolName = self.currentUniversity
        
    }
    
    func addRefreshControll()
    {
        let fresh:UIRefreshControl = UIRefreshControl()
        fresh.addTarget(self, action: "actionRefreshHandler:", forControlEvents: UIControlEvents.ValueChanged)
        fresh.tintColor = UIColor.whiteColor()
        self.tableView.addSubview(fresh)
    }
    
    func SendButtonRefresh(sender: UIRefreshControl)
    {
        self.page = 1
        let url = "http://104.131.91.181:8080/whoops/post/listNewBySchool?schoolId=\(self.schoolId)&pageNum=1&uid=\(FileUtility.getUserId())"
        tableView.beginLoadMoreData()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps",message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            self.dataArray = NSMutableArray()
            
            
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
                
            }
            self.tableView!.reloadData()

        })
        
    }
    
    func actionRefreshHandler(sender: UIRefreshControl)
    {
        self.page = 1
        let url = "http://104.131.91.181:8080/whoops/post/listNewBySchool?schoolId=\(self.schoolId)&pageNum=1&uid=\(FileUtility.getUserId())"
        tableView.beginLoadMoreData()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps".localized(),message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            
            
            self.dataArray = NSMutableArray()
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
                
            }
            self.tableView!.reloadData()
            sender.endRefreshing()
        })

    }
    
    func loadData()
    {
        let url = urlString()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps",message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            if self.page == 1 {
                self.dataArray = NSMutableArray()
            }
            
            

            
            if (arr.count == 0){
                self.tableView.endLoadMoreData()
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

        })
        
    }
    
    func urlString()->String
    {
        return "http://104.131.91.181:8080/whoops/post/listNewBySchool?schoolId=\(self.schoolId)&pageNum=\(page)&uid=\(FileUtility.getUserId())"
    }
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        self.page++
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //self.tableView.re
        //page = 1
        //loadData()
    }
    
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
        cell!.setCellUp()
        cell!.delegate = self;
        cell!.refreshUniversityDelete = self
        cell!.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
        commentsVC.jokeId = data.stringAttributeForKey("id")
        commentsVC.hidesBottomBarWhenPushed = true
        //self.navigationItem.title = "Back".localized()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRJokeCell2.cellHeightByData(data)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let send = segue.destinationViewController as! YRNewPostViewController
        send.schoolId = self.schoolId
        send.schoolName = self.currentUniversity
    }
    
    func imageViewTapped(noti:NSNotification)
    {
        
        let imageURL = noti.object as! String
        let imgVC = YRImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = imageURL
        self.navigationController?.pushViewController(imgVC, animated: true)
    }
    
    func refreshUniversityByFavor(){
        let fresh:UIRefreshControl = UIRefreshControl()
        self.actionRefreshHandler(fresh)
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
    
    
    
}
