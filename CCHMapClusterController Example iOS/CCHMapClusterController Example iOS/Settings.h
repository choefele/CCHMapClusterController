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

@interface Settings : NSObject

@property (nonatomic, assign, getter = isDebuggingEnabled) BOOL debuggingEnabled;
@property (nonatomic, assign) double cellSize;
@property (nonatomic, assign) double marginFactor;
@property (nonatomic, assign) SettingsDataSet dataSet;
@property (nonatomic, assign) SettingsClusterer clusterer;
@property (nonatomic, assign) SettingsAnimator animator;

@end
