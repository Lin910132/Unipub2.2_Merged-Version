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

    @IBOutlet weak var likeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uid = FileUtility.getUserId()
        _db.removeAllObjects()
        let nib = UINib(nibName:"LikeViewCell", bundle: nil)
        self.likeTableView.registerNib(nib, forCellReuseIdentifier: identifier)
        addRefreshControll()
        load_Data()
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(animated: Bool) {
        //self.navigationItem.title = "Likes".localized()
        
        //_db.removeAllObjects()
        //self.page = 1
        //load_Data()
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
                UIView.showAlertView("Opps",message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            if self.page == 1 {
                self._db = NSMutableArray()
            }
            
            if (arr.count == 0){
                self.likeTableView.endLoadMoreData()
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
            
            self.likeTableView!.reloadData()
            
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
        return self._db.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? LikeViewCell
        var cell : LikeViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? LikeViewCell
        if cell == nil{
            cell = LikeViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        let index = indexPath.row
        cell!.data = _db[index] as! NSDictionary
        cell!.setupSubviews()
        if (indexPath.row == self._db.count-1) && (self.stopLoading == false){
            self.page++
            load_Data()
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self._db[index] as! NSDictionary
        let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
        commentsVC.jokeId = data.stringAttributeForKey("postId")
        commentsVC.hidesBottomBarWhenPushed = true
        
        likeTableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let index = indexPath.row
        let data = self._db[index] as! NSDictionary
        return  LikeViewCell.cellHeightByData(data)
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
