//
//  Rules&InfoViewController.swift
//  UniPub
//
//  Created by EagleWind on 1/9/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import UIKit
//import Localize_Swift


class Rules_InfoViewController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Rules & Info".localized()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
