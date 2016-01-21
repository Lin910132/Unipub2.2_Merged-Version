//
//  KCTextView.h
//  Whoops
//
//  Created by huangyao on 15-2-27.
//  Copyright (c) 2015y Li Jiatan. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface KCTextView : UITextView

/**
 The string that is displayed when there is no other text in the text view.
 
 The default value is `nil`.
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 The color of the placeholder.
 
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic, strong) UIColor *placeholderTextColor;


@end
