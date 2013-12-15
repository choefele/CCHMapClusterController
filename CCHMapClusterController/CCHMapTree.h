//
//  CCHMapTree.h
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CCHMapTree : NSObject

- (void)addAnnotations:(NSArray *)annotations;
- (NSArray *)annotationsInMapRect:(MKMapRect)mapRect;

@end
