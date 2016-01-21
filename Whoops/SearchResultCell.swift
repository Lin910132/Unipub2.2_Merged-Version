//
//  SearchResultCell.swift
//  Whoops
//
//  Created by Li Jiatan on 3/5/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit

protocol YRRefreshSearchViewDelegate
{
    
    func refreshSearchView()
}

class SearchResultCell: UITableViewCell {
    var isHighLighted = Bool()
    var flag = true
    var currentIndex = Int()
    var favorite = []
    var data = NSDictionary()
    var schoolId = String()
    var uid = String()
    
    var delegate:YRRefreshSearchViewDelegate?
    
    @IBOutlet weak var frontImg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeBtnSelected(sender: UIButton) {
        
        dispatch_async(dispatch_get_main_queue(),{
            if self.isHighLighted == false
            {
                let location =  self.data.stringAttributeForKey("longitude")
                if location != "" {
                    self.schoolId = self.data.stringAttributeForKey("id")
                } else
                {
                    self.schoolId = self.data.stringAttributeForKey("schoolId")
                }
                
                let url = "http://104.131.91.181:8080/whoops/favorSchool/add?uid=\(self.uid)&schoolId=\(self.schoolId)"
                self.flag = true
                YRHttpRequest.requestWithURL(url,completionHandler:{ data in
                    
                    if data as! NSObject == NSNull()
                    {
                        UIView.showAlertView("WARNING".localized(), message: "Failed".localized())
                        return
                    }
                    
                    self.delegate!.refreshSearchView()
                    
                })
                
                self.isHighLighted = true
                self.likeButton.setImage(UIImage(named: "Like"), forState: UIControlState.Normal)
                //self.deleg
                
            }
            else
            {
                self.schoolId = self.data.stringAttributeForKey("schoolId")
                if self.schoolId == "" {
                    self.schoolId = self.data.stringAttributeForKey("id")
                }
                let url = "http://104.131.91.181:8080/whoops/favorSchool/delete?uid=\(self.uid)&schoolId=\(self.schoolId)"
                self.flag = true
                
                YRHttpRequest.requestWithURL(url,completionHandler:{ data in
                    
                    if data as! NSObject == NSNull()
                    {
                        UIView.showAlertView("WARNING".localized(), message:"Failed".localized())
                        return
                    }
                    
                    self.delegate!.refreshSearchView()
                })
                
                self.isHighLighted = false
                self.likeButton.setImage(UIImage(named: "115"), forState: UIControlState.Normal)
            }
            
            
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
