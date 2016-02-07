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
