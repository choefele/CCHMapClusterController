//
//  CCHMapCenterOfMassClusterer.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 04.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "CCHMapCenterOfMassClusterer.h"

@implementation CCHMapCenterOfMassClusterer

- (CLLocationCoordinate2D)coordinateForAnnotations:(NSSet *)annotations inMapRect:(MKMapRect)mapRect
{
    double latitude = 0, longitude = 0;
    for (id<MKAnnotation> annotation in annotations) {
        latitude += annotation.coordinate.latitude;
        longitude += annotation.coordinate.longitude;
    }
    
    double count = annotations.count;
    return CLLocationCoordinate2DMake(latitude / count, longitude / count);
}

@end
