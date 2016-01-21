//
//  MyPostCommentViewController.swift
//  Whoops
//
//  Created by Li Jiatan on 3/8/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//


import UIKit
import MessageUI

class MyPostCommentViewController: UITableViewController, YRRefreshViewDelegate,MFMailComposeViewControllerDelegate,YRJokeCellDelegate {
    
    let identifier = "cell"
    var dataArray = NSMutableArray()
    var page :Int=1
    var refreshView:YRRefreshView?
    var jokeId:String!
    //var badgeNumber = glovalVar
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Comments"
        self.tableView.backgroundColor = UIColor(red: 0.173, green: 0.133, blue: 0.361, alpha: 1.0)
        setupViews()
        loadData()
    }
    
    func setupViews()
    {
        let nib = UINib(nibName: "YRCommnentsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        
        var arr =  NSBundle.mainBundle().loadNibNamed("YRRefreshView" ,owner: self, options: nil) as Array
        self.refreshView = arr[0] as? YRRefreshView
        self.refreshView!.delegate = self
        self.tableView.tableFooterView = self.refreshView
    }
    
    func loadData()
    {
        //var url = "http://m2.qiushibaike.com/article/\(self.jokeId)/comments?count=20&page=\(self.page)"
        //var url = FileUtility.getUrlDomain() + "post/get?id=\(self.jokeId)"
        let url = "http://104.131.91.181:8080/whoops/comment/getCommentByPostId?postId=\(self.jokeId)"
        self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            var badgeNumber: Int=0
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Oops!",message:"Refresh Failed")
                return
            }
            
            let arr = data["data"] as! NSArray
            if arr.count  == 0
            {
                UIView.showAlertView("Alert".localized(), message: "No more Comments T_T".localized())
                self.tableView!.tableFooterView = nil
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
                    badgeNumber += 1;
                }
                
                
            }
            
            let tabItem = self.tabBarController?.tabBar.items![3];
            if badgeNumber>0 {
            tabItem!.badgeValue = String(badgeNumber)
            }
            self.tableView!.reloadData()
            self.refreshView!.stopLoading()
           
        })
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! YRCommnentsCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        cell.data = data
        
        //if (indexPath.row == dataArray.count - 1){
        //    self.page++
        //    loadData()
        //}
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRCommnentsCell.cellHeightByData(data)
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
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK".localized())
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }

    

}
