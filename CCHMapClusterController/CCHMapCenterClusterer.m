//
//  CCHMapCenterClusterer.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 04.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "CCHMapCenterClusterer.h"

#import "CCHMapClusterAnnotation.h"

#import <float.h>

@implementation CCHMapCenterClusterer

id<MKAnnotation> findClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint)
{
    id<MKAnnotation> closestAnnotation;
    CLLocationDistance closestDistance = __DBL_MAX__;
    for (id<MKAnnotation> annotation in annotations) {
        MKMapPoint annotationAsMapPoint = MKMapPointForCoordinate(annotation.coordinate);
        CLLocationDistance distance = MKMetersBetweenMapPoints(mapPoint, annotationAsMapPoint);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestAnnotation = annotation;
        }
    }
    
    return closestAnnotation;
}

- (CLLocationCoordinate2D)coordinateForAnnotations:(NSSet *)annotations inMapRect:(MKMapRect)mapRect
{
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(mapRect), MKMapRectGetMidY(mapRect));
    id<MKAnnotation> closestAnnotation = findClosestAnnotation(annotations, centerMapPoint);
    return closestAnnotation.coordinate;
}

@end
