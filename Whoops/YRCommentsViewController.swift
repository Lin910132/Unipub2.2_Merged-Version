//
//  YRCommentsViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-7.
//  Copyright (c) 2014y YANGReal. All rights reserved.
//

import UIKit

class YRCommentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource ,YRRefreshViewDelegate ,UITextFieldDelegate,YRRefreshCommentViewDelegate,YRRefreshCommentDelegate{
    
    var tableView:UITableView?
    let identifier = "cell"
    
    var dataArray = NSMutableArray()
    var page :Int = 1
    var refreshView:YRRefreshView?
    var jokeId:String!              //jokeId即为postId
    
    var postData:NSDictionary!
    var headerView:YRJokeCell2?
    
    var sendView:YRSendComment?
    
    var refreshCommentDelete:YRRefreshCommentDelegate?
    var listController:YRMainViewController?
    var universityController:UniversityViewController?
    var postController:MyPostsViewController?
    var replyController:MyRepliesViewController?
    var category:Int = 0
    
    var tableIndex:Int = 0
    var rowIndex = NSIndexPath()
    var tapGesture:UITapGestureRecognizer?
    var oldIndexPath:NSIndexPath?
    
    var notiDetect:Bool = false
    var fromReply:Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        self.title = "Detail".localized()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem?.title = "Back".localized()
        self.navigationItem.title = "Detail".localized()
        self.sendView?.commentText.placeholder = "Write some comments".localized()
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onKeyboardWillChangeFrame:",
            name: UIKeyboardWillChangeFrameNotification,
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (self.dataArray.count > 0 && notiDetect == true){
            let lastPath:NSIndexPath = NSIndexPath(forRow: self.dataArray.count - 1, inSection: 0)
            self.tableView?.scrollToRowAtIndexPath(lastPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            self.tableView?.selectRowAtIndexPath(lastPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
            self.tableView(self.tableView!, didSelectRowAtIndexPath: lastPath)
        }
        
        if (self.fromReply == true){
            let detectGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "detectTableTouch:")
            self.view.addGestureRecognizer(detectGesture)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }

    
    /**
    键盘显示隐藏事件监听
    */
    func onKeyboardWillChangeFrame(notification: NSNotification) {
        // 1、将通知中的数据转换成NSDictionary
        let dict = NSDictionary(dictionary: notification.userInfo!);
        // 2、获取键盘最后的Frame值
        let keyboardFrame = dict[UIKeyboardFrameEndUserInfoKey]!.CGRectValue;
        // 3、获取键盘移动值
        print("keyboardFrame.origin.y \(keyboardFrame.origin.y)")
        print("self.sendView!.bounds.height \(self.sendView!.bounds.height)")
        let ty = keyboardFrame.origin.y - view.frame.height;
        
        if (ty < 0){
            tapGesture = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
            view.addGestureRecognizer(tapGesture!)
        }
        else {
            view.removeGestureRecognizer(tapGesture!)
        }
        
        
        // 4、获取键盘弹出动画事件
        let duration = dict[UIKeyboardAnimationDurationUserInfoKey] as! Double;
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.sendView!.transform = CGAffineTransformMakeTranslation(0, ty);
            self.tableView?.transform = CGAffineTransformMakeTranslation(0, ty);
        });
        
