//
//  Settings.h
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 08.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    SettingsDataSetBerlin,
    SettingsDataSetUS
} SettingsDataSet;

typedef enum {
    SettingsClustererCenterOfMass,
    SettingsClustererNearCenter
} SettingsClusterer;

typedef enum {
    SettingsAnimatorFadeInOut
} SettingsAnimator;

@interface Settings : NSObject<NSCopying>

@property (nonatomic, getter = isDebuggingEnabled) BOOL debuggingEnabled;
@property (nonatomic) double cellSize;
@property (nonatomic) double marginFactor;
@property (nonatomic) SettingsDataSet dataSet;
@property (nonatomic, getter = isGroupingEnabled) BOOL groupingEnabled;
@property (nonatomic) SettingsClusterer clusterer;
@property (nonatomic) double maxZoomLevelForClustering;
@property (nonatomic) NSUInteger minUniqueLocationsForClustering;
@property (nonatomic) SettingsAnimator animator;

@end
