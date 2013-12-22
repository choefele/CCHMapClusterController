//
//  CCHMapTree.h
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UnsafeMutableArray : NSObject

@property (nonatomic, assign, readonly) id __unsafe_unretained *objects;
@property (nonatomic, assign, readonly) NSUInteger numObjects;

- (void)addObject:(__unsafe_unretained id)object;

@end

@interface CCHMapTree : NSObject

- (id)init;
- (id)initWithNodeCapacity:(NSUInteger)nodeCapacity minLatitude:(double)minLatitude maxLatitude:(double)maxLatitude minLongitude:(double)minLongitude maxLongitude:(double)maxLongitude;

- (void)addAnnotations:(NSArray *)annotations;
- (UnsafeMutableArray *)annotationsInMapRect:(MKMapRect)mapRect;

@end
