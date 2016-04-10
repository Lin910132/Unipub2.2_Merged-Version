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

class YRMainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate, YRRefreshViewDelegate,MFMailComposeViewControllerDelegate,YRJokeCellDelegate,YRRefreshMainDelegate, UIScrollViewDelegate{
    @IBOutlet weak var newBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var hotBtn: UIButton!
    @IBOutlet weak var allTimeHotBtn: UIButton!
    @IBOutlet weak var rankBtn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarview: UIView!
    //@IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let identifier = "cell"
    let activityIdentifier = "ActivityCell"
    var dataArray = [NSMutableArray](count: 5, repeatedValue: NSMutableArray())
    var page = [1,1,1,1,1]
    var refreshView:YRRefreshView?
    let locationManager: CLLocationManager = CLLocationManager()
    var stopLoading = [false, false, false, false, false]
    var lat:Double = 0
    var lng:Double = 0
    var school:Int = 0
    var userId:String = "0"
    
    var type:Int = 2
    var startIndex:Int = 2
    
    let itemArray = ["New","Hot","Favorite","All Time Hot","Rank"]
    var loadingFlag = [0, 0, 0, 0, 0]
    var currentDataCount = [0, 0, 0, 0, 0]
    var buttons = NSMutableArray()
    var tableArray = NSMutableArray()
    var currentIndex = 2
    var newIndex = 2
    var fromPost = false
    var fromDetail = false
    let refreshTag = 1001
    var refreshArray = NSMutableArray()
    
