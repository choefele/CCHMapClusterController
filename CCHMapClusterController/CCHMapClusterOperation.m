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


@end

@implementation CCHMapClusterOperation

- (void)main
{
    // For each cell in the grid, pick one annotation to show
    NSMutableSet *clusters = [NSMutableSet set];
    CCHMapClusterControllerEnumerateCells(self.gridMapRect, self.cellSize, ^(MKMapRect cellRect) {
        NSSet *allAnnotationsInCell = [_allAnnotationsMapTree annotationsInMapRect:cellRect];
        if (allAnnotationsInCell.count > 0) {
            // Select cluster representation
            NSSet *visibleAnnotationsInCell = [_visibleAnnotationsMapTree annotationsInMapRect:cellRect];
            CCHMapClusterAnnotation *annotationForCell = _findVisibleAnnotation(allAnnotationsInCell, visibleAnnotationsInCell);
            if (annotationForCell == nil) {
                annotationForCell = [[CCHMapClusterAnnotation alloc] init];
                annotationForCell.mapClusterController = self.clusterController;
                annotationForCell.coordinate = [_clusterer mapClusterController:self.clusterController coordinateForAnnotations:allAnnotationsInCell inMapRect:cellRect];
                annotationForCell.delegate = _delegate;
                annotationForCell.annotations = allAnnotationsInCell;
            } else {
                // For existing annotations, this will implicitly update annotation views
                dispatch_async(dispatch_get_main_queue(), ^{
                    annotationForCell.annotations = allAnnotationsInCell;
                    annotationForCell.title = nil;
                    annotationForCell.subtitle = nil;
                    if ([self.delegate respondsToSelector:@selector(mapClusterController:willReuseMapClusterAnnotation:)]) {
                        [self.delegate mapClusterController:self.clusterController willReuseMapClusterAnnotation:annotationForCell];
                    }
                });
            }
            
            // Collect clusters
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
