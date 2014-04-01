//
//  CCHMapClusterOperation.m
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

#import "CCHMapClusterOperation.h"

#import "CCHMapTree.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerUtils.h"
#import "CCHMapClusterer.h"
#import "CCHMapAnimator.h"
#import "CCHMapClusterControllerDelegate.h"

@interface CCHMapClusterOperation()

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) double cellMapSize;
@property (nonatomic, assign) double marginFactor;
@property (nonatomic, assign) MKMapRect visibleMapRect;
@property (nonatomic, assign) BOOL reuseExistingClusterAnnotations;

@end

@implementation CCHMapClusterOperation

- (id)initWithMapView:(MKMapView *)mapView cellSize:(double)cellSize marginFactor:(double)marginFactor reuseExistingClusterAnnotations:(BOOL)reuseExistingClusterAnnotation
{
    self = [super init];
    if (self) {
        _mapView = mapView;
        _cellMapSize = [self.class cellMapSizeForCellSize:cellSize withMapView:mapView];
        _marginFactor = marginFactor;
        _visibleMapRect = mapView.visibleMapRect;
        _reuseExistingClusterAnnotations = reuseExistingClusterAnnotation;
    }
    
    return self;
}

+ (double)cellMapSizeForCellSize:(double)cellSize withMapView:(MKMapView *)mapView
{
    // World size is multiple of cell size so that cells wrap around at the 180th meridian
    double cellMapSize = CCHMapClusterControllerMapLengthForLength(mapView, mapView.superview, cellSize);
    cellMapSize = CCHMapClusterControllerAlignMapLengthToWorldWidth(cellMapSize);
    
    return cellMapSize;
}

+ (MKMapRect)gridMapRectForMapRect:(MKMapRect)mapRect withCellMapSize:(double)cellMapSize marginFactor:(double)marginFactor
{
    // Expand map rect and align to cell size to avoid popping when panning
    MKMapRect gridMapRect = MKMapRectInset(mapRect, -marginFactor * mapRect.size.width, -marginFactor * mapRect.size.height);
    gridMapRect = CCHMapClusterControllerAlignMapRectToCellSize(gridMapRect, cellMapSize);
    
    return gridMapRect;
}

- (void)main
{
    // For each cell in the grid, pick one cluster annotation to show
    MKMapRect gridMapRect = [self.class gridMapRectForMapRect:self.visibleMapRect withCellMapSize:self.cellMapSize marginFactor:self.marginFactor];
    NSMutableSet *clusters = [NSMutableSet set];
    CCHMapClusterControllerEnumerateCells(gridMapRect, _cellMapSize, ^(MKMapRect cellMapRect) {
        NSSet *allAnnotationsInCell = [_allAnnotationsMapTree annotationsInMapRect:cellMapRect];
        if (allAnnotationsInCell.count > 0) {
            CCHMapClusterAnnotation *annotationForCell;
            
            if (_reuseExistingClusterAnnotations) {
                // Check if an existing cluster annotation can be reused
                NSSet *visibleAnnotationsInCell = [_visibleAnnotationsMapTree annotationsInMapRect:cellMapRect];
                annotationForCell = CCHMapClusterControllerFindVisibleAnnotation(allAnnotationsInCell, visibleAnnotationsInCell);
            }
            
            if (annotationForCell == nil) {
                // Create new cluster annotation
                annotationForCell = [[CCHMapClusterAnnotation alloc] init];
                annotationForCell.mapClusterController = _clusterController;
                annotationForCell.coordinate = [_clusterer mapClusterController:_clusterController coordinateForAnnotations:allAnnotationsInCell inMapRect:cellMapRect];
                annotationForCell.delegate = _delegate;
                annotationForCell.annotations = allAnnotationsInCell;
            } else {
                // For an existing cluster annotation, this will implicitly update its annotation view
                dispatch_async(dispatch_get_main_queue(), ^{
                    annotationForCell.annotations = allAnnotationsInCell;
                    annotationForCell.title = nil;
                    annotationForCell.subtitle = nil;
                    if ([_delegate respondsToSelector:@selector(mapClusterController:willReuseMapClusterAnnotation:)]) {
                        [_delegate mapClusterController:_clusterController willReuseMapClusterAnnotation:annotationForCell];
                    }
                });
            }
            
            // Collect cluster annotations
            [clusters addObject:annotationForCell];
        }
    });
    
    // Figure out difference between new and old clusters
    NSSet *annotationsBeforeAsSet = CCHMapClusterControllerClusterAnnotationsForAnnotations(self.mapView.annotations, self.clusterController);
    NSMutableSet *annotationsToKeep = [NSMutableSet setWithSet:annotationsBeforeAsSet];
    [annotationsToKeep intersectSet:clusters];
    NSMutableSet *annotationsToAddAsSet = [NSMutableSet setWithSet:clusters];
    [annotationsToAddAsSet minusSet:annotationsToKeep];
    NSArray *annotationsToAdd = [annotationsToAddAsSet allObjects];
    NSMutableSet *annotationsToRemoveAsSet = [NSMutableSet setWithSet:annotationsBeforeAsSet];
    [annotationsToRemoveAsSet minusSet:clusters];
    NSArray *annotationsToRemove = [annotationsToRemoveAsSet allObjects];
    
    // Show cluster annotations on map
    [_visibleAnnotationsMapTree removeAnnotations:annotationsToRemove];
    [_visibleAnnotationsMapTree addAnnotations:annotationsToAdd];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:annotationsToAdd];
        [self.animator mapClusterController:self.clusterController willRemoveAnnotations:annotationsToRemove withCompletionHandler:^{
            [self.mapView removeAnnotations:annotationsToRemove];
            
            if (self.completionHandler) {
                self.completionHandler();
            }
        }];
    });
}

@end
