//
//  CCHMapClusterController.m
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

// Based on https://github.com/MarcoSero/MSMapClustering by MarcoSero/WWDC 2010

#import "CCHMapClusterController.h"

#import "CCHMapClusterControllerUtils.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapViewDelegateProxy.h"
#import "CCHNearCenterMapClusterer.h"
#import "CCHFadeInOutMapAnimator.h"

#define fequal(a, b) (fabs((a) - (b)) < __FLT_EPSILON__)
@interface CCHMapClusterControllerPolygon : MKPolygon
@end
@implementation CCHMapClusterControllerPolygon
@end

@interface CCHMapClusterController()<MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKMapView *allAnnotationsMapView;
@property (nonatomic, strong) CCHMapViewDelegateProxy *mapViewDelegateProxy;
@property (nonatomic, strong) id<MKAnnotation> annotationToSelect;
@property (nonatomic, strong) CCHMapClusterAnnotation *mapClusterAnnotationToSelect;
@property (nonatomic, assign) MKCoordinateSpan regionSpanBeforeChange;
@property (nonatomic, strong) id<CCHMapClusterer> strongClusterer;
@property (nonatomic, strong) CCHMapClusterAnnotation *(^findVisibleAnnotation)(NSSet *annotations, NSSet *visibleAnnotations);
@property (nonatomic, strong) id<CCHMapAnimator> strongAnimator;

@end

@implementation CCHMapClusterController

- (id)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        self.reuseExistingClusterAnnotations = YES;
        self.marginFactor = 0.5;
        self.cellSize = 60;
        self.mapView = mapView;
        self.allAnnotationsMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        self.mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:self];
        
        // Keep strong reference to default instance because public property is weak
        id<CCHMapClusterer> clusterer = [[CCHNearCenterMapClusterer alloc] init];
        self.clusterer = clusterer;
        self.strongClusterer = clusterer;
        id<CCHMapAnimator> animator = [[CCHFadeInOutMapAnimator alloc] init];
        self.animator = animator;
        self.strongAnimator = animator;
    }
    return self;
}

- (void)setClusterer:(id<CCHMapClusterer>)clusterer
{
    _clusterer = clusterer;
    self.strongClusterer = nil;
}

- (void)setAnimator:(id<CCHMapAnimator>)animator
{
    _animator = animator;
    self.strongAnimator = nil;
}

- (void)setReuseExistingClusterAnnotations:(BOOL)reuseExistingClusterAnnotations
{
    _reuseExistingClusterAnnotations = reuseExistingClusterAnnotations;
    if (reuseExistingClusterAnnotations) {
        self.findVisibleAnnotation = ^CCHMapClusterAnnotation *(NSSet *annotations, NSSet *visibleAnnotations) {
            return CCHMapClusterControllerFindVisibleAnnotation(annotations, visibleAnnotations);
        };
    } else {
        self.findVisibleAnnotation = ^CCHMapClusterAnnotation *(NSSet *annotations, NSSet *visibleAnnotations) {
            return nil;
        };
    }
}

- (void)addAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)())completionHandler
{
    [self.allAnnotationsMapView addAnnotations:annotations];
    [self updateAnnotationsWithCompletionHandler:completionHandler];
}

- (NSUInteger)numberOfAnnotations
{
    return self.allAnnotationsMapView.annotations.count;
}

