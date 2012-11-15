//
//  DetailViewController.h
//  ImageSizeDemo
//
//  Created by javen on 12-11-12.
//  Copyright (c) 2012年 yuezo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@end