    @IBOutlet var m_LeftSwipeGesture: UISwipeGestureRecognizer!
    @IBOutlet var m_RightSwipeGesture: UISwipeGestureRecognizer!

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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(YRMainViewController.SendButtonRefresh(_:)),name:"loadMain", object: nil)
        
        locationManager.startUpdatingLocation()
        userId = FileUtility.getUserId()
        self.topBarview.backgroundColor = UIColor(red:65.0/255.0 , green:137.0/255.0 , blue:210.0/255.0 , alpha: 1.0);
        
        m_RightSwipeGesture.direction = .Right
        m_LeftSwipeGesture.direction = .Left
        
        setupViews()
        
        // self.hotClick();
        
    }
    
    
    func SendButtonRefresh(sender:UIRefreshControl){
        page[self.type] = 1
        self.stopLoading[self.type] = false
        self.currentDataCount[self.type] = 0
        let url = urlString(self.type)
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                return
            }
            
            let arr = data.objectForKey("data") as! NSArray
            
            self.dataArray[self.type] = NSMutableArray()
            for data : AnyObject  in arr
            {
                var isExist:Bool = false
                for item in self.dataArray[self.type]
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
                    self.dataArray[self.type].addObject(data)
                }
                
            }
            //self.page[self.type]++
            (self.tableArray[self.type] as! UITableView).reloadData()

        })
        
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        //self.tableView.reloadData()
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        
    }
    override func viewDidAppear(animated: Bool) {
        
        
        if (fromDetail == true){
            fromDetail = false

            //for (var i = 0; i < 5; i++){
            //    (self.tableArray[i] as! UITableView).reloadData()
            //}
            return
        }
        
        self.loadTableViews()
        //self.addRefreshControl()
        (self.tableArray[currentIndex] as! UITableView).scrollsToTop = true
        
        if (fromPost == true){
            self.tabBarButtonClicked(buttons[0])
            fromPost = false
        }
        else {
            self.tabBarButtonClicked(buttons[startIndex])
        }
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(YRMainViewController.imageViewTapped(_:)), name: "imageCellTap", object: nil)
        
        //page[self.type] = 1
        //loadData(self.type)
        
        //
        self.newBtn.setTitle(itemArray[0].localized(), forState: .Normal)
        self.hotBtn.setTitle(itemArray[1].localized() + "  ", forState: .Normal)
        self.favoriteBtn.setTitle(itemArray[2].localized(), forState: .Normal)
        self.allTimeHotBtn.setTitle(itemArray[3].localized(), forState: .Normal)
        self.rankBtn.setTitle(itemArray[4].localized(), forState: .Normal)
        self.loadButtons()
    }
    
    func loadTableViews(){
        
        let nib = UINib(nibName:"YRJokeCell", bundle: nil)
        let activityNib = UINib(nibName: "ActivityCell", bundle: nil)
        
        for i in 0 ... 4{
            let table:UITableView = UITableView()
            table.delegate = self
            table.dataSource = self
            table.registerNib(nib, forCellReuseIdentifier: identifier)
            table.registerNib(activityNib, forCellReuseIdentifier: activityIdentifier)
            table.tag = 1000 + i
            table.separatorStyle = .None
            table.scrollsToTop = false
            tableArray.addObject(table)
            loadingFlag[i] = 0
        }
        
        let mainWidth = UIScreen.mainScreen().bounds.width
        
        for i in 0 ... 4{
            let rect:CGRect = CGRectMake(mainWidth * CGFloat(i), 0, mainWidth, scrollView.frame.height)
            let view:UIView = UIView(frame: rect)
            let table:UITableView = tableArray[i] as! UITableView
            table.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
            view.addSubview(table)
            self.scrollView.addSubview(view)
            self.scrollView.scrollsToTop = false

        }
        
        self.scrollView.contentSize = CGSizeMake(mainWidth * 5, scrollView.frame.height)
    }
    
    func setupViews()
    {
        self.scrollView.delegate = self
        rankBtn.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.loadTableViews()
        self.addRefreshControl()
    }
    
    func addRefreshControl(){
        refreshArray.removeAllObjects()
        for i in 0 ... 4{
            let fresh:UIRefreshControl = UIRefreshControl()
            fresh.addTarget(self, action: #selector(YRMainViewController.actionRefreshHandler(_:)), forControlEvents: UIControlEvents.ValueChanged)
            fresh.tintColor = UIColor.grayColor()
            fresh.attributedTitle = NSAttributedString(string: "Loading".localized())
            (self.tableArray[i] as! UITableView).addSubview(fresh)
            fresh.hidden = true
            refreshArray.addObject(fresh)
        }
    }
    
    func actionRefreshHandler(sender:UIRefreshControl){
        page[self.type] = 1
        self.stopLoading[self.type] = false
        self.currentDataCount[self.type] = 0
        let url = urlString(self.type)
        //self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                sender.endRefreshing()
                return
            }
            
            //let arr = data["data"] as! NSArray
            let arr = data.objectForKey("data") as! NSArray
            
            self.dataArray[self.type] = NSMutableArray()
            for data : AnyObject  in arr
            {
                self.dataArray[self.type].addObject(data)
                
            }
            //self.page[self.type]++
            (self.tableArray[self.type] as! UITableView).reloadData()
            
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
            
            //let arr = data["data"] as! NSArray
            let arr = data.objectForKey("data") as! NSArray
            
            if self.page[self.type] == 1 {
                self.dataArray[self.type] = NSMutableArray()
            }
            
            if (arr.count == 0){
                self.stopLoading[type] = true
            }else{
                self.stopLoading[type] = false
            }
            
            for data in arr
            {
                var isExist:Bool = false
                for item in self.dataArray[self.type]
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
                    self.dataArray[self.type].addObject(data)
                }
                
            }
            (self.tableArray[self.type] as! UITableView).reloadData()
            print("Data load End -- \(self.type)")
        })
        
        
        
    }
    
    
    func urlString(type:Int)->String
    {
        var url:String = FileUtility.getUrlDomain()
        if(school == 0){
            if type == 0 {
                url += "post/listNewByLocation?latitude=\(lat)&longitude=\(lng)&pageNum=\(page[type])"
            }else if (type == 3){ //1
                url += "post/listHotByLocation?latitude=\(lat)&longitude=\(lng)&pageNum=\(page[type])"
            }else if (type == 1){ //2
                url += "favorPost/list?uid=\(FileUtility.getUserId())&pageNum=\(page[type])"
            }else {
                url += "post/listHotAll?pageNum=\(page[type])"
            }
        }else{
            if type == 0 {
                url += "post/listNewBySchool?schoolId=\(school)&pageNum=\(page[type])"
            }else if (type == 3){ //1
                url += "post/listHotBySchool?schoolId=\(school)&pageNum=\(page[type])"
            }else if (type == 1){ //2
                url += "favorPost/list?uid=\(FileUtility.getUserId())&pageNum=\(page[type])"
            }else {
                url += "post/listHotAll?pageNum=\(page[type])"
            }
        }
        url += "&uid=\(FileUtility.getUserId())"
        
        if (type == 2){ //4
            url = FileUtility.getUrlDomain() + "activity/activityData"
        }
        
        
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
        let tableIndex = getTableIndex(tableView)
        
        if (self.currentDataCount[tableIndex] < self.dataArray[tableIndex].count){
            self.currentDataCount[tableIndex] = self.dataArray[tableIndex].count
            self.stopLoading[tableIndex] = false
        }else{
            if (self.page[tableIndex]>1){
                self.stopLoading[tableIndex] = true
            }
        }
        
        return self.dataArray[tableIndex].count
    }
    
    func getTableIndex(tableView: UITableView) -> Int{
        for i in 0...4
        {
            let table: UITableView = tableArray[i] as! UITableView
            if (table == tableView){
                return i
            }
        }
        return self.type
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let tableIndex = getTableIndex(tableView)
        let index = indexPath.row
        let data = self.dataArray[tableIndex][index] as! NSDictionary
        
        var cell :YRJokeCell2? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRJokeCell2
        if cell == nil{
            cell = YRJokeCell2(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.data = data
        cell!.tableIndex = tableIndex
        cell!.rowIndex = indexPath
        cell?.bInMain = true
        cell?.category = 1
        
        if (self.type != 2){
            cell!.setCellUp()
        }else{
            var activityCell : ActivityCell? = tableView.dequeueReusableCellWithIdentifier(activityIdentifier) as? ActivityCell
            if activityCell == nil{
                activityCell = ActivityCell(style: .Default, reuseIdentifier: activityIdentifier)
            }
            activityCell?.imgUrl = data.stringAttributeForKey("images")
            activityCell?.SetUpVeiw()
            return activityCell!
        }
        
        cell!.delegate = self;
        cell!.refreshMainDelegate = self
        cell!.mainController = self
        cell!.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
        if (indexPath.row == self.dataArray[tableIndex].count-1) && (self.stopLoading[self.type] == false){
            self.page[self.type] += 1
            loadData(self.type)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let index = indexPath.row
        let tableIndex = getTableIndex(tableView)
        let data = self.dataArray[tableIndex][index] as! NSDictionary
        if self.type != 2 {
            return  YRJokeCell2.cellHeightByData(data)
        }else{
            return 200
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath
        let tableIndex = getTableIndex(tableView)
        
        if (tableIndex == 2){
            let activityVC = ActivityViewController(nibName: nil, bundle: nil)
            activityVC.url = FileUtility.getUrlDomain() + "post/listByActivity?activityId=1&pageNum=\(page[type])" +
                "&uid=\(FileUtility.getUserId())"
            activityVC.MainViewController = self
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            //self.tabBarController?.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(activityVC, animated: true)
            
        }else{
            let data = self.dataArray[tableIndex][index.row] as! NSDictionary
            let commentsVC = YRCommentsViewController(nibName :nil, bundle: nil)
            commentsVC.jokeId = data.stringAttributeForKey("id")
            commentsVC.tableIndex = tableIndex
            commentsVC.rowIndex = index
            commentsVC.category = 1
            commentsVC.hidesBottomBarWhenPushed = true
            commentsVC.listController = self
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            self.navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        //self.page[self.type]++
        loadData(self.type)
    }
    
    func imageViewTapped(noti:NSNotification)
    {
        
        let imageArray = noti.userInfo!["imageArray"] as! NSArray
        let imageIndex = noti.userInfo!["imageIndex"] as! Int

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let imgDetailVC = storyboard.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        imgDetailVC.imageArray = imageArray as! [UIImage];
        imgDetailVC.parentController = self
        imgDetailVC.startImageIndex = imageIndex
        imgDetailVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve

        //self.tabBarController?.tabBar.hidden = true
        
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
        
    }
    
    @IBAction func tabBarButtonClicked(sender: AnyObject) {
        let index = sender.tag
        
        for var i = 0;i<5;i++
        {
            let button = self.view.viewWithTag(i+100) as! UIButton
            if button.tag == index
            {
                button.selected = true
                newIndex = i
            }
            else
            {
                button.selected = false
            }
        }
        
        (tableArray[currentIndex] as! UITableView).scrollsToTop = false
        (tableArray[newIndex] as! UITableView).scrollsToTop = true
        
        
        self.type = index - 100
        if (self.loadingFlag[newIndex] == 0){
            self.page[self.type] = 1
            self.dataArray[self.type] = NSMutableArray()
            self.loadData(newIndex)
            (tableArray[newIndex] as! UITableView).reloadData()
            self.loadingFlag[newIndex] = 1
            self.stopLoading[self.type] = false
            self.currentDataCount[self.type] = 0
        }
        //(tableArray[newIndex] as! UITableView).reloadData()
        //self.loadData(index-100)

/*
        0 1 2 3 4
        1 2 3 4 0
        2 3 4 0 1
        3 4 0 1 2
        4 0 1 2 3
*/
        var arr = [3, 4, 0, 1, 2]
        for (var i = 0; i < currentIndex; i++){
        //for i in 0...currentIndex - 1{
            let tmp = arr[0]
            //for (var j = 0; j < 4; j++){
            for j in 0...3{
                arr[j] = arr[j + 1]
            }
            arr[4] = tmp
        }
        
        var virtualIndex = 0
        for (var i = 0; i < 5; i++){
            if (arr[i] == newIndex){
                virtualIndex = i
            }
        }
        
        let offset = abs(virtualIndex - 2)
        let direction = virtualIndex < 2
        
        animateButtons(offset, direction: direction)
        scrollPageWithIndex(self.type)
        
        /*
        if (self.fromPost == true){
        
            for (var i = 0; i < 5; i++){
                (self.refreshArray[i] as! UIRefreshControl).hidden = true
            }
            (self.refreshArray[self.type] as! UIRefreshControl).hidden = false
        }
        */

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
        //let fresh:UIRefreshControl = UIRefreshControl()
        //self.actionRefreshHandler(fresh)
        for (var i = 0; i < 5; i++){
            self.loadingFlag[i] = 0
        }
    }
    
    func FaveBtnClicked(cell:YRJokeCell2){
        
        //let indexPath = (tableArray[self.type] as! UITableView).indexPathForCell(cell)
        //let row = indexPath?.row
        //(self.dataArray[self.type][row!] as! NSDictionary)["isFave"] =
        //(tableArray[self.type] as! UITableView).reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.None)
        
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email".localized(), message: "Your device could not send e-mail.  Please check e-mail configuration and try again.".localized(), delegate: self, cancelButtonTitle: "OK".localized())
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func getSpaceButtons() -> CGFloat{
        let screenFrame = UIScreen.mainScreen().bounds
        var space:CGFloat = screenFrame.width
        
        for (var i = 0; i < 5; i++){
            (buttons[i] as! UIButton).titleLabel?.sizeToFit()
            
            let buttonTitleWidth = (buttons[i] as! UIButton).titleLabel?.frame.width
            space -= buttonTitleWidth!
        }
        
        return space / 10
    }
    
    func initButtonPosition(){
        
        let screenFrame = UIScreen.mainScreen().bounds

/*
        for (var i = 0; i < 5; i++){
            (buttons[i] as! UIButton).titleLabel?.sizeToFit()
        }
*/
        
        var basePos = CGPointZero
        basePos.x = 0
        basePos.y = (topBarview.frame.height - newBtn.frame.size.height) / 2
        
        var arr = [3, 4, 0, 1, 2]
        for (var i = 0; i < currentIndex; i++){
            let tmp = arr[0]
            for (var j = 0; j < 4; j++){
                arr[j] = arr[j + 1]
            }
            arr[4] = tmp
        }
        
        for (var i = 0; i < 5; i++){
            let button:UIButton = buttons[arr[i]] as! UIButton
            
            button.frame = CGRectMake(basePos.x, basePos.y, screenFrame.width / 5, newBtn.frame.height)
            basePos.x += screenFrame.width / 5
        }
        
        (buttons[currentIndex] as! UIButton).selected = true
    }
    
    func adjustBesideButtonPos(firstBtn: UIButton, secondBtn: UIButton){
        secondBtn.frame = CGRectMake(firstBtn.frame.origin.x + firstBtn.frame.size.width, firstBtn.frame.origin.y, firstBtn.frame.size.width, firstBtn.frame.size.height)
    }
    
    func loadButtons(){
        
        buttons.removeAllObjects()

        buttons.addObject(newBtn)
        buttons.addObject(favoriteBtn)
        buttons.addObject(rankBtn)
        buttons.addObject(hotBtn)
        buttons.addObject(allTimeHotBtn)
        
        
        initButtonPosition()
    }
    
    func animationToCenter(curretIndex: Int, newIndex: Int, bFlag: Bool){
        if (curretIndex == newIndex){
            return
        }
        
        if (bFlag == true){
            scrollPageWithIndex(newIndex)
        }
        
        for (var i = 0; i < buttons.count; i++){
            let button: UIButton = buttons[i] as! UIButton
            animationButton(button, offset: currentIndex - newIndex)
            button.selected = false
            if (i == newIndex)
            {
                button.selected = true
            }
        }
        
        currentIndex = newIndex
    }
    
    func animationButton(button:UIButton, offset: Int){
        
        let screenFrame = UIScreen.mainScreen().bounds
        let duration = Double(offset > 0 ? offset : offset * -1) * 0.2
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseOut, animations: {
            var frame = button.frame
            frame.origin.x += CGFloat(offset) * screenFrame.width / 3
            button.frame = frame
            }, completion: nil)
    }

    func animateButtons(offset:Int, direction:Bool){
        
        let screenFrame = UIScreen.mainScreen().bounds
        
        let moveItem1:QBAnimationItem = QBAnimationItem(duration: 0.1, delay: 0, options: .CurveLinear, animations: {
            () -> Void in
            
            var offset:CGFloat = 0
            for (var i = 0; i < 5; i++){
                let rect:CGRect = (self.buttons[i] as! UIButton).frame
                if (direction == true && rect.origin.x >= screenFrame.width - rect.width - 1 && rect.origin.x <= screenFrame.width - rect.width + 1){
                    offset = rect.width
                    break
                }
                else if (direction == false && rect.origin.x >= -1 && rect.origin.x <= 1){
                    offset = rect.width
                    break
                }
            }
            
            for (var i = 0; i < 5; i++){
                var rect:CGRect = (self.buttons[i] as! UIButton).frame
                if (direction == true){
                    rect.origin.x += offset
                }
                else {
                    rect.origin.x -= offset
                }
                (self.buttons[i] as! UIButton).frame = rect
            }
        })
        let move1:QBAnimationGroup = QBAnimationGroup(items: [moveItem1])
        
        let moveItem2:QBAnimationItem = QBAnimationItem(duration: 0, delay: 0, options: .CurveLinear, animations: {
            () -> Void in
            
            var offset:CGFloat = 0
            for (var i = 0; i < 5; i++){
                let rect:CGRect = (self.buttons[i] as! UIButton).frame
                if (direction == true && rect.origin.x > screenFrame.width - rect.width / 2){
                    offset = rect.width
                    break
                }
                else if (direction == false && rect.origin.x < -(rect.width / 2)){
                    offset = rect.width
                    break
                }
            }
            
            for (var i = 0; i < 5; i++){
                var rect:CGRect = (self.buttons[i] as! UIButton).frame
                if (direction == true){
                    if (rect.origin.x > screenFrame.width - rect.width / 2)
                    {
                        rect.origin.x = 0
                    }
                }
                else {
                    if (rect.origin.x < -(rect.width / 2))
                    {
                        rect.origin.x = screenFrame.width - offset
                    }
                }
                (self.buttons[i] as! UIButton).frame = rect
            }
        })
        let move2:QBAnimationGroup = QBAnimationGroup(items: [moveItem2])
        
        let color:QBAnimationItem = QBAnimationItem(duration: 0, delay: 0.1, options: .CurveLinear, animations: {
            () -> Void in
            var arr = [3, 4, 0, 1, 2]
            for (var i = 0; i < self.currentIndex; i++){
                let tmp = arr[0]
                for (var j = 0; j < 4; j++){
                    arr[j] = arr[j + 1]
                }
                arr[4] = tmp
            }

            for (var i = 0; i < 5; i++){
                self.makeGradient(i, buttonIndex: arr[i])
            }
        })
        let colorGroup = QBAnimationGroup(item: color)
    
        var animationArray:[QBAnimationGroup] = [QBAnimationGroup]()
        for (var i = 0; i < offset; i++){
            animationArray.append(move1)
            animationArray.append(move2)
            animationArray.append(colorGroup)
        }
        
        let sequence:QBAnimationSequence = QBAnimationSequence(animationGroups: animationArray, repeat: false)
        sequence.start()
    }
    
    func makeGradient(index:Int, buttonIndex:Int){
        let button:UIButton = buttons[buttonIndex] as! UIButton
        if (index == 0 || index == 4){
            button.titleLabel?.textColor = UIColor(white: 1.0, alpha: 0.3)
        }
        else if (index == 1 || index == 3){
            button.titleLabel?.textColor = UIColor(white: 1.0, alpha: 0.6)
        }
        else {
            button.titleLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        
        if (scrollView != self.scrollView)
        {
            return
        }
        
        let pageWidth = scrollView.frame.size.width
        let contentoffsetX = scrollView.contentOffset.x
        var page = Int((contentoffsetX - pageWidth / 2) / pageWidth) + 1
        
        
        if (scrollView.contentOffset.x < pageWidth / 2){
            page = 0
        }
        
        var bEnd = false
        
        if (currentIndex == 4 && scrollView.contentOffset.x <= pageWidth + 10){
            page = 0
            bEnd = true
        }
        else if (currentIndex == 0 && scrollView.contentOffset.x >= pageWidth * 3 - 10){
            page = 4
            bEnd = true
        }
        
        
        if (page != currentIndex){
            newIndex = page
            
            var arr = [3, 4, 0, 1, 2]
            for (var i = 0; i < currentIndex; i++){
                let tmp = arr[0]
                for (var j = 0; j < 4; j++){
                    arr[j] = arr[j + 1]
                }
                arr[4] = tmp
            }
            
            var virtualIndex = 0
            for (var i = 0; i < 5; i++){
                if (arr[i] == newIndex){
                    virtualIndex = i
                }
            }
            
            let offset = abs(virtualIndex - 2)
            let direction = virtualIndex < 2
            
            animateButtons(offset, direction: direction)
            
            for (var i = 0; i < 5; i++){
                (buttons[i] as! UIButton).selected = false
            }
            
            (buttons[newIndex] as! UIButton).selected = true
            
            
            // Enable scroll to top in each tableview
            (tableArray[currentIndex] as! UITableView).scrollsToTop = false
            (tableArray[newIndex] as! UITableView).scrollsToTop = true
            
            currentIndex = newIndex
            
            if (bEnd == true){
                scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.width * CGFloat(currentIndex), 0, scrollView.frame.width, scrollView.frame.height), animated: false)
            }
            
            self.type = newIndex
            if (self.loadingFlag[newIndex] == 0){
                self.page[self.type] = 1
                self.dataArray[self.type] = NSMutableArray()
                self.loadData(newIndex)
                (tableArray[newIndex] as! UITableView).reloadData()
                self.loadingFlag[newIndex] = 1
                self.stopLoading[self.type] = false
                self.currentDataCount[self.type] = 0
            }
        }
    }
    
    
    
    func scrollPageWithIndex(pageIndex:Int){
        if (pageIndex >= 5 || pageIndex < 0){
            return
        }
        
        let mainScreen = UIScreen.mainScreen().bounds
        
        var scrollToRect:CGRect = CGRect(x: 0, y: 0, width: mainScreen.width, height: scrollView.frame.height)
        scrollToRect.origin.x = CGFloat(pageIndex) * mainScreen.width
        scrollView.scrollRectToVisible(scrollToRect, animated: true)
        
        currentIndex = pageIndex
    }
    
    
    @IBAction func swipeHandle(sender: UISwipeGestureRecognizer) {
        var index = 0
        if (sender.direction == .Left){
            index = (currentIndex == 4) ? 0 : currentIndex + 1
        }
        else if (sender.direction == .Right){
            index = (currentIndex == 0) ? 4 : currentIndex - 1
        }
        
        self.tabBarButtonClicked(buttons[index])
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let frame = scrollView.frame
        if (scrollView.contentOffset.x < 0){
            
            scrollView.scrollRectToVisible(CGRectMake(frame.width * 4, 0, frame.width, frame.height), animated: false)
        }
        else if (scrollView.contentOffset.x > frame.width * 4){
            scrollView.scrollRectToVisible(CGRectMake(0, 0, frame.width, frame.height), animated: false)
        }
    }
    
    func changeButtonState(tbIndex:Int, rIndex:NSIndexPath, key:String, value:String){
        let data:NSMutableDictionary = NSMutableDictionary(dictionary: dataArray[tbIndex][rIndex.row] as! [NSObject : AnyObject])
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
            dataArray[tbIndex].replaceObjectAtIndex(rIndex.row, withObject: newData)
        }
        
        (tableArray[tbIndex] as! UITableView).reloadRowsAtIndexPaths([rIndex], withRowAnimation: UITableViewRowAnimation.None)

    }
}