- (void)updateAnnotationsWithCompletionHandler:(void (^)())completionHandler
{
    // Calculate cell size in map point units
    double cellSize = CCHMapClusterControllerMapLengthForLength(_mapView, _mapView.superview, _cellSize);
    
    // Expand map rect and align to cell size to avoid popping when panning
    MKMapRect visibleMapRect = _mapView.visibleMapRect;
    MKMapRect gridMapRect = MKMapRectInset(visibleMapRect, -_marginFactor * visibleMapRect.size.width, -_marginFactor * visibleMapRect.size.height);
    gridMapRect = CCHMapClusterControllerAlignToCellSize(gridMapRect, cellSize);
    MKMapRect cellMapRect = MKMapRectMake(0, MKMapRectGetMinY(gridMapRect), cellSize, cellSize);
    
    // For each cell in the grid, pick one annotation to show
    while (MKMapRectGetMinY(cellMapRect) < MKMapRectGetMaxY(gridMapRect)) {
        cellMapRect.origin.x = MKMapRectGetMinX(gridMapRect);
        
        while (MKMapRectGetMinX(cellMapRect) < MKMapRectGetMaxX(gridMapRect)) {
            NSSet *allAnnotationsInCell = [_allAnnotationsMapView annotationsInMapRect:cellMapRect];
            if (allAnnotationsInCell.count > 0) {
                NSMutableSet *visibleAnnotationsInCell = [[_mapView annotationsInMapRect:cellMapRect] mutableCopy];
                MKUserLocation *userLocation = _mapView.userLocation;
                if (userLocation) {
                    [visibleAnnotationsInCell removeObject:userLocation];
                }
                
                // Select cluster representation
                CCHMapClusterAnnotation *annotationForCell = _findVisibleAnnotation(allAnnotationsInCell, visibleAnnotationsInCell);
                if (annotationForCell == nil) {
                    annotationForCell = [[CCHMapClusterAnnotation alloc] init];
                    annotationForCell.coordinate = [_clusterer mapClusterController:self coordinateForAnnotations:allAnnotationsInCell inMapRect:cellMapRect];
                }
                annotationForCell.annotations = allAnnotationsInCell.allObjects;
                annotationForCell.delegate = _delegate;
                annotationForCell.title = nil;
                annotationForCell.subtitle = nil;
                
                // Show cluster annotation on map
                [visibleAnnotationsInCell removeObject:annotationForCell];
                [_animator mapClusterController:self removeAnnotations:visibleAnnotationsInCell];
                [_mapView addAnnotation:annotationForCell];
            }
            cellMapRect.origin.x += MKMapRectGetWidth(cellMapRect);
        }
        cellMapRect.origin.y += MKMapRectGetWidth(cellMapRect);
    }
    
    if (self.isDebuggingEnabled) {
        [_mapView removeOverlays:_mapView.overlays];
        MKMapPoint points[4];

        cellMapRect = MKMapRectMake(0, MKMapRectGetMinY(gridMapRect), cellSize, cellSize);
        while (MKMapRectGetMinY(cellMapRect) < MKMapRectGetMaxY(gridMapRect)) {
            cellMapRect.origin.x = MKMapRectGetMinX(gridMapRect);
            
            while (MKMapRectGetMinX(cellMapRect) < MKMapRectGetMaxX(gridMapRect)) {
                points[0] = MKMapPointMake(MKMapRectGetMinX(cellMapRect), MKMapRectGetMinY(cellMapRect));
                points[1] = MKMapPointMake(MKMapRectGetMaxX(cellMapRect), MKMapRectGetMinY(cellMapRect));
                points[2] = MKMapPointMake(MKMapRectGetMaxX(cellMapRect), MKMapRectGetMaxY(cellMapRect));
                points[3] = MKMapPointMake(MKMapRectGetMinX(cellMapRect), MKMapRectGetMaxY(cellMapRect));
                MKPolygon *polygon = [CCHMapClusterControllerPolygon polygonWithPoints:points count:4];
                [_mapView addOverlay:polygon];

                cellMapRect.origin.x += MKMapRectGetWidth(cellMapRect);
            }
            cellMapRect.origin.y += MKMapRectGetWidth(cellMapRect);
        }
    }
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)deselectAllAnnotations
{
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for (id<MKAnnotation> selectedAnnotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:selectedAnnotation animated:YES];
    }
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation andZoomToRegionWithLatitudinalMeters:(CLLocationDistance)latitudinalMeters longitudinalMeters:(CLLocationDistance)longitudinalMeters
{
    // Deselect annotations
    [self deselectAllAnnotations];
    
    // Zoom to annotation
    self.annotationToSelect = annotation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, latitudinalMeters, longitudinalMeters);
    [self.mapView setRegion:region animated:YES];
    if (CCHMapClusterControllerCoordinateEqualToCoordinate(region.center, self.mapView.centerCoordinate)) {
        // Manually call update methods because region won't change
        [self mapView:self.mapView regionWillChangeAnimated:YES];
        [self mapView:self.mapView regionDidChangeAnimated:YES];
    }
}

