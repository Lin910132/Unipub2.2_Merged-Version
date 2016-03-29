//
//  ImagesDetailViewController.swift
//  UniPub
//
//  Created by BRD on 1/18/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width

import Foundation
import UIKit




class ImagesDetailViewController: UIViewController,UIScrollViewDelegate {
    
    var imageArray : NSArray!;
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    

    
    
    var currentIndex=Int()
    var countOfimageArray:Int = 0
    var currentOffset=CGPoint()
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ImagesDetailViewController.tapHandler(_:)))
        scrollView.addGestureRecognizer(gesture)
        scrollView.backgroundColor=UIColor.blackColor()
        currentIndex=1
        countOfimageArray=imageArray.count
        
        scrollView.contentSize = CGSizeMake(CGFloat(countOfimageArray) * SCREEN_WIDTH, SCREEN_HEIGHT)
        
        var i = 0
        for _ in imageArray
        {
//            let gesture = UITapGestureRecognizer(target: self, action: "tapProductHandler")
//            itemView.addGestureRecognizer(gesture)
            
            let imageview : UIImageView = UIImageView(frame: CGRectMake(SCREEN_WIDTH*CGFloat(i), 0, SCREEN_WIDTH, SCREEN_HEIGHT))
            imageview.image = imageArray[i] as? UIImage
            imageview.contentMode = UIViewContentMode.ScaleAspectFit;
            scrollView.addSubview(imageview)
            
         //   scrollView.addSubview(itemView)
//            if(i == currentIndex - 1){
//                imageview.transform = CGAffineTransformMakeScale(1, 1)
//            }
            scrollView.delegate = self
            i += 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func tapProductHandler(){
        self.performSegueWithIdentifier("gotoProductDetail", sender: nil)
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView){
        
        for var i = currentIndex-2 ; i < currentIndex+1 ; i += 1
        {
            if(i == -1){continue}
            let cell : UIView  = scrollView.subviews[i]
            cell.transform = CGAffineTransformMakeScale(1, 1)
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        
        var offset = targetContentOffset.memory
        if(velocity.x>0){
            print("Siwpe Left")
            currentIndex += 1
        }else{
            print("Siwpe right")
            currentIndex -= 1
        }
        
        if(currentIndex > self.imageArray.count){
            currentIndex=self.imageArray.count
        }
        
        if(currentIndex < 1){
            currentIndex = 1
        }
        
        offset.x = SCREEN_WIDTH * CGFloat(currentIndex - 1)
        targetContentOffset.memory = offset
        
    }
    
    func tapHandler(gesture : UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

   
    
    
}