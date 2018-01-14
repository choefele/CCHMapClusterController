//
//  CCHMapClusterOperation.h
//  CCHMapClusterController
//
//  Copyright (C) 2014 Claus Höfele
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

@class CCHMapClusterController;
@class CCHMapClusterAnnotation;
@class CCHMapTree;
@protocol CCHMapClusterer;
@protocol CCHMapAnimator;
@protocol CCHMapClusterControllerDelegate;


typedef enum {
	ClusterMethodGridBased,
	ClusterMethodDistanceBased
} CCHClusterMethod;


@interface CCHMapClusterOperation : NSOperation

@property (nonatomic) CCHMapTree *allAnnotationsMapTree;
@property (nonatomic) CCHMapTree *visibleAnnotationsMapTree;
@property (nonatomic) id<CCHMapClusterer> clusterer;
@property (nonatomic) id<CCHMapAnimator> animator;
@property (nonatomic, weak) id<CCHMapClusterControllerDelegate> clusterControllerDelegate;
@property (nonatomic, weak) CCHMapClusterController *clusterController;
@property (nonatomic) CCHClusterMethod clusterMethod;

- (instancetype)initWithMapView:(MKMapView *)mapView cellSize:(double)cellSize marginFactor:(double)marginFactor reuseExistingClusterAnnotations:(BOOL)reuseExistingClusterAnnotation maxZoomLevelForClustering:(double)maxZoomLevelForClustering minUniqueLocationsForClustering:(NSUInteger)minUniqueLocationsForClustering;

+ (double)cellMapSizeForCellSize:(double)cellSize withMapView:(MKMapView *)mapView;
+ (MKMapRect)gridMapRectForMapRect:(MKMapRect)mapRect withCellMapSize:(double)cellMapSize marginFactor:(double)marginFactor;

@end
