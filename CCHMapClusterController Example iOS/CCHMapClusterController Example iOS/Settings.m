//
//  Settings.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus Höfele on 08.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (id)init
{
    self = [super init];
    if (self) {
        _cellSize = 60;
        _marginFactor = 0.5;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Settings *settings = [[Settings alloc] init];
    settings.debuggingEnabled = self.isDebuggingEnabled;
    settings.cellSize = self.cellSize;
    settings.marginFactor = self.marginFactor;
    settings.dataSet = self.dataSet;
    settings.clusterer = self.clusterer;
    settings.animator = self.animator;
    
    return settings;
}

@end
