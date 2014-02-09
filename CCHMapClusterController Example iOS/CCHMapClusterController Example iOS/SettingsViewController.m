//
//  SettingsViewController.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 07.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "SettingsViewController.h"

#import "Settings.h"

#define SECTION_DATA_SET 1
#define SECTION_CLUSTERER 2
#define SECTION_ANIMATOR 3

@interface SettingsViewController()

@property (nonatomic, strong) UISwitch *debuggingEnabledSwitch;
@property (nonatomic, strong) UISlider *cellSizeSlider;
@property (nonatomic, strong) UISlider *marginFactorSlider;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.debuggingEnabledSwitch = [[UISwitch alloc] init];
    self.debuggingEnabledSwitch.on = self.settings.isDebuggingEnabled;
    self.debuggingEnabledTableViewCell.accessoryView = self.debuggingEnabledSwitch;
    
    self.cellSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.cellSizeSlider.minimumValue = 20;
    self.cellSizeSlider.maximumValue = 200;
    self.cellSizeSlider.value = MIN(MAX(self.settings.cellSize, self.cellSizeSlider.minimumValue), self.cellSizeSlider.maximumValue);
    self.cellSizeTableViewCell.accessoryView = self.cellSizeSlider;

    self.marginFactorSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.marginFactorSlider.minimumValue = 0;
    self.marginFactorSlider.maximumValue = 1.5;
    self.marginFactorSlider.value = MIN(MAX(self.settings.marginFactor, self.marginFactorSlider.minimumValue), self.marginFactorSlider.maximumValue);
    self.marginFactorTableViewCell.accessoryView = self.marginFactorSlider;

    NSIndexPath *dataSetIndexPath = [NSIndexPath indexPathForItem:(NSInteger)self.settings.dataSet inSection:SECTION_DATA_SET];
    [self selectIndexPath:dataSetIndexPath];

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
    if (indexPath.section == SECTION_DATA_SET) {
        [self selectIndexPath:indexPath];
    } else if (indexPath.section == SECTION_CLUSTERER) {
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
    self.settings.debuggingEnabled = self.debuggingEnabledSwitch.on;
    self.settings.cellSize = self.cellSizeSlider.value;
    self.settings.marginFactor = self.marginFactorSlider.value;
    self.settings.dataSet = (SettingsDataSet)[self selectedRowForSection:SECTION_DATA_SET];
    self.settings.clusterer = (SettingsClusterer)[self selectedRowForSection:SECTION_CLUSTERER];
    self.settings.animator = (SettingsAnimator)[self selectedRowForSection:SECTION_ANIMATOR];

    if (self.completionBlock) {
        self.completionBlock([self.settings copy]);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