        //        键盘弹出隐藏所执行的操作数据
        //        UIKeyboardAnimationCurveUserInfoKey = 7;
        //        UIKeyboardAnimationDurationUserInfoKey = "0.25";  键盘弹出/隐藏时动画时间
        //        UIKeyboardBoundsUserInfoKey = "NSRect: {{0, 0}, {375, 258}}";
        //        UIKeyboardCenterBeginUserInfoKey = "NSPoint: {187.5, 796}";
        //        UIKeyboardCenterEndUserInfoKey = "NSPoint: {187.5, 538}";
        //        UIKeyboardFrameBeginUserInfoKey = "NSRect: {{0, 667}, {375, 258}}";
        //        UIKeyboardFrameEndUserInfoKey = "NSRect: {{0, 409}, {375, 258}}";
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.sendView!.resignFirstResponder()
    }
    
    
    func setupViews()
    {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        self.tableView = UITableView(frame:CGRectMake(0,0,width,height - 50), style:.Grouped)
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
/*
        if (self.fromReply == false){
            self.tableView!.allowsSelection = false
        }
        self.tableView!.allowsMultipleSelection = false
*/
        
        //self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        //self.tableView?.separatorColor = UIColor.redColor()
        self.tableView?.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        //var nib = UINib(nibName:"YRJokeCell", bundle: nil)
        let nib = UINib(nibName: "YRCommnentsCell", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView!)
        
        
        var arr =  NSBundle.mainBundle().loadNibNamed("YRSendComment" ,owner: self, options: nil) as Array
        self.sendView = arr[0] as? YRSendComment
        self.sendView?.delegate = self
        self.sendView?.setCurrentPostId(jokeId)
        
        self.sendView?.frame = CGRectMake(0, height - 50 , width, 50)
        self.view.addSubview(sendView!)
        
        let btn = UIBarButtonItem(image: UIImage(named: "info"), landscapeImagePhone: UIImage(named: "info"), style: UIBarButtonItemStyle.Plain, target: self, action: "btnAuditClicked")
        self.navigationItem.rightBarButtonItem = btn
        
        loadPostData()
        
        //        headerView.initData()
        
        
        
        
        //        var arr =  NSBundle.mainBundle().loadNibNamed("YRRefreshView" ,owner: self, options: nil) as Array
        //        self.refreshView = arr[0] as? YRRefreshView
        //        self.refreshView!.delegate = self
        //
        //        self.tableView!.tableFooterView = self.refreshView
        
    }
    
    func loadData()
    {
        let url = FileUtility.getUrlDomain() + "comment/getCommentByPostId?postId=\(jokeId)"
        //        self.refreshView!.startLoading()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("WARNING".localized(), message: "Network error!".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
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
            //            self.refreshView!.stopLoading()
            self.page++
            
            let width = self.view.frame.size.width
            let height = self.view.frame.size.height
            self.sendView?.frame = CGRectMake(0, height - 50 , width, 50)
            if (self.fromReply == true)
            {
                self.tableView!.layoutIfNeeded()
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    // do some task
                    self.tableView!.layoutIfNeeded()
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        let lastPath:NSIndexPath = NSIndexPath(forRow: self.dataArray.count - 1, inSection: 0)
                        self.tableView?.scrollToRowAtIndexPath(lastPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                        self.tableView?.selectRowAtIndexPath(lastPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
                        self.tableView(self.tableView!, didSelectRowAtIndexPath: lastPath)
                    }
                }
            }
        })
        

        
    }
    
    func loadPostData()
    {
        let url = FileUtility.getUrlDomain() + "post/get?id=\(self.jokeId)&uid=\(FileUtility.getUserId())"
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                return
            }
            
            
            
//            var arrHeader =  NSBundle.mainBundle().loadNibNamed("YRJokeCell" ,owner: self, options: nil) as Array
            
            self.headerView = YRJokeCell2(style: .Default, reuseIdentifier: "cell")
            let post = data["data"] as! NSDictionary
            self.headerView?.data = post
            self.headerView?.bInMain = true
            self.headerView?.category = self.category
            self.headerView?.rowIndex = self.rowIndex
            self.headerView?.tableIndex = self.tableIndex
            self.headerView?.mainController = self.listController
            self.headerView?.postViewController = self.postController
            self.headerView?.replyController = self.replyController
            self.headerView?.universityController = self.universityController
            self.headerView?.setCellUp()
            self.headerView?.frame = CGRectMake(0, 0, self.view.frame.size.width,YRJokeCell2.cellHeightByData(post))
            self.headerView?.backgroundColor = UIColor(red:246.0/255.0 , green:246.0/255.0 , blue:246.0/255.0 , alpha: 1.0);
            
            self.tableView!.tableHeaderView = self.headerView
            self.headerView?.refreshCommentDelegate = self
        })
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.dataArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? YRJokeCell
        var cell : YRCommnentsCell? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRCommnentsCell
        if cell == nil {
            cell = YRCommnentsCell(style: .Default, reuseIdentifier: identifier)
        }
        
        //var cell :YRJokeCell2? = tableView.dequeueReusableCellWithIdentifier(identifier) as? YRJokeCell2
        //if cell == nil{
        //    cell = YRJokeCell2(style: .Default, reuseIdentifier: identifier)
        //}
        
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        cell!.data = data
        
