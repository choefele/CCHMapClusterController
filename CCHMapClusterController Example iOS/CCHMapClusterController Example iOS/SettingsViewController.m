//
//  SettingsViewController.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 07.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "SettingsViewController.h"

#import "Settings.h"

#define SECTION_GENERAL 0
#define SECTION_GENERAL_ROW_CELL_SIZE 1
#define SECTION_GENERAL_ROW_MARGIN_FACTOR 2
#define SECTION_DATA_SET 1
#define SECTION_CLUSTERER 2
#define SECTION_ANIMATOR 3

@interface SettingsViewController()

@property (nonatomic, strong) UISwitch *debuggingEnabledSwitch;
@property (nonatomic, strong) UIStepper *cellSizeStepper;
@property (nonatomic, strong) UIStepper *marginFactorStepper;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.debuggingEnabledSwitch = [[UISwitch alloc] init];
    self.debuggingEnabledSwitch.on = self.settings.isDebuggingEnabled;
    self.debuggingEnabledTableViewCell.accessoryView = self.debuggingEnabledSwitch;
    
    self.cellSizeStepper = [self stepperForRow:SECTION_GENERAL_ROW_CELL_SIZE];
    self.cellSizeStepper.minimumValue = 20;
    self.cellSizeStepper.maximumValue = 200;
    self.cellSizeStepper.stepValue = 10;
    self.cellSizeStepper.value = MIN(MAX(self.settings.cellSize, self.cellSizeStepper.minimumValue), self.cellSizeStepper.maximumValue);
    self.cellSizeTableViewCell.accessoryView = self.cellSizeStepper;
    self.cellSizeTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.cellSizeStepper.value];
    
    self.marginFactorStepper = [self stepperForRow:SECTION_GENERAL_ROW_MARGIN_FACTOR];
    self.marginFactorStepper.minimumValue = -0.2;
    self.marginFactorStepper.maximumValue = 1.5;
    self.marginFactorStepper.stepValue = 0.1;
    self.marginFactorStepper.value = MIN(MAX(self.settings.marginFactor, self.marginFactorStepper.minimumValue), self.marginFactorStepper.maximumValue);
    self.marginFactorTableViewCell.accessoryView = self.marginFactorStepper;
    self.marginFactorTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.marginFactorStepper.value];

    NSIndexPath *dataSetIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.settings.dataSet inSection:SECTION_DATA_SET];
    [self selectIndexPath:dataSetIndexPath];

    NSIndexPath *clustererIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.settings.clusterer inSection:SECTION_CLUSTERER];
    [self selectIndexPath:clustererIndexPath];

    NSIndexPath *animatorIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.settings.clusterer inSection:SECTION_ANIMATOR];
    [self selectIndexPath:animatorIndexPath];
}

- (UIStepper *)stepperForRow:(NSInteger)row
{
    UIStepper *stepper = [[UIStepper alloc] init];
    stepper.tag = row;
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return stepper;
}

- (void)stepperValueChanged:(UIStepper *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:SECTION_GENERAL];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

- (void)selectIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:indexPath.section];
    for (NSInteger i = 0; i < numberOfRows; i++) {
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
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
        NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:i inSection:section];
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
    self.settings.cellSize = self.cellSizeStepper.value;
    self.settings.marginFactor = self.marginFactorStepper.value;
    self.settings.dataSet = (SettingsDataSet)[self selectedRowForSection:SECTION_DATA_SET];
    self.settings.clusterer = (SettingsClusterer)[self selectedRowForSection:SECTION_CLUSTERER];
    self.settings.animator = (SettingsAnimator)[self selectedRowForSection:SECTION_ANIMATOR];

    if (self.completionBlock) {
        self.completionBlock([self.settings copy]);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
