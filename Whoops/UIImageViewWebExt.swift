//
//  UIImageViewWebExt.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014y YANGReal. All rights reserved.
//

import UIKit
import Foundation

extension UIImageView
{
    func setImage(urlString:String,placeHolder:UIImage!)
    {
        let u = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        //let u = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let url = NSURL(string:u!)
        let cacheFilename = url?.lastPathComponent
        let cachePath = FileUtility.cachePath(cacheFilename!)
        let image : AnyObject = FileUtility.imageDataFromPath(cachePath)
        //let cropimage:AnyObject=UIImage()
      //  println(cachePath)
        if image as! NSObject != NSNull()
        {
            self.image = image as? UIImage //self.cropToBounds(image as! UIImage, width: self.width(), height: self.height())
        }
        else
        {
            let req = NSURLRequest(URL: url!)
            let queue = NSOperationQueue();
            NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { response, data, error in
                if error != nil
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            print(error)
                            self.image = placeHolder
                        })
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            
                            let image = UIImage(data: data!)
                            
                            
                            //return image
                            
                            
                            if image == nil
                            {
                                self.image = placeHolder
                            }
                            else
                            {
                                self.image = image//self.cropToBounds(image!, width: self.width(), height: self.height())
                                //FileUtility.imageCacheToPath(cachePath,image:data!)
                            }
                        })
                }
                })

        }
        
    }
    
   /*( func cropToBounds(image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }*/
}


