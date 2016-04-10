//
//  YRHttpRequest.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014y YANGReal. All rights reserved.
//

import UIKit
import Foundation

//class func connectionWithRequest(request: NSURLRequest!, delegate: AnyObject!) -> NSURLConnection!


class YRHttpRequest: NSObject {

    override init()
    {
        super.init();
    }
    
    class func requestWithURL(urlString:String,completionHandler:(data:AnyObject)->Void)
    {
        let url = NSURL(string:urlString)
        let req = NSURLRequest(URL: url!)
        let queue = NSOperationQueue();
        NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
            if error != nil
            {
                dispatch_async(dispatch_get_main_queue(),
                {
                    print(error)
                    completionHandler(data:NSNull())
                })
            }
            else
            {
                let jsonData = (try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)) as! NSDictionary

                dispatch_async(dispatch_get_main_queue(),
                {
                    completionHandler(data:jsonData)
                    
                })
            }
        })
    }
    
   
    class func postWithURL(urlString urlString:String,paramData:String)->NSMutableArray{
    
    
        let data:NSMutableArray = NSMutableArray()
        let url1:NSURL = NSURL(string: urlString)!
    
        let postData:NSData = paramData.dataUsingEncoding(NSUTF8StringEncoding)!
    
        let postLength:String = String( postData.length )
    
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url1)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    
//        var reponseError: NSError?
        var response: NSURLResponse?
    
        var urlData: NSData?
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
        } catch let error as NSError {
//            reponseError = error
            print(error.localizedDescription)
            urlData = nil
        }
    
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            NSLog("Response code: %ld", res.statusCode);
    
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
    
                NSLog("Response ==> %@", responseData);
    
//                var error: NSError?
    
//                let jsonData:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers )) as! NSDictionary
    
                
    
                
            } else {
                NSLog("Login failed2");
            }
        } else {
            NSLog("Login failed3");
        }
        return data
    }
    
}
