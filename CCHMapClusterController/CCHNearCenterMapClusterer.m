//
//  CCHNearCenterMapClusterer.m
//  CCHMapClusterController
//
//  Copyright (C) 2013 Claus Höfele
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCHNearCenterMapClusterer.h"

#import <float.h>

@implementation CCHNearCenterMapClusterer

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

- (CLLocationCoordinate2D)mapClusterController:(CCHMapClusterController *)mapClusterController coordinateForAnnotations:(NSSet *)annotations inMapRect:(MKMapRect)mapRect
{
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(mapRect), MKMapRectGetMidY(mapRect));
    id<MKAnnotation> closestAnnotation = findClosestAnnotation(annotations, centerMapPoint);
    return closestAnnotation.coordinate;
}

@end
