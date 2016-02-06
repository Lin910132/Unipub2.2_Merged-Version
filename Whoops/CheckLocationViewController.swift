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
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var summaryLabel: UILabel!
    
    @IBOutlet var step1: UILabel!
    @IBOutlet var step2: UILabel!
    @IBOutlet var step3: UILabel!
    @IBOutlet var step4: UILabel!
    @IBOutlet var setLocation: UIButton!
    
    override func viewDidLoad() {
        locationManager.delegate = self
        self.view.backgroundColor = UIColor.applicationMainColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        titleLabel.text = "WHOOPS".localized() + "..."
        summaryLabel.text = "Unipub needs your location in order to work. Here are a few quick steps to fix this.".localized()
        step1.text = "1. " + "Open your Settings".localized()
        step2.text = "2. " + "Scroll to Privacy and tap on it".localized()
        step3.text = "3. " + "Tap on Location Services".localized()
        step4.text = "4. " + "Find Unipub and turn Location On".localized()
        setLocation.setTitle("TAKE ME THERE".localized() + "!", forState: UIControlState.Normal)
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
