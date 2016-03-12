//
//  LikeViewController.swift
//  Whoop
//
//  Created by Li Jiatan on 4/16/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let identifier = "likeViewCell"
    var stopLoading: Bool = true
    var _db = NSMutableArray()
    var uid = String()
    var page: Int = 1
    
    var limitCount = 0
    var realCount = 0
    var bLoadMore = false
    
    @IBOutlet weak var likeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uid = FileUtility.getUserId()
        _db.removeAllObjects()
        let nib = UINib(nibName:"LikeViewCell", bundle: nil)
        self.likeTableView.registerNib(nib, forCellReuseIdentifier: identifier)
        //addRefreshControll()
        load_Data()
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Likes".localized()
        
        //_db.removeAllObjects()
        //self.page = 1
        //load_Data()
        bLoadMore = false
        let tabItem = self.tabBarController?.tabBar.items![3]
        var notificationNumber: Int64 = 0
        
        if tabItem?.badgeValue != nil {
            var badgeNumber = (tabItem?.badgeValue)! as String
            if (badgeNumber.characters.last == "+"){
                badgeNumber = badgeNumber.substringToIndex(badgeNumber.characters.count - 1)
            }
            notificationNumber = Int64 (badgeNumber)!
            limitCount = Int (badgeNumber)!
        }
        
        if notificationNumber > 0{
            _db.removeAllObjects()
            self.page = 1
            load_Data()
        }
    }
    
    func addRefreshControll()
    {
        let fresh:UIRefreshControl = UIRefreshControl()
        fresh.addTarget(self, action: "actionRefreshHandler:", forControlEvents: UIControlEvents.ValueChanged)
        fresh.tintColor = UIColor.whiteColor()
        self.likeTableView.addSubview(fresh)
    }
    
    func actionRefreshHandler(sender: UIRefreshControl)
    {
        self.page = 1
        let url = FileUtility.getUrlDomain() + "msg/getMsgByUId?uid=\(self.uid)&pageNum=\(self.page)"
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps".localized(),message: "Loading Failed".localized())
                sender.endRefreshing()
                return
            }
            
            let arr = data["data"] as! NSArray
            
            
            
            self._db = NSMutableArray()
            for data : AnyObject  in arr
            {
                self._db.addObject(data)
                
            }
            self.likeTableView!.reloadData()
            sender.endRefreshing()
        })
    }
    
    func load_Data(){
        let url = FileUtility.getUrlDomain() + "msg/getMsgByUId?uid=\(self.uid)&pageNum=\(self.page)"
        //var url = "http://104.131.91.181:8080/whoops/msg/getMsgByUId?uid=97&pageNum=1"
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            if (arr.count == 0){
                self.stopLoading = true
            }else{
                self.stopLoading = false
            }
            
            for data : AnyObject  in arr
            {
                var isExist:Bool = false
                for item in self._db
                {
                    let oldId = data["id"] as! Int
                    let newId = item["id"] as! Int
                    if  oldId == newId
                    {
                        isExist = true
                    }
                }
                if isExist == false {
                    self._db.addObject(data)
                }

            }
            
            self.likeTableView.reloadData()

        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self._db.count
        
        if (bLoadMore == true){
            realCount = count
            return count
        }
        else {
            if (count == 0){
                return 0
            }
            else if (count < limitCount){
                realCount = count
            }
            else{
                realCount = limitCount
            }
            return realCount + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? LikeViewCell
        var cell : LikeViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? LikeViewCell
        if cell == nil{
            cell = LikeViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        let index = indexPath.row
        if (indexPath.row < realCount){
            cell!.data = _db[index] as! NSDictionary
            cell!.setupSubviews()
            if (indexPath.row == self._db.count-1) && (self.stopLoading == false){
                self.page++
                load_Data()
            }
        }
        else if (indexPath.row == realCount && bLoadMore == false){
            cell?.title.hidden = true
            cell?.content.hidden = true
            cell?.viewMore.hidden = false
            cell?.likeImg.hidden = true
            
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (bLoadMore == true){
        
            let index = indexPath.row
            let data = self._db[index] as! NSDictionary
            let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
            commentsVC.jokeId = data.stringAttributeForKey("postId")
            commentsVC.hidesBottomBarWhenPushed = true
        
            likeTableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.navigationController?.pushViewController(commentsVC, animated: true)
        }
        else {
            if (indexPath.row == realCount){
                bLoadMore = true
                tableView.reloadData()
            }
            else {
                let index = indexPath.row
                let data = self._db[index] as! NSDictionary
                let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
                commentsVC.jokeId = data.stringAttributeForKey("postId")
                commentsVC.hidesBottomBarWhenPushed = true
                commentsVC.notiDetect = true
                
                likeTableView.deselectRowAtIndexPath(indexPath, animated: true)
                self.navigationController?.pushViewController(commentsVC, animated: true)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let index = indexPath.row
        if (index < realCount){
            let data = self._db[index] as! NSDictionary
            return  LikeViewCell.cellHeightByData(data, bLast: false)
        }
        else if (bLoadMore == false){
            return 50.0
        }
        
        return 50.0
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
