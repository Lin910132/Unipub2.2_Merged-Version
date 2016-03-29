//
//  LanguageSettingTableViewController.swift
//  UniPub
//
//  Created by EagleWind on 1/6/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import UIKit
import Localize_Swift


var selectedLang: String!
var deviceLang: String!
var appLangs = ["en","zh-Hans","zh-Hant"]


/////////////
//struct AlertString {
//    struct Title {
//        static let Opps = NSLocalizedString("Opps".localized(), comment: "Surprised to occurd")
//        static let notEmailed = NSLocalizedString("Could Not Send Email".localized(), comment: "Could Not Send Email")
//        static let Alert = NSLocalizedString("Alert".localized(), comment: "Alert")
//        static let OppsT = NSLocalizedString("Opps".localized(), comment: "Opps")
//        static let Report = NSLocalizedString("Report".localized(), comment: "Report")
//        static let WarningNE = NSLocalizedString("WARNING".localized(), comment: "Warning")
//        static let WarningM6 = NSLocalizedString("WARNING".localized(), comment: "Warning")
//    }
//    struct Message{
//        static let Opps = NSLocalizedString("Loading Failed".localized(), comment: "Loading Failed")
//        static let notEmailed = NSLocalizedString("Your device could not send e-mail.  Please check e-mail configuration and try again.".localized(), comment: "Not Emailed Response")
//        static let AlertRF = NSLocalizedString("Refresh Failed".localized(), comment: "Refresh Failed")
//        static let AlertLF = NSLocalizedString("Loading Failed".localized(), comment: "Loading Failed")
//        static let AlertRS = NSLocalizedString("Report success".localized(), comment: "Report success")
//        static let OppsT = NSLocalizedString("No more Comments T_T".localized(), comment: "No more Comments T_T")
//        static let reportMsg = NSLocalizedString("This post violate Unipub's regulation!".localized(), comment: "Checking Report")
//        static let WarningNE = NSLocalizedString("Network error!".localized(), comment: "Network error!")
//        static let WarningNNE = NSLocalizedString("No Network Access".localized(), comment: "No Network Access")
//        static let WarningM6 = NSLocalizedString("The max count of photos can not be more than 6".localized(), comment: "Length Error")
//        static let WarningEm = NSLocalizedString("The Content should not be empty".localized(), comment: "The Content should not be empty")
//        static let failedMsg = NSLocalizedString("Failed".localized(), comment: "Failed")
//        
//        
//        
//    }
//    
//    static let cancelBtn = NSLocalizedString("Cancel".localized(), comment: "Cancel")
//    static let okBtn = NSLocalizedString("OK".localized(), comment: "OK")
//    static let yesBtn = NSLocalizedString("Yes".localized(), comment: "Yes")
//    static let noBtn = NSLocalizedString("No".localized(), comment: "No")
//    static let photoStr = NSLocalizedString("Photo".localized(), comment: "Photo")
//    static let DetailStr = NSLocalizedString("Detail".localized(), comment: "Detail")
//    static let reloadingStr = NSLocalizedString("Reloading".localized(), comment: "Reloading")
//    static let writeSomeThing = NSLocalizedString("Write something".localized(), comment: "Write something")
//    static let cameraStr = NSLocalizedString("Camera".localized(), comment: "Camera")
//    static let photoLib = NSLocalizedString("Photo Library".localized(), comment: "Photo Library")
//    static let Selected = NSLocalizedString("Selected".localized(), comment: "Selected")
//    static let searchText = NSLocalizedString("Search your School".localized(), comment: "Search your School")
//    static let myFavorite = NSLocalizedString("My Favorite".localized(), comment: "My Favorite")
//    static let nearBy = NSLocalizedString("Near By".localized(), comment: "Nearby")
//    static let unKnown = NSLocalizedString("Unknown".localized(), comment: "Unknown")
//    static let replyStr = NSLocalizedString("Reply".localized(), comment: "One Reply")
//    static let repliesStr = NSLocalizedString("Replies".localized(), comment: "Several ")
//    static let NickNameClicked = NSLocalizedString("I'm interest in your post in Whoop, that ".localized(), comment: "Nick Name Clicked")
//    static let NickNameClickedTwo = NSLocalizedString("Hi, I'm interest in your post in Whoop, that".localized(), comment: "Nick Name Clicked in YRJokeCell2.swift")
//    static let clickToLoadMore = NSLocalizedString("Click to load more".localized(), comment: "Click to load more")
//    static let dragToLoadMore = NSLocalizedString("Drag to Load More".localized(), comment: "Drag to Load More")
//    static let pullToLoadMore = NSLocalizedString("Pull to Load More".localized(), comment: "Pull to Load More")
//    static let refreshSuccess = NSLocalizedString("Refresh Success".localized(), comment: "Refresh Success")
//    static let refreshFailed = NSLocalizedString("Refresh Failed".localized(), comment: "Refresh Failed")
//    static let loading = NSLocalizedString("Loading".localized(), comment: "Loading")
//    static let loadingCompleted = NSLocalizedString("Loading Completed".localized(), comment: "Loading Conmpleted")
//    static let releaseToRefresh = NSLocalizedString("Release to refresh".localized(), comment: "release to refresh")
//    
//    
//}
extension String {
    func localized(lang:String) ->String {
        
//        let path = NSBundle.mainBundle().pathForResource(lang, ofType: "lproj")
        let path = "/Users/eaglewind/Desktop/DannyKan's Project/Updated/whoop-master/\(lang).lproj"
        
        let bundle = NSBundle(path: path)
       
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
//////////////////////

class LanguageSettingTableViewController: UITableViewController {

    
    
    let myLang: [String] = ["English(US)","简体中文","繁體中文"]

    let userDefaults = NSUserDefaults.standardUserDefaults()

    var lang: String!
    var iIndex: Int!
    var lastSelectedIndexPath: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lang = Localize.currentLanguage()
        self.iIndex = appLangs.indexOf(lang)
        self.lastSelectedIndexPath = iIndex
        self.setLang()
    }
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LanguageSettingTableViewController.setLang), name: LCLLanguageChangeNotification, object: nil)
        
    }
    
    func goBackBtn(){
//        let viewSetting = self.storyboard?.instantiateViewControllerWithIdentifier("viewSetting") as! SettingViewController
//        self.navigationController?.pushViewController(viewSetting, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setLang(){
        self.navigationItem.title = "Language Setting".localized()
        self.tableView.reloadData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .Plain, target: self, action: #selector(LanguageSettingTableViewController.goBackBtn))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("langCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.myLang[indexPath.row]
        if self.lastSelectedIndexPath == indexPath.row{
            cell.accessoryType = .Checkmark
            cell.detailTextLabel!.text = "Selected".localized()
        }else{
            cell.accessoryType = .None
            cell.detailTextLabel!.text = nil
        }

        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark
            {
                cell.accessoryType = .None
                tableView.reloadData()
            }
            else
            {
                
                cell.accessoryType = .Checkmark
                lastSelectedIndexPath = indexPath.row
                switch indexPath.row{
                case 0:
                    selectedLang = appLangs[indexPath.row]
                case 1:
                    selectedLang = appLangs[indexPath.row]
                case 2:
                    selectedLang = appLangs[indexPath.row]
                default:
                    selectedLang = appLangs[0]
                }
                Localize.setCurrentLanguage(selectedLang)
                
            }
        }
    }
}
