//
//  UniversityPageObj.swift
//  UniPub
//
//  Created by Li Jiatan on 9/30/15.
//  Copyright © 2015 Li Jiatan. All rights reserved.
//

import Foundation

class UniversityPageObj: NSObject {
    static var Page:Int = 1
    
    static var PageNum : Int {
        get{
            return self.Page;
        }
        
        set{
            self.Page = newValue
        }
    }
}