//
//  YRSendViewCell.swift
//  Whoops
//
//  Created by huangyao on 15-2-27.
//  Copyright (c) 2015y Li Jiatan. All rights reserved.
//

import Foundation

class YRSendViewCell: UIView, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var photoButton: UIButton!
    
    
    @IBAction func photoButtonClick(sender: UIButton) {
        //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
        
        
        var sourceType = UIImagePickerControllerSourceType.Camera
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
        }
        
        
        let picker = UIImagePickerController()
 
        picker.delegate = self

        picker.allowsEditing = true//设置可编辑
        
        picker.sourceType = sourceType
        
//        self.presentViewController(picker, animated: true, completion: nil)//进入照相界面

    }
    
}
