//
//  MapClusterController.m
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

#define fequal(a, b) (fabs((a) - (b)) < __FLT_EPSILON__)
@interface CCHMapClusterControllerPolygon : MKPolygon
@end
@implementation CCHMapClusterControllerPolygon
@end

@interface CCHMapClusterController()<MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKMapView *allAnnotationsMapView;
@property (strong, nonatomic) CCHMapViewDelegateProxy *mapViewDelegateProxy;
@property (nonatomic, strong) id<MKAnnotation> annotationToSelect;
@property (nonatomic, strong) CCHMapClusterAnnotation *mapClusterAnnotationToSelect;
@property (nonatomic, assign) MKCoordinateSpan regionSpanBeforeChange;

@end

@implementation CCHMapClusterController

- (id)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        self.marginFactor = 0.5;
        self.cellSize = 60;
        self.mapView = mapView;
        self.allAnnotationsMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        self.mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:self];
    }
    return self;
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
    double cellSize = CCHMapClusterControllerMapLengthForLength(self.mapView, self.mapView.superview, self.cellSize);
    
    // Expand map rect and align to cell size to avoid popping when panning
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    MKMapRect gridMapRect = MKMapRectInset(visibleMapRect, -_marginFactor * visibleMapRect.size.width, -_marginFactor * visibleMapRect.size.height);
    gridMapRect = CCHMapClusterControllerAlignToCellSize(gridMapRect, cellSize);
    MKMapRect cellMapRect = MKMapRectMake(0, MKMapRectGetMinY(gridMapRect), cellSize, cellSize);
    
    // For each cell in the grid, pick one annotation to show
    while (MKMapRectGetMinY(cellMapRect) < MKMapRectGetMaxY(gridMapRect)) {
        cellMapRect.origin.x = MKMapRectGetMinX(gridMapRect);
        
        while (MKMapRectGetMinX(cellMapRect) < MKMapRectGetMaxX(gridMapRect)) {
            NSMutableSet *allAnnotationsInCell = [[self.allAnnotationsMapView annotationsInMapRect:cellMapRect] mutableCopy];
            if (allAnnotationsInCell.count > 0) {
                NSMutableSet *visibleAnnotationsInCell = [[self.mapView annotationsInMapRect:cellMapRect] mutableCopy];
                MKUserLocation *userLocation = self.mapView.userLocation;
                if (userLocation) {
                    [visibleAnnotationsInCell removeObject:userLocation];
                }
                
                CCHMapClusterAnnotation *annotationForCell = CCHMapClusterControllerFindAnnotation(cellMapRect, allAnnotationsInCell, visibleAnnotationsInCell);
                annotationForCell.annotations = allAnnotationsInCell.allObjects;
                annotationForCell.delegate = self.delegate;
                annotationForCell.title = nil;
                annotationForCell.subtitle = nil;
                
                [visibleAnnotationsInCell removeObject:annotationForCell];
                [self removeAnnotations:visibleAnnotationsInCell];
                [self.mapView addAnnotation:annotationForCell];
            }
            cellMapRect.origin.x += MKMapRectGetWidth(cellMapRect);
        }
        cellMapRect.origin.y += MKMapRectGetWidth(cellMapRect);
    }
    
    if (self.isDebuggingEnabled) {
        [self.mapView removeOverlays:self.mapView.overlays];
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
                [self.mapView addOverlay:polygon];

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

- (void)removeAnnotations:(NSSet *)annotations
{
    // Animate annotations that get removed
    for (id<MKAnnotation> annotation in annotations) {
#if TARGET_OS_IPHONE
        MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
        [UIView animateWithDuration:0.2 animations:^{
            annotationView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.mapView removeAnnotation:annotation];
        }];
#else
        [self.mapView removeAnnotation:annotation];
#endif
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
#if TARGET_OS_IPHONE
    for (MKAnnotationView *annotationView in annotationViews)
    {
        annotationView.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            annotationView.alpha = 1.0;
        }];
    }
#endif
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
