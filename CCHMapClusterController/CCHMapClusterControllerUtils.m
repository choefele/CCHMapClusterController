//
//  CCHMapClusterControllerUtils.m
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

#import "CCHMapClusterControllerUtils.h"

#import "CCHMapClusterAnnotation.h"

#import <float.h>

#define fequal(a, b) (fabs((a) - (b)) < __FLT_EPSILON__)

MKMapRect CCHMapClusterControllerAlignMapRectToCellSize(MKMapRect mapRect, double cellSize)
{
    NSCAssert(cellSize != 0, @"Invalid map length");
    if (cellSize == 0) {
        return MKMapRectNull;
    }

    double startX = floor(MKMapRectGetMinX(mapRect) / cellSize) * cellSize;
    double startY = floor(MKMapRectGetMinY(mapRect) / cellSize) * cellSize;
    double endX = ceil(MKMapRectGetMaxX(mapRect) / cellSize) * cellSize;
    double endY = ceil(MKMapRectGetMaxY(mapRect) / cellSize) * cellSize;
    
    return MKMapRectMake(startX, startY, endX - startX, endY - startY);
}

CCHMapClusterAnnotation *CCHMapClusterControllerFindVisibleAnnotation(NSSet *annotations, NSSet *visibleAnnotations)
{
    for (id<MKAnnotation> annotation in annotations) {
        for (CCHMapClusterAnnotation *visibleAnnotation in visibleAnnotations) {
            if ([visibleAnnotation.annotations containsObject:annotation]) {
                return visibleAnnotation;
            }
        }
    }
    
    return nil;
}

#if TARGET_OS_IPHONE
double CCHMapClusterControllerMapLengthForLength(MKMapView *mapView, UIView *view, double length)
#else
double CCHMapClusterControllerMapLengthForLength(MKMapView *mapView, NSView *view, double length)
#endif
{
    // Convert points to coordinates
    CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:CGPointZero toCoordinateFromView:view];
    CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:CGPointMake(length, 0) toCoordinateFromView:view];
    
    // Convert coordinates to map points
    MKMapPoint leftMapPoint = MKMapPointForCoordinate(leftCoordinate);
    MKMapPoint rightMapPoint = MKMapPointForCoordinate(rightCoordinate);

    // Calculate distance between map points
    double xd = leftMapPoint.x - rightMapPoint.x;
    double yd = leftMapPoint.y - rightMapPoint.y;
    double mapLength = sqrt(xd*xd + yd*yd);
    
    // For very large lengths, we assume that we measured the other way around the world
    if (mapLength > (MKMapSizeWorld.width * 0.5)) {
        mapLength = MKMapSizeWorld.width - mapLength;
    }
    
    return mapLength;
}

double CCHMapClusterControllerAlignMapLengthToWorldWidth(double mapLength)
{
    NSCAssert(mapLength != 0, @"Invalid map length");
    if (mapLength == 0) {
        return 0;
    }

    mapLength = MKMapSizeWorld.width / floor(MKMapSizeWorld.width / mapLength);
    return mapLength;
}

BOOL CCHMapClusterControllerCoordinateEqualToCoordinate(CLLocationCoordinate2D coordinate0, CLLocationCoordinate2D coordinate1)
{
    BOOL isCoordinateUpToDate = fequal(coordinate0.latitude, coordinate1.latitude) && fequal(coordinate0.longitude, coordinate1.longitude);
    return isCoordinateUpToDate;
}

CCHMapClusterAnnotation *CCHMapClusterControllerClusterAnnotationForAnnotation(MKMapView *mapView, id<MKAnnotation> annotation, MKMapRect mapRect)
{
    CCHMapClusterAnnotation *annotationResult;
    
    NSSet *mapAnnotations = [mapView annotationsInMapRect:mapRect];
    for (id<MKAnnotation> mapAnnotation in mapAnnotations) {
        if ([mapAnnotation isKindOfClass:CCHMapClusterAnnotation.class]) {
            CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)mapAnnotation;
            if (mapClusterAnnotation.annotations) {
                if ([mapClusterAnnotation.annotations containsObject:annotation]) {
                    annotationResult = mapClusterAnnotation;
                    break;
                }
            }
        }
    }
    
    return annotationResult;
}

void CCHMapClusterControllerEnumerateCells(MKMapRect mapRect, double cellSize, void (^block)(MKMapRect cellRect))
{
    NSCAssert(block != NULL, @"Block argument can't be NULL");
    if (block == nil) {
        return;
    }
    
    MKMapRect cellRect = MKMapRectMake(0, MKMapRectGetMinY(mapRect), cellSize, cellSize);
    while (MKMapRectGetMinY(cellRect) < MKMapRectGetMaxY(mapRect)) {
        cellRect.origin.x = MKMapRectGetMinX(mapRect);
        
        while (MKMapRectGetMinX(cellRect) < MKMapRectGetMaxX(mapRect)) {
            // Wrap around the origin's longitude
            MKMapRect rect = MKMapRectMake(fmod(cellRect.origin.x, MKMapSizeWorld.width), cellRect.origin.y, cellRect.size.width, cellRect.size.height);
            block(rect);
            
            cellRect.origin.x += MKMapRectGetWidth(cellRect);
        }
        cellRect.origin.y += MKMapRectGetWidth(cellRect);
    }
}

MKMapRect CCHMapClusterControllerMapRectForCoordinateRegion(MKCoordinateRegion coordinateRegion)
{
    CLLocationCoordinate2D topLeftCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + (coordinateRegion.span.latitudeDelta / 2.0), coordinateRegion.center.longitude - (coordinateRegion.span.longitudeDelta / 2.0));
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - (coordinateRegion.span.latitudeDelta / 2.0), coordinateRegion.center.longitude + (coordinateRegion.span.longitudeDelta / 2.0));
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x, topLeftMapPoint.y, fabs(bottomRightMapPoint.x - topLeftMapPoint.x), fabs(bottomRightMapPoint.y - topLeftMapPoint.y));
    
    return mapRect;
}

NSSet *CCHMapClusterControllerClusterAnnotationsForAnnotations(NSArray *annotations, CCHMapClusterController *mapClusterController)
{
    NSSet *filteredAnnotations = [NSMutableSet setWithArray:annotations];
    filteredAnnotations = [filteredAnnotations filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL evaluation = NO;
        if ([evaluatedObject isKindOfClass:CCHMapClusterAnnotation.class]) {
            CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)evaluatedObject;
            evaluation = (clusterAnnotation.mapClusterController == mapClusterController);
        }
        return evaluation;
    }]];
    
    return filteredAnnotations;
}
