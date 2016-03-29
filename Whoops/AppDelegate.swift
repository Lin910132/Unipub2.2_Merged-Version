//
//  AppDelegate.swift
//  Whoops
//
//  Created by Li Jiatan on 2/25/15.
//  Copyright (c) 2015 Li Jiatan. All rights reserved.
//

import UIKit
import Parse
import Localize_Swift




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    
    
    


    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //MARK: - Getting the Device's language setting.
        var fstRun: Bool = false
        if !fstRun{
            let cuLang = Localize.currentLanguage()
            switch cuLang{
            case "en":
                Localize.setCurrentLanguage(cuLang)
            case "zh-Hans":
                Localize.setCurrentLanguage(cuLang)
            case "zh-Hant":
                Localize.setCurrentLanguage(cuLang)
            default:
                Localize.setCurrentLanguage("en")
            }
            fstRun = true
        }
        
        
        
        // Override point for customization after application launch.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
       // UIApplication.sharedApplication().statusBarFrame =
        swizzlingMethod(UIViewController.self,
            oldSelector: #selector(UIViewController.viewDidLoad),
            newSelector: Selector("viewDidLoadForChangeTitleColor"))
        
        Parse.setApplicationId("OEcTC65wuvGwqASgutgQDjFce3Dp0l8bhQ8hmAhs",
            clientKey: "Vm9QRZfBVb5aVHbiZs1m42nyfV4JhoyZFhRznnzs")
        
        Flurry.startSession("ZN9CB2BK8KJMCJ26S8Q5")
        Flurry.logAllPageViewsForTarget(UINavigationController)
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
           
            }
        }
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.addUniqueObject("a\(FileUtility.getUserId())", forKey: "channels")
        currentInstallation.saveInBackground()
        
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        // Language Setting Part
        
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.removeObjectForKey("likes");
        
        let myTimer = NSTimer(timeInterval: 1, target: self, selector: #selector(AppDelegate.timerDidFire), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(myTimer, forMode: NSRunLoopCommonModes)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let tabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBarId") as! MyUITabBarController
//        tabBarController.delegate = self;

        return true
    }
    
    func timerDidFire() {
        let uid : String = FileUtility.getUserId()
        let url = FileUtility.getUrlDomain() + "msg/getMsgByUId?uid=\(uid)"
        //var url = "http://104.131.91.181:8080/whoops/msg/getMsgByUId?uid=97&pageNum=1"
        YRHttpRequest.requestWithURL(url,completionHandler:{ data in
            
            if data as! NSObject == NSNull()
            {
                return
            }
            
            let arr = data.objectForKey("data") as! NSArray

            let defaults = NSUserDefaults.standardUserDefaults()
            if((defaults.objectForKey("likes")) == nil){
                let saveData = NSKeyedArchiver.archivedDataWithRootObject(NSArray())
                defaults.setObject(saveData, forKey: "likes")
                defaults.synchronize()
            }
            
            let savedData = defaults.objectForKey("likes") as! NSData
            let saved = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as! NSArray
            
            //let saved = defaults.arrayForKey("likes") as? AnyObject as! NSArray
            var badgeNumber = 0
            
            for data : AnyObject  in arr
            {
                var isExist:Bool = false
                for item in saved
                {
                    //let newId = data["id"] as! Int
                    //let oldId = item["id"] as! Int
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
                    badgeNumber=badgeNumber+1;
                }
                
                // tabItem!.badgeValue = data as! String
                //For test pull request
            }
            
            if badgeNumber > 0 {
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "newLike", object: nil, userInfo: ["badgeNumber":String(badgeNumber)]))
            }
            

        })

    }
    

    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    
    func swizzlingMethod(clzz: AnyClass, oldSelector: Selector, newSelector: Selector) {
        let oldMethod = class_getInstanceMethod(clzz, oldSelector)
        let newMethod = class_getInstanceMethod(clzz, newSelector)
        method_exchangeImplementations(oldMethod, newMethod)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its cur rent state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

