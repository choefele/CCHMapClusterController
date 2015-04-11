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

#define fequal(a, b) (fabs((a) - (b)) < __FLT_EPSILON__)

@interface CCHMapClusterOperation()

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) double cellSize;
@property (nonatomic) double cellMapSize;
@property (nonatomic) double marginFactor;
@property (nonatomic) MKMapRect mapViewVisibleMapRect;
@property (nonatomic) MKCoordinateRegion mapViewRegion;
@property (nonatomic) CGFloat mapViewWidth;
@property (nonatomic, copy) NSArray *mapViewAnnotations;
@property (nonatomic) BOOL reuseExistingClusterAnnotations;
@property (nonatomic) double maxZoomLevelForClustering;
@property (nonatomic) NSUInteger minUniqueLocationsForClustering;

@property (nonatomic, getter = isExecuting) BOOL executing;
@property (nonatomic, getter = isFinished) BOOL finished;

@end

@implementation CCHMapClusterOperation

@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize clusterMethod;


- (instancetype)initWithMapView:(MKMapView *)mapView cellSize:(double)cellSize marginFactor:(double)marginFactor reuseExistingClusterAnnotations:(BOOL)reuseExistingClusterAnnotation maxZoomLevelForClustering:(double)maxZoomLevelForClustering minUniqueLocationsForClustering:(NSUInteger)minUniqueLocationsForClustering
{
    self = [super init];
    if (self) {
        _mapView = mapView;
		_cellSize = cellSize;
        _cellMapSize = [self.class cellMapSizeForCellSize:cellSize withMapView:mapView];
        _marginFactor = marginFactor;
        _mapViewVisibleMapRect = mapView.visibleMapRect;
        _mapViewRegion = mapView.region;
        _mapViewWidth = mapView.bounds.size.width;
        _mapViewAnnotations = mapView.annotations;
        _reuseExistingClusterAnnotations = reuseExistingClusterAnnotation;
        _maxZoomLevelForClustering = maxZoomLevelForClustering;
        _minUniqueLocationsForClustering = minUniqueLocationsForClustering;
        
        _executing = NO;
        _finished = NO;
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


- (MKZoomScale) currentZoomScale
{
	CGSize screenSize = self.mapView.bounds.size;
	MKMapRect mapRect = self.mapView.visibleMapRect;
	MKZoomScale zoomScale = screenSize.width / mapRect.size.width;
	return zoomScale;
}


+ (double) distanceSquared:(MKMapPoint)a b:(MKMapPoint)b {
	return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}


+ (MKMapRect) createBoundsFromSpan:(MKMapPoint)p span:(double)span {
	double halfSpan = span / 2;
	return MKMapRectMake(p.x - halfSpan, p.y - halfSpan, span, span);
}



- (void)start
{
	switch (self.clusterMethod) {
		case ClusterMethodGridBased:
			[self start_grid];
			break;
		case ClusterMethodDistanceBased:
			[self start_distance];
			break;
	};
}



// A simple clustering algorithm with O(nlog n) performance. Resulting clusters are not
// hierarchical. Contributed by GitHub user __amishjake__.
// Steps:
// 1. Iterate over candidate annotations.
// 2. Create/re-use a CCHMapClusterAnnotation with the center of the annotation.
// 3. Add all annotations that are within a certain distance to the cluster.
// 4. Move any annotations out of an existing cluster if they are closer to another cluster.
// 5. Remove those items from the list of candidate clusters.
// 6. Add/remove items on the actual map as in the grid algorithm.
//
- (void) start_distance
{
	self.executing = YES;
	
	BOOL respondsToSelector = [_clusterControllerDelegate respondsToSelector:@selector(mapClusterController:willReuseMapClusterAnnotation:)];

	double zoomLevel = CCHMapClusterControllerZoomLevelForRegion(self.mapViewRegion.center.longitude, self.mapViewRegion.span.longitudeDelta, self.mapViewWidth);
	BOOL disableClustering = (zoomLevel > self.maxZoomLevelForClustering);

	// Zoom scale * MK distance = screen points
	MKZoomScale zoomScale = [self currentZoomScale];
	
	// The width and height of the square around a point that we'll consider later
	double zoomSpecificSpan = _cellSize / zoomScale;
	
	// Annotations we've already looked at for a starting point for a cluster
	NSMutableSet *visitedCandidates = [[NSMutableSet alloc] init];

	// The MKAnnotations (single POIs and clusters alike) we want on display
	NSMutableSet *results = [[NSMutableSet alloc] init];
	
	// Map a single POI MKAnnotation to its distance (NSNumber*) from its cluster (if added to one yet)
	NSMapTable *distanceToCluster = [NSMapTable strongToStrongObjectsMapTable];
	
	// Map a single POI MKAnnotation to its cluster annotation (if added to one yet)
	NSMapTable *itemToCluster = [NSMapTable strongToStrongObjectsMapTable];

	// Existing annotations to re-use
	NSMutableSet *annotationsToReuse = [NSMutableSet setWithSet:[_visibleAnnotationsMapTree annotationsInMapRect:self.mapView.visibleMapRect]];
	//NSMutableSet *annotationsToReuse = [NSMutableSet setWithSet:[_visibleAnnotationsMapTree annotations]];
	
	// The CCHMapClusterAnnotations that are being reused
	NSMutableSet *reusedAnnotations = [NSMutableSet setWithSet:[_visibleAnnotationsMapTree annotations]];
	
	@synchronized(_allAnnotationsMapTree) {
		
		// Iterate over all POIs we know about
		for (id<MKAnnotation> candidate in _allAnnotationsMapTree.annotations) {
			
			if ([visitedCandidates containsObject:candidate]) {
				// Candidate is already part of another cluster.
				continue;
			}
				
			// searchBounds is a rectangle of size zoomSpecificSpan (map x and y,
			// not LatLng), centered on the candidate item's point
			MKMapPoint point = MKMapPointForCoordinate(candidate.coordinate);
			MKMapRect searchBounds = [self.class createBoundsFromSpan:point span:zoomSpecificSpan];
			
			// Get list of MKAnnotations in that bounds
			NSSet *clusterItems = [_allAnnotationsMapTree annotationsInMapRect:searchBounds];
			
			CCHMapClusterAnnotation *cluster;

			if (_reuseExistingClusterAnnotations) {
				// Check if an existing cluster annotation can be reused
				cluster = CCHMapClusterControllerFindVisibleAnnotation(clusterItems, annotationsToReuse);
				
				// For unique locations, coordinate has to match as well
				//if (annotationForCell && annotationSetsAreUniqueLocations) {
				//	BOOL coordinateMatches = fequal(coordinate.latitude, annotationForCell.coordinate.latitude) && fequal(coordinate.longitude, annotationForCell.coordinate.longitude);
				//	annotationForCell = coordinateMatches ? annotationForCell : nil;
				//}
			}
			
			if (cluster == nil) {
				// Create new cluster annotation
				cluster = [[CCHMapClusterAnnotation alloc] init];
				cluster.mapClusterController = _clusterController;
				cluster.delegate = _clusterControllerDelegate;
			}
			else {
				[reusedAnnotations addObject:cluster];
				[annotationsToReuse removeObject:cluster];
			}
			
			// Cluster takes coordinate of first found annotation
			cluster.coordinate = candidate.coordinate;
			cluster.annotations = [[NSSet alloc] init];
			
			if (clusterItems.count == 1) {
				// Only the current marker is in range. Just add the single item to the results.
				cluster.annotations = [cluster.annotations setByAddingObject:candidate];
				[results addObject:cluster];
				[visitedCandidates addObject:candidate];
				[distanceToCluster setObject:[NSNumber numberWithDouble:0.0] forKey:candidate];
				continue;
			}

			// Add the cluster of several annotations to the results
			[results addObject:cluster];
			
			// Iterate items in the bounds box
			for (id<MKAnnotation> clusterItem in clusterItems) {
				
				// This item may already be associated with another cluster,
				// in which case we can know its distance from that cluster
				NSNumber *existingDistance = [distanceToCluster objectForKey:clusterItem];
				
				// Get distance from the new cluster location we're working on
				double distance = [self.class distanceSquared:MKMapPointForCoordinate(clusterItem.coordinate) b:MKMapPointForCoordinate(candidate.coordinate)];
				
				if (existingDistance != nil) {
					// Item already belongs to another cluster. Check if it's closer to this cluster.
					if ([existingDistance doubleValue] <= distance) {
						// next clusterItem
						continue;
					}
					// Remove from previous cluster.
					CCHMapClusterAnnotation *prevCluster = [itemToCluster objectForKey:clusterItem];
					if (prevCluster != nil) {
						NSMutableSet *set = [NSMutableSet setWithSet:prevCluster.annotations];
						[set minusSet:[NSSet setWithObject:clusterItem]];
						prevCluster.annotations = set;
					}
					
				}
					
				// Record new distance
				[distanceToCluster setObject:[NSNumber numberWithDouble:distance] forKey:clusterItem];
					
				// Add item to the cluster we're working on
				cluster.annotations = [cluster.annotations setByAddingObject:clusterItem];
					
				// Update mapping in our item-to-cluster map.
				[itemToCluster setObject:cluster forKey:clusterItem];
			}
				
			// Mark all of them visited so we don't start considering them again
			[visitedCandidates addObjectsFromArray:[clusterItems allObjects]];
		}
	}

	// Tell client to reconfigure all annotations that we are re-using
	for (CCHMapClusterAnnotation* anno in reusedAnnotations) {
		dispatch_async(dispatch_get_main_queue(), ^{
			anno.title = nil;
			anno.subtitle = nil;
			if (respondsToSelector) {
				[_clusterControllerDelegate mapClusterController:_clusterController willReuseMapClusterAnnotation:anno];
			}
		});
	}
	
	// Figure out difference between new and old clusters
	NSSet *annotationsBeforeAsSet = CCHMapClusterControllerClusterAnnotationsForAnnotations(self.mapViewAnnotations, self.clusterController);
	NSMutableSet *annotationsToKeep = [NSMutableSet setWithSet:annotationsBeforeAsSet];
	[annotationsToKeep intersectSet:results];
	NSMutableSet *annotationsToAddAsSet = [NSMutableSet setWithSet:results];
	[annotationsToAddAsSet minusSet:annotationsToKeep];
	NSArray *annotationsToAdd = [annotationsToAddAsSet allObjects];
	NSMutableSet *annotationsToRemoveAsSet = [NSMutableSet setWithSet:annotationsBeforeAsSet];
	[annotationsToRemoveAsSet minusSet:results];
	NSArray *annotationsToRemove = [annotationsToRemoveAsSet allObjects];
	
	// Show cluster annotations on map
	[_visibleAnnotationsMapTree removeAnnotations:annotationsToRemove];
	[_visibleAnnotationsMapTree addAnnotations:annotationsToAdd];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.mapView addAnnotations:annotationsToAdd];
		[self.animator mapClusterController:self.clusterController willRemoveAnnotations:annotationsToRemove withCompletionHandler:^{
			[self.mapView removeAnnotations:annotationsToRemove];
			
			self.executing = NO;
			self.finished = YES;
		}];
	});
}


