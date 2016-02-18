//
//  MyUITabBarController.swift
//  Whoop
//
//  Created by alidao3 on 15/4/9.
//  Copyright (c) 2015y Li Jiatan. All rights reserved.
//

import UIKit
import Foundation

class MyUITabBarController: UITabBarController, UITabBarControllerDelegate{
    
    var oldSelectedIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.backgroundColor = UIColor.applicationTabBarColor();
        self.tabBar.barTintColor=UIColor.whiteColor()
        
        self.tabBar.tintColor = UIColor.applicationMainColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeUpdate:", name: "newLike", object: nil);

        
        //
        // set red as selected background color
        let numberOfItems = CGFloat(tabBar.items!.count)
        let tabBarItemSize = CGSize(width: tabBar.frame.width / numberOfItems, height: self.tabBar.frame.height)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(UIColor(red: 53/255, green: 147/255, blue: 221/255, alpha: 1), size: tabBarItemSize).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 6
        tabBar.frame.origin.x = -5
        
        //
        let itemIndex = 2
        let bgColor = UIColor(red: 53/255, green: 147/255, blue: 221/255, alpha: 1)
        
        let itemWidth = tabBar.frame.width / CGFloat(tabBar.items!.count)
        let bgView = UIView(frame: CGRectMake(itemWidth * CGFloat(itemIndex), 0, itemWidth, tabBar.frame.height+6))
        bgView.backgroundColor = bgColor
        tabBar.insertSubview(bgView, atIndex: 0)
        
        self.configTabBar();
    }
    
    func badgeUpdate(aNot:NSNotification){
        let tabItem = self.tabBar.items![3];
        let badgeString = aNot.userInfo!["badgeNumber"] as! String
        let badgeNumber: Int64? = Int64 (badgeString)
        
        if (badgeNumber >= 10){
            tabItem.badgeValue = badgeString + "+"
        }else{
            tabItem.badgeValue = badgeString
        }
        
    }
    
    
    func configTabBar() {
        let items = self.tabBar.items
        var iIndex: Int = 0
        let imageName = ["Home","Search","Post","LikeB","Profile"]
        for item in items! {
            let dic = NSDictionary(object: UIColor.applicationMainColor(),
                forKey:   NSForegroundColorAttributeName)
            item.setTitleTextAttributes(dic as? [String : AnyObject],forState: UIControlState.Selected)
            // MARK: tab bar image insets
            item.image = UIImage(named: imageName[iIndex])?.imageWithRenderingMode(.AlwaysOriginal)
            iIndex++
            item.imageInsets = UIEdgeInsets(top: 7, left: 1, bottom: -5, right: 1)
            item.tag = iIndex
        }
        
    }
    
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        if (item.tag == 3){
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("postNavigation")
            
            ((vc as! UINavigationController).topViewController as! YRNewPostViewController).mainController = self
            
            //isSchool = true
            self.presentViewController(vc, animated: true, completion: nil)
            
//            let postController:YRNewPostViewController! = (self.viewControllers![2] as! UINavigationController).topViewController as! YRNewPostViewController
//            postController.mainController = self
        }
        else if (item.tag == 4){
            let uid : String = FileUtility.getUserId()
            let url = FileUtility.getUrlDomain() + "msg/getMsgByUId?uid=\(uid)"
            //var url = "http://104.131.91.181:8080/whoops/msg/getMsgByUId?uid=97&pageNum=1"
            YRHttpRequest.requestWithURL(url,completionHandler:{ data in
                
                if data as! NSObject == NSNull()
                {
                    return
                }
                
                let arr = data["data"] as! NSArray
                
                let defaults = NSUserDefaults.standardUserDefaults()
                let dataSave = NSKeyedArchiver.archivedDataWithRootObject(arr)
                defaults.setObject(dataSave, forKey: "likes")
                defaults.synchronize()
                item.badgeValue = nil
            })

        }
        else if (item.tag == 1){
            let controller:YRMainViewController = (self.viewControllers![0] as! UINavigationController).topViewController as! YRMainViewController
            controller.fromDetail = true
        }
        
        oldSelectedIndex = self.selectedIndex
    }
    

}

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, size.height-4, size.width+3, size.height-2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
