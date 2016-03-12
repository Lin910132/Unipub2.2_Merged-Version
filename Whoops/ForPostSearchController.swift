//
//  ForPostSearchController.swift
//  UniPub
//
//  Created by POK on 3/11/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import Foundation
import CoreLocation
import Localize_Swift




class ForPostSearchController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating,YRRefreshViewDelegate,YRRefreshSearchViewDelegate, CLLocationManagerDelegate{
    
    
    
    @IBOutlet weak var searchTableView: UITableView!
    var _db = NSMutableArray()
    var myFavorite = NSMutableArray()
    var nearby = NSMutableArray()
    var filteredTableData = []
    var dbUrl = String()
    var nearbyUrl = String()
    var myFavoriteUrl = String()
    var resultSearchController = UISearchController()
    var refreshView: YRRefreshView?
    //var sendFavorite:YRSendComment?
    var flag: Bool = false
    
    let locationManager = CLLocationManager()
    var uid = String()
    var lat = Double()
    var lng = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: I changed
        self.navigationController?.navigationBarHidden = false
        
        //add background to status bar
        let modalView:UIView = UIView(frame: CGRectMake(0 , 0, self.view.frame.width, UIApplication.sharedApplication().statusBarFrame.height+2))
        modalView.backgroundColor = UIColor(netHex: 0x2E8BD1)
        self.view.addSubview(modalView)
        
