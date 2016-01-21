//
//  ProfileTableViewController.swift
//  UniPub
//
//  Created by EagleWind on 1/9/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var myPostLbl: UILabel!
    @IBOutlet weak var myReplies: UILabel!
    @IBOutlet weak var settingsLbl: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Profile".localized()
        
        self.myPostLbl.text  = "My Posts".localized()
        self.myReplies.text = "My Replies".localized()
        self.settingsLbl.text = "Settings".localized()
        
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return 3
    }
}
