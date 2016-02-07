//
//  CheckLocationViewController.swift
//  UniPub
//
//  Created by Li Jiatan on 2/5/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import UIKit
import Foundation

class CheckLocationViewController: UIViewController,CLLocationManagerDelegate {

    let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        locationManager.delegate = self
        self.view.backgroundColor = UIColor.applicationMainColor()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(ios8()){
            let status = CLLocationManager.authorizationStatus()
            
            if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func TakeBtnClicked(sender: AnyObject) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
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
}
