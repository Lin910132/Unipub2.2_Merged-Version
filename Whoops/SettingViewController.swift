//
//  SettingViewController.swift
//  UniPub
//
//  Created by Li Jiatan on 8/18/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit
import Localize_Swift

class SettingViewController: UITableViewController {
    
    @IBOutlet weak var votingLbl: UILabel!
    @IBOutlet weak var rightLeftSegControll: UISegmentedControl!
    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var privacyPolicyLbl: UILabel!
    @IBOutlet weak var rulesInfoLbl: UILabel!
    @IBOutlet weak var termsOfServiceLbl: UILabel!
    
    
    
    
    
    
    let segItems = ["Left", "Right"]
    
    override func viewWillAppear(animated: Bool) {
        //self.votingLbl.text = "Voting".localized()
        //self.rightLeftSegControll.setTitle("Left".localized(), forSegmentAtIndex: 0)
        //self.rightLeftSegControll.setTitle("Right".localized(), forSegmentAtIndex: 1)
        self.languageLbl.text = "Language".localized()
        self.privacyPolicyLbl.text = "Privacy Policy".localized()
        self.rulesInfoLbl.text = "Rules & Info".localized()
        self.termsOfServiceLbl.text = "Terms of Service".localized()
        
        clearsSelectionOnViewWillAppear = true
        
        self.navigationItem.title = "Settings".localized()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SettingViewController.goBackBtn))
        
    }
    
    
    func goBackBtn(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    @IBAction func facebookLink(sender: AnyObject) {
        //let url = NSURL(string: "http://www.facebook.com/whoop.hopkins")
        let url = NSURL(string: "fb://profile/100009359472896")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/hopkinswhoop/")!)
        }
    }
    
    @IBAction func WeChatButtonClick(sender: AnyObject) {
        let url = NSURL(string: "weixin://weixin.qq.com/r/YkjO1jTEk2nsrXC19x1w")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://weixin.qq.com/r/YkjO1jTEk2nsrXC19x1w")!)
        }
    }
    
    @IBAction func InsButtonClick(sender: AnyObject) {
        
        let url = NSURL(string: "instagram://user?username=Unipub")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.instagram.com/unipub/")!)
        }
    }
    
    @IBAction func WeiBoButtonClick(sender: AnyObject) {
        let url = NSURL(string: "weibo://")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
        else {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.weibo.com/")!)
        }
    }
    
    @IBAction func renrenLink(sender: AnyObject) {
        //if let url = NSURL(string: "http://page.renren.com/602116917") {
        //    UIApplication.sharedApplication().openURL(url)
        //}
        let renrenHooks = "renren://profile/602116917"
        let renrenUrl = NSURL(string: renrenHooks)
        if UIApplication.sharedApplication().canOpenURL(renrenUrl!)
        {
            UIApplication.sharedApplication().openURL(renrenUrl!)
            
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://page.renren.com/602116917")!)
        }
    }
   
}
