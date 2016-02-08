//
//  MainViewController.swift
//  Whoops
//
//  Created by huangyao on 15-2-26.
//  Copyright (c) 2015y Li Jiatan. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MessageUI
import Localize_Swift


//import YRJokeCell2

class YRMainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate, YRRefreshViewDelegate,MFMailComposeViewControllerDelegate,YRJokeCellDelegate,YRRefreshMainDelegate{
    @IBOutlet weak var newBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var hotBtn: UIButton!
    @IBOutlet weak var allTimeHotBtn: UIButton!
    @IBOutlet weak var rankBtn: UIButton!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarview: UIView!
    //@IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let identifier = "cell"
    //    var tableView:UITableView?
    var dataArray = NSMutableArray()
    //var imageArray = NSMutableArray()
    var page = [1,1,1,1,1]
    var refreshView:YRRefreshView?
    let locationManager: CLLocationManager = CLLocationManager()
    var stopLoading: Bool = false
    var lat:Double = 0
    var lng:Double = 0
    var school:Int = 0
    var userId:String = "0"
    
    var type:Int = 4
    
    let itemArray = ["New","Hot","Favorite","All Time Hot","Rank"]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if(ios8()){
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "SendButtonRefresh:",name:"loadMain", object: nil)
        
        locationManager.startUpdatingLocation()
        userId = FileUtility.getUserId()
        self.topBarview.backgroundColor = UIColor(red:65.0/255.0 , green:137.0/255.0 , blue:210.0/255.0 , alpha: 1.0);
        setupViews()
        
        // self.hotClick();
        
    }
    
    
    func SendButtonRefresh(sender:UIRefreshControl){
        page[self.type] = 1
        self.stopLoading = false
        let url = urlString(self.type)
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            self.dataArray = NSMutableArray()
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
            //self.page[self.type]++
            self.tableView!.reloadData()
            //self.refreshView!.stopLoading()

        })
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        //self.tableView.reloadData()
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        
    }
    override func viewDidAppear(animated: Bool) {
        self.newBtn.setTitle(itemArray[0].localized(), forState: .Normal)
        self.hotBtn.setTitle(itemArray[1].localized(), forState: .Normal)
        self.favoriteBtn.setTitle(itemArray[2].localized(), forState: .Normal)
        self.allTimeHotBtn.setTitle(itemArray[3].localized(), forState: .Normal)
        self.rankBtn.setTitle("✨" + itemArray[4].localized() + "✨", forState: .Normal)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageViewTapped:", name: "imageCellTap", object: nil)
        
        //page[self.type] = 1
        //loadData(self.type)
        
        //
        self.newBtn.setTitle(itemArray[0].localized(), forState: .Normal)
        self.hotBtn.setTitle(itemArray[1].localized(), forState: .Normal)
        self.favoriteBtn.setTitle(itemArray[2].localized(), forState: .Normal)
        self.allTimeHotBtn.setTitle(itemArray[3].localized(), forState: .Normal)
        self.rankBtn.setTitle("✨" + itemArray[4].localized() + "✨", forState: .Normal)
        
    }
    
