//
//  PhotoDetailViewController.swift
//  UniPub
//
//  Created by Must on 2/9/16.
//  Copyright © 2016 Li Jiatan. All rights reserved.
//

import Foundation
import UIKit
import MWPhotoBrowser

class PhotoDetailViewController:MWPhotoBrowser, MWPhotoBrowserDelegate{
    var imageArray:[UIImage] = [UIImage]()
    var photoArray:[MWPhoto] = [MWPhoto]()
    var startImageIndex = 0
    var parentController:YRMainViewController?
    
    override func viewDidLoad() {
        for (var i = 0; i < imageArray.count; i++){
            let photo:MWPhoto = MWPhoto(image: imageArray[i])
            photoArray.append(photo)
        }
        
        self.delegate = self
        self.displayActionButton = false
        self.displayNavArrows = false
        self.displaySelectionButtons = false
        self.alwaysShowControls = false
        self.zoomPhotosToFill = true
        self.enableGrid = false
        self.startOnGrid = false
        self.enableSwipeToDismiss = true
        self.autoPlayOnAppear = false
        self.setCurrentPhotoIndex(0)
        self.registerGestureRecorgnizer()
        self.setCurrentPhotoIndex(UInt(startImageIndex))
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func registerGestureRecorgnizer(){
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("dismissByTap:"))
        self.view.addGestureRecognizer(gesture)
    }
    
    func dismissByTap(recorgnize: UIGestureRecognizer){
        self.parentController?.fromDetail = true

        self.dismissViewControllerAnimated(true, completion: {
            self.parentController?.tabBarController?.tabBar.hidden = false
        })
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt{
        return UInt(photoArray.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol!{
        if (index < UInt(photoArray.count)){
            return photoArray[Int(index)] 
        }
        return nil
    }
}