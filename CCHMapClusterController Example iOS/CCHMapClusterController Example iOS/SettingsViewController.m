//
//  SettingsViewController.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 07.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "SettingsViewController.h"

#import "CCHMapClusterController.h"

#define SECTION_CLUSTERER 1
#define SECTION_ANIMATOR 2

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.debugTableViewCell.accessoryView = [[UISwitch alloc] init];
    [self updateSettings];
}

- (void)updateSettings
{
    // General
    UISwitch *debugSwitch = (UISwitch *)self.debugTableViewCell.accessoryView;
    debugSwitch.on = self.mapClusterController.isDebuggingEnabled;
}

- (void)updateClusterController
{
    // General
    UISwitch *debugSwitch = (UISwitch *)self.debugTableViewCell.accessoryView;
    self.mapClusterController.debuggingEnabled = debugSwitch.on;
}

- (void)selectIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:indexPath.section];
    for (NSInteger i = 0; i < numberOfRows; i++) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForItem:i inSection:indexPath.section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:rowIndexPath];
        if (i == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_CLUSTERER) {
        [self selectIndexPath:indexPath];
    } else if (indexPath.section == SECTION_ANIMATOR) {
        [self selectIndexPath:indexPath];
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)done:(UIBarButtonItem *)sender
{
    [self updateClusterController];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
