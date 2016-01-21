//
//  UIViewControllerExt.swift
//  Whoop
//
//  Created by alidao3 on 15/4/9.
//  Copyright (c) 2015y Li Jiatan. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {
    func viewDidLoadForChangeTitleColor() {
        self.viewDidLoadForChangeTitleColor()
        if self.isKindOfClass(UINavigationController.classForCoder()) {
            self.changeNavigationBarTextColor(self as! UINavigationController)
        }
    }
    
    func changeNavigationBarTextColor(navController: UINavigationController) {
        let nav = navController as UINavigationController
        let dic = NSDictionary(object: UIColor.whiteColor(),
            forKey:NSForegroundColorAttributeName)
        nav.navigationBar.titleTextAttributes = dic as? [String : AnyObject]
        nav.navigationBar.barTintColor = UIColor.applicationMainColor()
        nav.navigationBar.tintColor = UIColor.whiteColor()
        nav.navigationBar.backgroundColor=UIColor.applicationMainColor();
        
    } 
    
}