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

@property (nonatomic, copy, readonly) NSSet *annotations;

- (id)init;
- (id)initWithNodeCapacity:(NSUInteger)nodeCapacity minLatitude:(double)minLatitude maxLatitude:(double)maxLatitude minLongitude:(double)minLongitude maxLongitude:(double)maxLongitude;

- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotations:(NSArray *)annotations;
- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect;

@end