        // Get location begins
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            self.flag = true
            locationManager.requestWhenInUseAuthorization()
        } else {
            self.flag = true
            locationManager.startUpdatingLocation()
        }
        //Get location Ends
        
        self.uid = FileUtility.getUserId()
        self.dbUrl = "http://104.131.91.181:8080/whoops/school/getAll"
        //self.nearbyUrl = "http://104.131.91.181:8080/whoops/school/listSchoolByLocation?latitude=\(self.lat)&longitude=\(self.lng)"
        self.myFavoriteUrl = "http://104.131.91.181:8080/whoops/favorSchool/listByUid?uid=\(self.uid)"
        
        self.searchTableView.reloadData()
        
        //loadDB(nearbyUrl, target: nearby)
        loadDB(dbUrl, target: _db)
        loadDB(myFavoriteUrl, target: myFavorite)
        
        //if (_db == NSNull()){
        //    UIView.showAlertView("Opps".localized(),message: "No School Nearby".localized())
        //}
        
        var arr =  NSBundle.mainBundle().loadNibNamed("YRRefreshView" ,owner: self, options: nil) as Array
        self.refreshView = arr[0] as? YRRefreshView
        self.refreshView?.delegate = self
        self.addRefreshControl()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        SchoolObject.schoolId = "0"
        SchoolObject.schoolName = ""
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.searchBar.barTintColor = UIColor(netHex: 0x3593DD)
            controller.searchBar.tintColor = UIColor.whiteColor()
            let textfield = controller.searchBar.valueForKey("_searchField") as? UITextField
            textfield?.backgroundColor = UIColor(netHex: 0x2E8BD1)
            //textfield?.backgroundColor = UIColor.blackColor()
            textfield?.textColor = UIColor.whiteColor()
            textfield?.tintColor = UIColor.whiteColor()
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            textfield?.attributedPlaceholder = NSAttributedString(string: "Search your School".localized(),
                attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
            //
            //            controller.searchBar.placeholder = "Search your School"
            self.searchTableView.tableHeaderView = controller.searchBar
            //            self.searchTableView.tableHeaderView?.backgroundColor = UIColor(netHex: 0x3593DD)
            self.navigationController?.navigationBarHidden = false
            return controller
        })()
        
        
        self.searchTableView.reloadData()
        
        //        let titleStr = self.navigationItem.title! as String
        print(Localize.currentLanguage(), "Select a School to Post".localized())
        self.navigationItem.title = "Select a School to Post".localized()
        self.navigationController?.navigationBarHidden = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("get location")
        
        if self.flag {
            self.flag = false
            let location:CLLocation = locations[locations.count-1]
            self.nearby.removeAllObjects()
            if (location.horizontalAccuracy > 0) {
                self.lat = location.coordinate.latitude
                self.lng = location.coordinate.longitude
                self.nearbyUrl = "http://104.131.91.181:8080/whoops/school/listSchoolByLocation?latitude=\(self.lat)&longitude=\(self.lng)"
                
                //self.nearby.removeAllObjects()
                loadDB(nearbyUrl, target: nearby)
                
                self.locationManager.stopUpdatingLocation()
                //println(location.coordinate)
                
                //println("latitude \(location.coordinate.latitude) longitude \(location.coordinate.longitude)")
            }
        } else {return}
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        //        self.textLabel.text = "get location error"
    }
    
    func addRefreshControl(){
        
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "actionRefreshHandler:", forControlEvents: UIControlEvents.ValueChanged)
        refresh.tintColor = UIColor.whiteColor()
        self.searchTableView.addSubview(refresh)
    }
    
    func actionRefreshHandler(sender: UIRefreshControl)
    {
        
        let url = "http://104.131.91.181:8080/whoops/school/listSchoolByLocation?latitude=\(self.lat)&longitude=\(self.lng)"
        self.nearby.removeAllObjects()
        
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Opps".localized(),message: "No School Nearby".localized())
                sender.endRefreshing()
                return
            }
            
            let arr = data["data"] as! NSArray
            
            for data : AnyObject  in arr
            {
                self.nearby.addObject(data)
            }
            self.searchTableView.reloadData()
            sender.endRefreshing()
        })
    }
    
    
    func refreshSearchView(){
        
        self.myFavorite.removeAllObjects()
        self.nearby.removeAllObjects()
        loadDB(myFavoriteUrl, target: myFavorite)
        loadDB(nearbyUrl, target: nearby)
        //self.refreshView!.stopLoading()
        
    }
    
    func refreshView(refreshView:YRRefreshView,didClickButton btn:UIButton)
    {
        
    }
    
    
    func loadDB(url:String, target: NSMutableArray)
    {
        //if target === self.myFavorite {self.myFavorite.removeAllObjects()}
        
        //There is an empty string coming in, and I don't know why
        if (url == ""){
            return
        }
        
        target.removeAllObjects()
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                UIView.showAlertView("Alert".localized(),message: "No Network Access".localized())
                return
            }
            
            let arr = data["data"] as! NSArray
            
            for data : AnyObject  in arr
            {
                target.addObject(data)
            }
            self.searchTableView.reloadData()
            // self.refreshView!.stopLoading()
            //self.page++
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.resultSearchController.active
        {
            return 1
        }else
        {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.resultSearchController.active
        {
            return self.filteredTableData.count
        }
        else
        {
            switch (section){
            case 0: return self.myFavorite.count
            case 1: return self.nearby.count
            default: return 0
            }
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headCell = tableView.dequeueReusableCellWithIdentifier("headCell") as! SearchHeadCell
        headCell.backgroundView = nil
        
        if self.resultSearchController.active
        {
            return headCell
        }
        else
        {
            switch (section){
            case 0: headCell.header.text = "My Favorite".localized()
            headCell.headImg.image = UIImage(named: "Like")
            case 1: headCell.header.text = "Near By".localized()
            headCell.headImg.image = UIImage(named: "Nearby")
            default: headCell.header.text = nil
            headCell.headImg.image = nil
            }
            
        }
        return headCell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  self.resultSearchController.active {return 0}
        else { return 50}
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResult") as! SearchResultCell
        let row = indexPath.row
        cell.currentIndex = indexPath.row
        cell.delegate = self
        var isLike : Bool = false
        
        if self.resultSearchController.active
        {
            //let myFavoriteUrl = "http://104.131.91.181:8080/whoops/favorSchool/listByUid?uid=\(self.uid)"
            //loadDB(myFavoriteUrl, target: self.myFavorite)
            let data = self.filteredTableData[row] as! NSDictionary
            cell.title.text = data.stringAttributeForKey("nameEn")
            //cell.title.text = self.filteredTableData[row]
            cell.data = data
            cell.uid = self.uid
            
            cell.isHighLighted = false
            cell.backgroundView = nil
            cell.backgroundColor = UIColor.clearColor()
            //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            for (var i = 0; i < self.myFavorite.count; i++){
                let item = myFavorite[i] as! NSDictionary
                
                if (item.stringAttributeForKey("nameEn") == data.stringAttributeForKey("nameEn")){
                    isLike = true;
                    break;
                }
            }
            
            if isLike {
                cell.likeButton.setImage(UIImage(named: "Like"), forState: UIControlState.Normal)
            }else{
                cell.likeButton.setImage(UIImage(named: "SearchLike"), forState: UIControlState.Normal)
            }
            
            cell.frontImg.image = UIImage(named: "frontImg")
            return cell
        }
        else
        {
            if indexPath.section == 0
            {
                cell.favorite = self.myFavorite
                //cell.title.text = self.myFavorite[row]
                let data = self.myFavorite[row] as! NSDictionary
                cell.title.text = data.stringAttributeForKey("nameEn")
                cell.data = data
                //cell.uid = FileUtility.getUserId()
                cell.uid = self.uid
                
                cell.isHighLighted = true
                cell.backgroundView = nil
                cell.backgroundColor = UIColor.clearColor()
                //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                //if cell.flag {
                //    loadDB(myFavoriteUrl, target: myFavorite)
                //    self.searchTableView.reloadData()
                //    cell.flag = false
                //}
                
                cell.likeButton.setImage(UIImage(named: "Like"), forState: UIControlState.Normal)
                cell.frontImg.image = UIImage(named: "frontImg")
                return cell
            }
            
            if indexPath.section == 1
            {
                //cell.title.text = self.nearby[row]
                let data = self.nearby[row] as! NSDictionary
                cell.title.text = data.stringAttributeForKey("nameEn")
                cell.data = data
                //cell.uid = FileUtility.getUserId()
                cell.uid = self.uid
                
                //if cell.flag{
                //    self.searchTableView.reloadData()
                //    cell.flag = false
                //}
                
                cell.isHighLighted = false
                cell.backgroundView = nil
                cell.backgroundColor = UIColor.clearColor()
                //cell.tailImg.image = UIImage(named: "115")
                //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
                for (var i = 0; i < self.myFavorite.count; i++){
                    let item = myFavorite[i] as! NSDictionary
                    
                    if (item.stringAttributeForKey("nameEn") == data.stringAttributeForKey("nameEn")){
                        isLike = true;
                        break;
                    }
                }
                
                if isLike {
                    cell.likeButton.setImage(UIImage(named: "Like"), forState: UIControlState.Normal)
                }else{
                    cell.likeButton.setImage(UIImage(named: "SearchLike"), forState: UIControlState.Normal)
                }
                
                cell.frontImg.image = UIImage(named: "frontImg")
                return cell
            }
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if self.resultSearchController.active{
            let cell:SearchResultCell = tableView.cellForRowAtIndexPath(indexPath) as! SearchResultCell
            let title = cell.title.text
            
            self.resultSearchController.dismissViewControllerAnimated(false, completion: {
                let navController:UINavigationController = self.navigationController?.presentingViewController as! UINavigationController
                let postcontroller:YRNewPostViewController = navController.topViewController as! YRNewPostViewController
                postcontroller.schoolName = title!
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
        }
        else {
            if (indexPath.section == 1){
                let cell:SearchResultCell = tableView.cellForRowAtIndexPath(indexPath) as! SearchResultCell
                let title = cell.title.text
                let navController:UINavigationController = self.navigationController?.presentingViewController as! UINavigationController
                let postcontroller:YRNewPostViewController = navController.topViewController as! YRNewPostViewController
                postcontroller.schoolName = title!
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        
        let searchPredicateCn = NSPredicate(format: "(nameCn contains[cd] %@)", searchController.searchBar.text!)
        let searchPredicateEn = NSPredicate(format: "(nameEn contains[cd] %@)", searchController.searchBar.text!)
        let searchPredicateAbbr = NSPredicate(format: "(nameAbbr contains[cd] %@)", searchController.searchBar.text!)
        
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [searchPredicateCn, searchPredicateEn, searchPredicateAbbr])
        
        let array = _db.filteredArrayUsingPredicate(predicate)
        
        filteredTableData = array
        self.searchTableView.reloadData()
    }
}
