//
//  SettingsViewController.h
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 07.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Settings;

@interface SettingsViewController : UITableViewController

@property (nonatomic, copy) void (^completionBlock)(Settings *settings);
@property (nonatomic, copy) Settings *settings;

@end