//    @IBAction func postButton(sender: AnyObject) {
//        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("postNavigation") 
//        self.presentViewController(vc, animated: true, completion: nil)
//    }
    
    
    
    func setupViews()
    {
//        var width = self.view.frame.size.width
//        var height = self.view.frame.size.height
        //        self.tableView = UITableView(frame:CGRectMake(0,0,width,height-49))
        
        rankBtn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        rankBtn.selected = true
        
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        
        let nib = UINib(nibName:"YRJokeCell", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        
        self.view.addSubview(self.tableView!)
        
        self.addRefreshControl()
        loadData(self.type)

    }
    
    
    func addRefreshControl(){
        let fresh:UIRefreshControl = UIRefreshControl()
        fresh.addTarget(self, action: "actionRefreshHandler:", forControlEvents: UIControlEvents.ValueChanged)
        fresh.tintColor = UIColor.whiteColor()
        fresh.attributedTitle = NSAttributedString(string: "Loading".localized())
        self.tableView?.addSubview(fresh)
    }
    
    func actionRefreshHandler(sender:UIRefreshControl){
        page[self.type] = 1
        self.stopLoading = false
        let url = urlString(self.type)
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                sender.endRefreshing()
                return
            }
            
            let arr = data["data"] as! NSArray
            
            self.dataArray = NSMutableArray()
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
                
            }
            //Don't increase page, or you'll lose page 2
            //self.page[self.type]++
            self.tableView!.reloadData()
            //self.refreshView!.stopLoading()
            
            sender.endRefreshing()
        })
        
    }
    
    func loadData(type:Int)
    {
        let url = urlString(type)
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            if self.page[type] == 1 {
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
            self.tableView!.reloadData()
            //self.refreshView!.stopLoading()
            
        })
        
        
        
    }
    
    
    func urlString(type:Int)->String
    {
        var url:String = FileUtility.getUrlDomain()
        if(school == 0){
            if type == 0 {
                url += "post/listNewByLocation?latitude=\(lat)&longitude=\(lng)&pageNum=\(page[type])"
            }else if (type == 1){
                url += "post/listHotByLocation?latitude=\(lat)&longitude=\(lng)&pageNum=\(page[type])"
            }else if (type == 2){
                url += "favorPost/list?uid=\(FileUtility.getUserId())&pageNum=\(page[type])"
            }else {
                url += "post/listHotAll?pageNum=\(page[type])"
            }
        }else{
            if type == 0 {
                url += "post/listNewBySchool?schoolId=\(school)&pageNum=\(page[type])"
            }else if (type == 1){
                url += "post/listHotBySchool?schoolId=\(school)&pageNum=\(page[type])"
            }else if (type == 2){
                url += "favorPost/list?uid=\(FileUtility.getUserId())&pageNum=\(page[type])"
            }else {
                url += "post/listHotAll?pageNum=\(page[type])"
            }
        }
        
        if (type == 4){
            url = FileUtility.getUrlDomain() + "post/listByActivity?activityId=1&pageNum=\(page[type])"
        }
        url += "&uid=\(FileUtility.getUserId())"
        
        
        
        return url
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.dataArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        

        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        var cell :YRJokeCell2? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRJokeCell2
        if cell == nil{
            cell = YRJokeCell2(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.data = data
        cell!.setCellUp()
        cell!.delegate = self;
        cell!.refreshMainDelegate = self
        cell!.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
        if (indexPath.row == self.dataArray.count-1) && (self.stopLoading == false){
            self.page[self.type]++
            loadData(self.type)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRJokeCell2.cellHeightByData(data)
        //return 500
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
        commentsVC.jokeId = data.stringAttributeForKey("id")
        commentsVC.hidesBottomBarWhenPushed = true
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.navigationController?.pushViewController(commentsVC, animated: true)
        
        //    self.performSegueWithIdentifier("showComment", sender:data.stringAttributeForKey("id"))
        
    }
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        var postId:String = sender as String;
    //
    //        var commentViewController:YRCommentsViewController =  segue.destinationViewController as YRCommentsViewController;
    //        commentViewController.postId = postId
    //    }
    
    
    
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        //refreshView.startLoading()
        self.page[self.type]++
        loadData(self.type)
    }
    
    func imageViewTapped(noti:NSNotification)
    {
        
        let imageArray = noti.userInfo!["imageArray"] as! NSArray
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imgDetailVC = storyboard.instantiateViewControllerWithIdentifier("imagesDetail") as! ImagesDetailViewController
        imgDetailVC.imageArray = imageArray;
        
        imgDetailVC.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.presentViewController(imgDetailVC, animated: true, completion: nil)
 
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(ios8()){
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CheckLocation")
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        let location:CLLocation = locations[locations.count-1] 
        
        if (location.horizontalAccuracy > 0) {
            lat = location.coordinate.latitude
            lng = location.coordinate.longitude
            if self.page[self.type] == 1 {
                loadData(self.type)
            }
            self.locationManager.stopUpdatingLocation()
            
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        //        self.textLabel.text = "get location error"
    }
    
    @IBAction func tabBarButtonClicked(sender: AnyObject) {
        let index = sender.tag
        self.stopLoading = false
        
        for var i = 0;i<5;i++
        {
            let button = self.view.viewWithTag(i+100) as! UIButton
            if button.tag == index
            {
                button.selected = true
            }
            else
            {
                button.selected = false
            }
        }
        
        self.page[self.type] = 1
        self.dataArray = NSMutableArray()
        self.tableView!.reloadData()
        self.type = index - 100
        self.loadData(index-100)
        //self.setupViews()

    }
    
    
    func ios8()->Bool{
        let version:NSString = UIDevice.currentDevice().systemVersion
        let bigVersion = version.substringToIndex(1)
        let intBigVersion = Int(bigVersion)
        if intBigVersion >= 8 {
            return true
        }else {
            return false
        }
        
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
    
    func refreshMain(){
        let fresh:UIRefreshControl = UIRefreshControl()
        self.actionRefreshHandler(fresh)
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
