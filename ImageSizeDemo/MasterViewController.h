//
//  MasterViewController.h
//  ImageSizeDemo
//
//  Created by javen on 12-11-12.
//  Copyright (c) 2012年 yuezo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
