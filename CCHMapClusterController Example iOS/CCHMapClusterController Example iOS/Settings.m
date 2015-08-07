//
//  Settings.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 08.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellSize = 60;
        _marginFactor = 0.5;
        _maxZoomLevelForClustering = 16;
        _minUniqueLocationsForClustering = 3;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Settings *settings = [[Settings alloc] init];
    settings.debuggingEnabled = self->_debuggingEnabled;
    settings.cellSize = self->_cellSize;
    settings.approximatedAnnotationRadius = self->_approximatedAnnotationRadius;
    settings.marginFactor = self->_marginFactor;
    settings.dataSet = self->_dataSet;
    settings.groupingEnabled = self->_groupingEnabled;
    settings.clusterer = self->_clusterer;
    settings.maxZoomLevelForClustering = self->_maxZoomLevelForClustering;
    settings.minUniqueLocationsForClustering = self->_minUniqueLocationsForClustering;
    settings.animator = self->_animator;
    
    return settings;
}

@end
