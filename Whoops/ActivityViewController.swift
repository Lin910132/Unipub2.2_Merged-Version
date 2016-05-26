//
//  ActivityViewController.swift
//  UniPub
//
//  Created by Li Jiatan on 4/4/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let identifier = "cell"
    
    var url = ""
    var sorceUrl = ""
    var page = 1
    var dataArray = NSMutableArray()
    var stopLoading = false
    
    var tableView: UITableView!
    var MainViewController:YRMainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "Activity"
        SetUpView()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivityViewController.imageViewTapped(_:)), name: "imageViewTapped", object: nil)
    }
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.MainViewController?.fromDetail = true
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
    }
    
    
    func imageViewTapped(noti:NSNotification)
    {
        
        let imageURL = noti.object as! String
        let imgVC = YRImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = imageURL
        self.navigationController?.pushViewController(imgVC, animated: true)
    }
    
    func SetUpView() {
        //self.automaticallyAdjustsScrollViewInsets = false
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        self.tableView = UITableView(frame:CGRectMake(0,0,width,height), style:.Grouped)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView?.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        let nib = UINib(nibName:"YRJokeCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0)
        self.view.addSubview(self.tableView!)
        addRefreshControll()
    }
    
    func addRefreshControll()
    {
        //let emptyRefresh:UIRefreshControl = UIRefreshControl()
        let fresh:UIRefreshControl = UIRefreshControl()
        fresh.addTarget(self, action: #selector(ActivityViewController.actionRefreshHandler(_:)), forControlEvents: UIControlEvents.ValueChanged)
        fresh.tintColor = UIColor.whiteColor()
        fresh.attributedTitle = NSAttributedString(string: "Loading".localized() + "...")
        self.tableView.separatorInset = UIEdgeInsetsMake(100, 100, 100, 100)
        self.tableView.addSubview(fresh)
    }
    
    func actionRefreshHandler(sender: UIRefreshControl)
    {
        self.stopLoading = false
        self.page = 1
        //let url = "http://104.131.91.181:8080/whoops/post/listNewBySchool?schoolId=\(self.schoolId)&pageNum=1&uid=\(FileUtility.getUserId())"
        if url == ""{
            UIView.showAlertView("Opps".localized(), message: "Can't find the Activity...")
            return
        }else{
            self.sorceUrl = url + "&pageNum=\(page)"
        }
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps".localized(),message: "Loading Failed".localized())
                sender.endRefreshing()
                return
            }
            
            let arr = data.objectForKey("data") as! NSArray
            
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
        //let url = urlString()
        if url == ""{
            UIView.showAlertView("Opps".localized(), message: "Can't find the Activity...")
            return
        }else{
            self.sorceUrl = url + "&pageNum=\(page)"
        }
        
        YRHttpRequest.requestWithURL(self.sorceUrl,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps",message: "Loading Failed".localized())
                return
            }
            
            let arr = data.objectForKey("data") as! NSArray
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
                    let dataDic = data as! NSDictionary
                    let oldId : Int? = dataDic.valueForKey("id") as? Int
                    
                    let itemDic = item as! NSDictionary
                    let newId = itemDic.valueForKey("id") as? Int
                    
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
    
    func changeButtonState(tbIndex:Int, rIndex:NSIndexPath, key:String, value:String){
        let data:NSMutableDictionary = NSMutableDictionary(dictionary: dataArray[rIndex.row] as! [NSObject : AnyObject])
        var bChanged = false
        if (key == "isFavor"){
            data.setValue(value, forKey: key)
            bChanged = true
            MainViewController?.refreshMain()
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
        
        self.tableView!.reloadRowsAtIndexPaths([rIndex], withRowAnimation: UITableViewRowAnimation.None)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        var cell :YRJokeCell2? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRJokeCell2
        if cell == nil{
            cell = YRJokeCell2(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.data = data
        cell!.setCellUp()
        cell?.rowIndex = indexPath
        cell?.activityConroller = self
        cell?.category = 5
        //cell!.delegate = self;
        //cell!.refreshUniversityDelete = self
        cell!.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
        
        if (indexPath.row == dataArray.count-1)&&(!self.stopLoading){
            page++
            loadData()
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
        commentsVC.jokeId = data.stringAttributeForKey("id")
        commentsVC.activityController = self
        commentsVC.rowIndex = indexPath
        commentsVC.category = 5
        commentsVC.hidesBottomBarWhenPushed = true
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRJokeCell2.cellHeightByData(data)
    }

}
