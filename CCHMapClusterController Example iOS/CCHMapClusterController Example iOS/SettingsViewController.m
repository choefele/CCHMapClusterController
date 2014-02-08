//
//  SettingsViewController.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 07.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "SettingsViewController.h"

#import "Settings.h"

#define SECTION_CLUSTERER 1
#define SECTION_ANIMATOR 2

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISwitch *debuggingEnabledSwitch = [[UISwitch alloc] init];
    debuggingEnabledSwitch.on = self.settings.isDebuggingEnabled;
    self.debugTableViewCell.accessoryView = debuggingEnabledSwitch;
    
    NSIndexPath *clustererIndexPath = [NSIndexPath indexPathForItem:(NSInteger)self.settings.clusterer inSection:SECTION_CLUSTERER];
    [self selectIndexPath:clustererIndexPath];

    NSIndexPath *animatorIndexPath = [NSIndexPath indexPathForItem:(NSInteger)self.settings.clusterer inSection:SECTION_ANIMATOR];
    [self selectIndexPath:animatorIndexPath];
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

- (NSInteger)selectedRowForSection:(NSInteger)section
{
    NSInteger selectedRow = 0;
    
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:section];
    for (NSInteger i = 0; i < numberOfRows; i++) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForItem:i inSection:section];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:rowIndexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            selectedRow = i;
            break;
        }
    }
    
    return selectedRow;
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
    UISwitch *debuggingEnabledSwitch = (UISwitch *)self.debugTableViewCell.accessoryView;
    self.settings.debuggingEnabled = debuggingEnabledSwitch.on;
    self.settings.clusterer = (SettingsClusterer)[self selectedRowForSection:SECTION_CLUSTERER];
    self.settings.animator = (SettingsAnimator)[self selectedRowForSection:SECTION_ANIMATOR];

    if (self.completionBlock) {
        self.completionBlock([self.settings copy]);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
