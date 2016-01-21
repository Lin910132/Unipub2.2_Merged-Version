//
//  SchoolObject.swift
//  UniPub
//
//  Created by 刘乃坤 on 15/8/28.
//  Copyright (c) 2015年 Li Jiatan. All rights reserved.
//

import Foundation


class SchoolObject: NSObject {
    static var schoolId:String = "0"
    
    static var schoolName:String = ""
    
    static var result : String {
        get{
            return self.schoolId;
        }
        
        set{
            //self.schoolId = newValue
        }
    }
   }