// Original Grid-based algorithm
- (void)start_grid
{
    self.executing = YES;
	
    double zoomLevel = CCHMapClusterControllerZoomLevelForRegion(self.mapViewRegion.center.longitude, self.mapViewRegion.span.longitudeDelta, self.mapViewWidth);
    BOOL disableClustering = (zoomLevel > self.maxZoomLevelForClustering);
    BOOL respondsToSelector = [_clusterControllerDelegate respondsToSelector:@selector(mapClusterController:willReuseMapClusterAnnotation:)];
	
    // For each cell in the grid, pick one cluster annotation to show
    MKMapRect gridMapRect = [self.class gridMapRectForMapRect:self.mapViewVisibleMapRect withCellMapSize:self.cellMapSize marginFactor:self.marginFactor];
    NSMutableSet *clusters = [NSMutableSet set];
    CCHMapClusterControllerEnumerateCells(gridMapRect, _cellMapSize, ^(MKMapRect cellMapRect) {
        NSSet *allAnnotationsInCell = [_allAnnotationsMapTree annotationsInMapRect:cellMapRect];
		
        if (allAnnotationsInCell.count > 0) {
            BOOL annotationSetsAreUniqueLocations;
            NSArray *annotationSets;
            if (disableClustering) {
                // Create annotation for each unique location because clustering is disabled
                annotationSets = CCHMapClusterControllerAnnotationSetsByUniqueLocations(allAnnotationsInCell, NSUIntegerMax);
                annotationSetsAreUniqueLocations = YES;
            } else {
                NSUInteger max = _minUniqueLocationsForClustering > 1 ? _minUniqueLocationsForClustering - 1 : 1;
                annotationSets = CCHMapClusterControllerAnnotationSetsByUniqueLocations(allAnnotationsInCell, max);
                if (annotationSets) {
                    // Create annotation for each unique location because there are too few locations for clustering
                    annotationSetsAreUniqueLocations = YES;
                } else {
                    // Create one annotation for entire cell
                    annotationSets = @[allAnnotationsInCell];
                    annotationSetsAreUniqueLocations = NO;
                }
            }

            NSMutableSet *visibleAnnotationsInCell = [NSMutableSet setWithSet:[_visibleAnnotationsMapTree annotationsInMapRect:cellMapRect]];
            for (NSSet *annotationSet in annotationSets) {
                CLLocationCoordinate2D coordinate;
                if (annotationSetsAreUniqueLocations) {
                    coordinate = [annotationSet.anyObject coordinate];
                } else {
                    coordinate = [_clusterer mapClusterController:_clusterController coordinateForAnnotations:annotationSet inMapRect:cellMapRect];
                }
                
                CCHMapClusterAnnotation *annotationForCell;
                if (_reuseExistingClusterAnnotations) {
                    // Check if an existing cluster annotation can be reused
                    annotationForCell = CCHMapClusterControllerFindVisibleAnnotation(annotationSet, visibleAnnotationsInCell);
                    
                    // For unique locations, coordinate has to match as well
                    if (annotationForCell && annotationSetsAreUniqueLocations) {
                        BOOL coordinateMatches = fequal(coordinate.latitude, annotationForCell.coordinate.latitude) && fequal(coordinate.longitude, annotationForCell.coordinate.longitude);
                        annotationForCell = coordinateMatches ? annotationForCell : nil;
                    }
                }
                
                if (annotationForCell == nil) {
                    // Create new cluster annotation
                    annotationForCell = [[CCHMapClusterAnnotation alloc] init];
                    annotationForCell.mapClusterController = _clusterController;
                    annotationForCell.delegate = _clusterControllerDelegate;
                    annotationForCell.annotations = annotationSet;
                    annotationForCell.coordinate = coordinate;
                } else {
                    // For an existing cluster annotation, this will implicitly update its annotation view
                    [visibleAnnotationsInCell removeObject:annotationForCell];
                    annotationForCell.annotations = annotationSet;
                    dispatch_async(dispatch_get_main_queue(), ^{
						// 3/24/15
						//if (annotationSetsAreUniqueLocations) {
                            annotationForCell.coordinate = coordinate;
                        //}
                        annotationForCell.title = nil;
                        annotationForCell.subtitle = nil;
                        if (respondsToSelector) {
                            [_clusterControllerDelegate mapClusterController:_clusterController willReuseMapClusterAnnotation:annotationForCell];
                        }
                    });
                }
                
                // Collect cluster annotations
                [clusters addObject:annotationForCell];
            }
        }
    });
    
    // Figure out difference between new and old clusters
    NSSet *annotationsBeforeAsSet = CCHMapClusterControllerClusterAnnotationsForAnnotations(self.mapViewAnnotations, self.clusterController);
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
            
            self.executing = NO;
            self.finished = YES;
        }];
    });
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end