//        cell!.selectionStyle = UITableViewCellSelectionStyle.Blue
        cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
        cell!.backgroundColor = UIColor.whiteColor();
        let selectedview = UIView()
        selectedview.backgroundColor = UIColor.grayColor()
        cell?.selectedBackgroundView = selectedview
        return cell!
    }
    
    //    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
    //
    //
    //    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        return  YRCommnentsCell.cellHeightByData(data)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        return true
    }
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        //refreshView.startLoading()
        loadData()
    }
    
    
    func refreshCommentView(refreshView:YRSendComment,didClickButton btn:UIButton){
        self.dataArray = NSMutableArray()
        loadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func btnAuditClicked(){
        let alertView = UIAlertView()
        alertView.title = "Report".localized()
        alertView.message = "This post violate Unipub's regulation!".localized()
        alertView.addButtonWithTitle("No".localized())
        alertView.addButtonWithTitle("Yes".localized())
        alertView.cancelButtonIndex = 0
        alertView.delegate = self
        alertView.show()
        
    }
    
    func refreshCommentByFavor(){
        loadPostData()
    }

    
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int){
        if buttonIndex != alertView.cancelButtonIndex{
            let url = FileUtility.getUrlDomain() + "post/reportPost?postId=\(self.jokeId)&uid=\(FileUtility.getUserId())"
            
            YRHttpRequest.requestWithURL(url,completionHandler:{ data in
                
                if data as! NSObject == NSNull()
                {
                    UIView.showAlertView("Alert".localized(), message: "Loading Failed".localized())
                    return
                }
                
                UIView.showAlertView("Alert".localized(),message: "Report success".localized())
                
            })
            
        }
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:YRCommnentsCell = tableView.cellForRowAtIndexPath(indexPath) as! YRCommnentsCell
        sendView?.commentText.placeholder = "Reply to: " + cell.contentLabel.text!
        sendView?.commentId = "\(indexPath.row)"
        oldIndexPath = indexPath
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        sendView?.commentText.placeholder = "Write some comments"
        sendView?.commentId = ""
        oldIndexPath = nil
    }
    
    func detectTableTouch(tap:UITapGestureRecognizer){
        let pos = tap.locationInView(self.tableView)
        let indexPath = self.tableView?.indexPathForRowAtPoint(pos)
        if (indexPath != nil){
            let cell:YRCommnentsCell = self.tableView?.cellForRowAtIndexPath(indexPath!) as! YRCommnentsCell
            if (cell.selected != true){
                if (oldIndexPath != nil){
                    self.tableView?.deselectRowAtIndexPath(oldIndexPath!, animated: true)
                    self.tableView(self.tableView!, didDeselectRowAtIndexPath: oldIndexPath!)
                }
                self.tableView?.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
                self.tableView(self.tableView!, didSelectRowAtIndexPath: indexPath!)
            }
            else{
                self.tableView?.deselectRowAtIndexPath(indexPath!, animated: true)
                self.tableView(self.tableView!, didDeselectRowAtIndexPath: indexPath!)
            }
        }
        else {
            if (oldIndexPath != nil){
                self.tableView?.deselectRowAtIndexPath(oldIndexPath!, animated: true)
                self.tableView(self.tableView!, didDeselectRowAtIndexPath: oldIndexPath!)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.category == 1){
            self.listController?.fromDetail = true
        }
    }
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