#pragma mark - Map view proxied delegate methods

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)annotationViews
{
    // Forward to standard delegate
    if ([self.mapViewDelegateProxy.target respondsToSelector:@selector(mapView:didAddAnnotationViews:)]) {
        [self.mapViewDelegateProxy.target mapView:mapView didAddAnnotationViews:annotationViews];
    }

    // Animate annotations that get added
    [self.animator mapClusterController:self didAddAnnotationViews:annotationViews];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // Forward to standard delegate
    if ([self.mapViewDelegateProxy.target respondsToSelector:@selector(mapView:regionWillChangeAnimated:)]) {
        [self.mapViewDelegateProxy.target mapView:mapView regionWillChangeAnimated:animated];
    }
    
    self.regionSpanBeforeChange = mapView.region.span;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // Forward to standard delegate
    if ([self.mapViewDelegateProxy.target respondsToSelector:@selector(mapView:regionDidChangeAnimated:)]) {
        [self.mapViewDelegateProxy.target mapView:mapView regionDidChangeAnimated:animated];
    }
    
    // Deselect all annotations when zooming in/out. Longitude delta will not change
    // unless zoom changes (in contrast to latitude delta).
    BOOL hasZoomed = !fequal(mapView.region.span.longitudeDelta, self.regionSpanBeforeChange.longitudeDelta);
    if (hasZoomed) {
        [self deselectAllAnnotations];
    }
    
    // Update annotations
    [self updateAnnotationsWithCompletionHandler:^{
        if (self.annotationToSelect) {
            // Map has zoomed to selected annotation; search for cluster annotation that contains this annotation
            CCHMapClusterAnnotation *mapClusterAnnotation = CCHMapClusterControllerClusterAnnotationForAnnotation(self.mapView, self.annotationToSelect, mapView.visibleMapRect);
            self.annotationToSelect = nil;
            
            if (CCHMapClusterControllerCoordinateEqualToCoordinate(self.mapView.centerCoordinate, mapClusterAnnotation.coordinate)) {
                // Select immediately since region won't change
                [self.mapView selectAnnotation:mapClusterAnnotation animated:YES];
            } else {
                // Actual selection happens in next call to mapView:regionDidChangeAnimated:
                self.mapClusterAnnotationToSelect = mapClusterAnnotation;
                
                // Dispatch async to avoid calling regionDidChangeAnimated immediately
                dispatch_async(dispatch_get_main_queue(), ^{
                    // No zooming, only panning. Otherwise, annotation might change to a different cluster annotation
                    [self.mapView setCenterCoordinate:mapClusterAnnotation.coordinate animated:NO];
                });
            }
        } else if (self.mapClusterAnnotationToSelect) {
            // Map has zoomed to annotation
            [self.mapView selectAnnotation:self.mapClusterAnnotationToSelect animated:YES];
            self.mapClusterAnnotationToSelect = nil;
        }
    }];
}

#if TARGET_OS_IPHONE
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    // Forward to standard delegate
    if ([self.mapViewDelegateProxy.target respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        [self.mapViewDelegateProxy.target mapView:mapView viewForOverlay:overlay];
    }

    // Display debug polygons
    MKOverlayView *view;
    if ([overlay isKindOfClass:CCHMapClusterControllerPolygon.class]) {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonView.strokeColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
        polygonView.lineWidth = 1;
        view = polygonView;
    }
    
    return view;
}
#else
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    // Forward to standard delegate
    if ([self.mapViewDelegateProxy.target respondsToSelector:@selector(mapView:rendererForOverlay:)]) {
        [self.mapViewDelegateProxy.target mapView:mapView rendererForOverlay:overlay];
    }
    
    // Display debug polygons
    MKOverlayRenderer *renderer;
    if ([overlay isKindOfClass:CCHMapClusterControllerPolygon.class]) {
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonRenderer.strokeColor = [NSColor.blueColor colorWithAlphaComponent:0.7];
        polygonRenderer.lineWidth = 1;
        renderer = polygonRenderer;
    }
    
    return renderer;
}
#endif

@end
