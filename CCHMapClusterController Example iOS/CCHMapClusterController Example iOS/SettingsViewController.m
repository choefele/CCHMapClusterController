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
#define SECTION_DATA_SET 1
#define SECTION_CLUSTERER 2
#define SECTION_ANIMATOR 3

@interface SettingsViewController()

@property (weak, nonatomic) IBOutlet UITableViewCell *debuggingEnabledTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSizeTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *marginFactorTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *maxZoomLevelTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *minUniqueLocationsTableViewCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *groupingEnabledTableViewCell;

@property (nonatomic) UISwitch *debuggingEnabledSwitch;
@property (nonatomic) UIStepper *cellSizeStepper;
@property (nonatomic) UIStepper *marginFactorStepper;
@property (nonatomic) UIStepper *maxZoomLevelStepper;
@property (nonatomic) UIStepper *minUniqueLocationsStepper;
@property (nonatomic) UISwitch *groupingEnabledSwitch;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // SECTION_GENERAL
    self.debuggingEnabledSwitch = [[UISwitch alloc] init];
    self.debuggingEnabledSwitch.on = self.settings.isDebuggingEnabled;
    self.debuggingEnabledTableViewCell.accessoryView = self.debuggingEnabledSwitch;
    
    self.cellSizeStepper = [self newStepper];
    self.cellSizeStepper.minimumValue = 20;
    self.cellSizeStepper.maximumValue = 200;
    self.cellSizeStepper.stepValue = 10;
    self.cellSizeStepper.value = MIN(MAX(self.settings.cellSize, self.cellSizeStepper.minimumValue), self.cellSizeStepper.maximumValue);
    self.cellSizeTableViewCell.accessoryView = self.cellSizeStepper;
    self.cellSizeTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.cellSizeStepper.value];
    
    self.marginFactorStepper = [self newStepper];
    self.marginFactorStepper.minimumValue = -0.2;
    self.marginFactorStepper.maximumValue = 1.5;
    self.marginFactorStepper.stepValue = 0.1;
    self.marginFactorStepper.value = MIN(MAX(self.settings.marginFactor, self.marginFactorStepper.minimumValue), self.marginFactorStepper.maximumValue);
    self.marginFactorTableViewCell.accessoryView = self.marginFactorStepper;
    self.marginFactorTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.marginFactorStepper.value];

    // SECTION_DATA_SET
    NSIndexPath *dataSetIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.settings.dataSet inSection:SECTION_DATA_SET];
    [self selectIndexPath:dataSetIndexPath];
    
    self.groupingEnabledSwitch = [[UISwitch alloc] init];
    self.groupingEnabledSwitch.on = self.settings.isGroupingEnabled;
    self.groupingEnabledTableViewCell.accessoryView = self.groupingEnabledSwitch;

    // SECTION_CLUSTERER
    NSIndexPath *clustererIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.settings.clusterer inSection:SECTION_CLUSTERER];
    [self selectIndexPath:clustererIndexPath];
    
    self.maxZoomLevelStepper = [self newStepper];
    self.maxZoomLevelStepper.minimumValue = 5;
    self.maxZoomLevelStepper.maximumValue = 25;
    self.maxZoomLevelStepper.stepValue = 1;
    self.maxZoomLevelStepper.value = MIN(MAX(self.settings.maxZoomLevelForClustering, self.maxZoomLevelStepper.minimumValue), self.maxZoomLevelStepper.maximumValue);
    self.maxZoomLevelTableViewCell.accessoryView = self.maxZoomLevelStepper;
    self.maxZoomLevelTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.maxZoomLevelStepper.value];

    self.minUniqueLocationsStepper = [self newStepper];
    self.minUniqueLocationsStepper.minimumValue = 2;
    self.minUniqueLocationsStepper.maximumValue = 10;
    self.minUniqueLocationsStepper.stepValue = 1;
    self.minUniqueLocationsStepper.value = MIN(MAX(self.settings.minUniqueLocationsForClustering, self.minUniqueLocationsStepper.minimumValue), self.minUniqueLocationsStepper.maximumValue);
    self.minUniqueLocationsTableViewCell.accessoryView = self.minUniqueLocationsStepper;
    self.minUniqueLocationsTableViewCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", self.minUniqueLocationsStepper.value];

    // SECTION_ANIMATOR
    NSIndexPath *animatorIndexPath = [NSIndexPath indexPathForRow:(NSInteger)self.settings.clusterer inSection:SECTION_ANIMATOR];
    [self selectIndexPath:animatorIndexPath];
}

- (UIStepper *)newStepper
{
    UIStepper *stepper = [[UIStepper alloc] init];
    [stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    return stepper;
}

- (void)stepperValueChanged:(UIStepper *)sender
{
    CGPoint point = [self.tableView convertPoint:CGPointMake(0, 0) fromView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
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
    self.settings.groupingEnabled = self.groupingEnabledSwitch.on;
    self.settings.dataSet = (SettingsDataSet)[self selectedRowForSection:SECTION_DATA_SET];
    self.settings.clusterer = (SettingsClusterer)[self selectedRowForSection:SECTION_CLUSTERER];
    self.settings.maxZoomLevelForClustering = self.maxZoomLevelStepper.value;
    self.settings.minUniqueLocationsForClustering = (NSUInteger)self.minUniqueLocationsStepper.value;
    self.settings.animator = (SettingsAnimator)[self selectedRowForSection:SECTION_ANIMATOR];

    if (self.completionBlock) {
        self.completionBlock([self.settings copy]);
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
