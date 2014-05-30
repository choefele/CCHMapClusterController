//
//  CCHMapClusterControllerUtils.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class CCHMapClusterAnnotation;
@class CCHMapClusterController;

MKMapRect CCHMapClusterControllerAlignMapRectToCellSize(MKMapRect mapRect, double cellSize);
CCHMapClusterAnnotation *CCHMapClusterControllerFindVisibleAnnotation(NSSet *annotations, NSSet *visibleAnnotations);
#if TARGET_OS_IPHONE
double CCHMapClusterControllerMapLengthForLength(MKMapView *mapView, UIView *view, double length);
#else
double CCHMapClusterControllerMapLengthForLength(MKMapView *mapView, NSView *view, double length);
#endif
double CCHMapClusterControllerAlignMapLengthToWorldWidth(double mapLength);
BOOL CCHMapClusterControllerCoordinateEqualToCoordinate(CLLocationCoordinate2D coordinate0, CLLocationCoordinate2D coordinate1);
CCHMapClusterAnnotation *CCHMapClusterControllerClusterAnnotationForAnnotation(MKMapView *mapView, id<MKAnnotation> annotation, MKMapRect mapRect);
void CCHMapClusterControllerEnumerateCells(MKMapRect mapRect, double cellSize, void (^block)(MKMapRect cellMapRect));
MKMapRect CCHMapClusterControllerMapRectForCoordinateRegion(MKCoordinateRegion coordinateRegion);
NSSet *CCHMapClusterControllerClusterAnnotationsForAnnotations(NSArray *annotations, CCHMapClusterController *mapClusterController);
double CCHMapClusterControllerZoomLevelForRegion(CLLocationDegrees longitudeCenter, CLLocationDegrees longitudeDelta, CGFloat width);
NSArray *CCHMapClusterControllerAnnotationSetsByUniqueLocations(NSSet *annotations, NSUInteger maxUniqueLocations);
BOOL CCHMapClusterControllerIsUniqueLocation(NSSet *annotations);