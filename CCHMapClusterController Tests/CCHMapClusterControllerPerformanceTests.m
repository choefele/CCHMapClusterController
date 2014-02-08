//
//  CCHMapClusterControllerPerformanceTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 12.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHMapClusterControllerUtils.h"
#import "KPAnnotationTree.h"
#import "TBQuadTree.h"
#import "QTree.h"

#include <mach/mach_time.h>

#define NUM_PASSES 1

@interface QTreeAnnotation : MKPointAnnotation<QTreeInsertable>
@end

@interface CCHMapClusterControllerPerformanceTests : XCTestCase

@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, assign) MKMapRect mapRect;
@property (nonatomic, assign) double cellSize;
@property (nonatomic, strong) NSArray *clusterCounts;

@end

@implementation CCHMapClusterControllerPerformanceTests

- (void)setUp
{
    [super setUp];
    
    // Read test data
    NSString *file = [NSBundle.mainBundle pathForResource:@"Berlin-Data" ofType:@"json"];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:file];
    [inputStream open];
    NSArray *dataAsJson = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:nil];
    
    // Convert JSON into annotation objects
    self.annotations = [NSMutableArray array];
    for (NSDictionary *annotationAsJSON in dataAsJson) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        NSString *latitudeAsString = [annotationAsJSON valueForKeyPath:@"location.coordinates.latitude"];
        NSString *longitudeAsString = [annotationAsJSON valueForKeyPath:@"location.coordinates.longitude"];
        annotation.coordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);
        
        [self.annotations addObject:annotation];
    }
    
    // Captured by running example app on Retina 4 inch device and zooming in three times
    self.cellSize = 15359.999231;
    self.mapRect = MKMapRectMake(144122872.779819, 87920635.595405, 168959.991536, 276479.986149);
    self.clusterCounts = @[@(1), @(3), @(4), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(4), @(5), @(11), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(3), @(7), @(4), @(5), @(0), @(4), @(0), @(0), @(0), @(0), @(0), @(2), @(13), @(3), @(4), @(5), @(8), @(6), @(0), @(0), @(0), @(0), @(0), @(0), @(3), @(32), @(25), @(29), @(14), @(3), @(3), @(0), @(0), @(1), @(0), @(0), @(15), @(14), @(23), @(40), @(17), @(1), @(12), @(1), @(0), @(13), @(28), @(2), @(2), @(168), @(153), @(29), @(1), @(5), @(0), @(43), @(7), @(224), @(15), @(4), @(110), @(83), @(62), @(58), @(7), @(3), @(271), @(477), @(89), @(52), @(12), @(65), @(192), @(46), @(36), @(16), @(7), @(150), @(169), @(508), @(144), @(37), @(65), @(160), @(31), @(16), @(0), @(0), @(14), @(21), @(158), @(49), @(21), @(6), @(27), @(59), @(7), @(0), @(0), @(5), @(61), @(122), @(0), @(6), @(1), @(1), @(25), @(3), @(1), @(9), @(5), @(10), @(23), @(2), @(2), @(0), @(0), @(7), @(0), @(1), @(0), @(32), @(11), @(7), @(4), @(3), @(2), @(0), @(3), @(2), @(0), @(3), @(8), @(15), @(7), @(0), @(0), @(1), @(0), @(0), @(0), @(0), @(0), @(1), @(0), @(0), @(0), @(7), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(1), @(1), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0), @(1), @(9), @(1), @(0), @(0), @(0), @(0)];
}

double performAndTrackTime(int numPasses, dispatch_block_t block)
{
    uint64_t startTime = mach_absolute_time();
    for (int i = 0; i < numPasses; i++) {
        block();
    }
    uint64_t endTime = mach_absolute_time();
    
    // Elapsed time in mach time units
    uint64_t elapsedTime = endTime - startTime;
    
    // The first time we get here, ask the system
    // how to convert mach time units to nanoseconds
    static double ticksToNanoseconds = 0.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mach_timebase_info_data_t timebase;
        mach_timebase_info(&timebase);
        ticksToNanoseconds = (double)timebase.numer / timebase.denom;
    });
    
    double elapsedTimeInNanoseconds = (elapsedTime * ticksToNanoseconds) / numPasses;
    return elapsedTimeInNanoseconds;
}

- (void)testMKMapView
{
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [mapView addAnnotations:self.annotations];
    double cellSize = self.cellSize;
    MKMapRect mapRect = self.mapRect;
    
    double duration = performAndTrackTime(NUM_PASSES, ^{
        NSMutableArray *clusterCounts = [NSMutableArray array];
        CCHMapClusterControllerEnumerateCells(mapRect, cellSize, ^(MKMapRect cellRect) {
            NSSet *allAnnotationsInCell = [mapView annotationsInMapRect:cellRect];
            
            [clusterCounts addObject:@(allAnnotationsInCell.count)];
        });
        
        XCTAssertEqual(self.clusterCounts.count, (NSUInteger)198);
        XCTAssertEqualObjects(clusterCounts, self.clusterCounts);
    });

    NSLog(@"Duration %@: %f ms", NSStringFromSelector(_cmd), duration / 1E6);
}

- (void)testKPAnnotationTree
{
    KPAnnotationTree *tree = [[KPAnnotationTree alloc] initWithAnnotations:self.annotations];
    double cellSize = self.cellSize;
    MKMapRect mapRect = self.mapRect;
    
    double duration = performAndTrackTime(NUM_PASSES, ^{
        NSMutableArray *clusterCounts = [NSMutableArray array];
        CCHMapClusterControllerEnumerateCells(mapRect, cellSize, ^(MKMapRect cellRect) {
            NSArray *allAnnotationsInCell = [tree annotationsInMapRect:cellRect];
            
            [clusterCounts addObject:@(allAnnotationsInCell.count)];
        });
        
        XCTAssertEqual(self.clusterCounts.count, (NSUInteger)198);
        XCTAssertEqualObjects(clusterCounts, self.clusterCounts);
    });
    
    NSLog(@"Duration %@: %f ms", NSStringFromSelector(_cmd), duration / 1E6);
}

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

- (void)testTBQuadTree
{
    NSUInteger count = self.annotations.count;
    TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
    for (NSInteger i = 0; i < count; i++) {
        id<MKAnnotation> annotation = self.annotations[i];
        dataArray[i] = TBQuadTreeNodeDataMake(annotation.coordinate.latitude, annotation.coordinate.longitude, (__bridge void*)annotation);
    }

    TBBoundingBox world = TBBoundingBoxMake(50, 10, 60, 20); // minLat, minLon, maxLat, maxLon
    TBQuadTreeNode *root = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);

    double cellSize = self.cellSize;
    MKMapRect mapRect = self.mapRect;
    
    double duration = performAndTrackTime(NUM_PASSES, ^{
        NSMutableArray *clusterCounts = [NSMutableArray array];
        CCHMapClusterControllerEnumerateCells(mapRect, cellSize, ^(MKMapRect cellRect) {
            NSMutableArray *allAnnotationsInCell = [NSMutableArray array];
            TBQuadTreeGatherDataInRange(root, TBBoundingBoxForMapRect(cellRect), ^(TBQuadTreeNodeData data) {
                [allAnnotationsInCell addObject:(__bridge id)data.data];
            });
            
            [clusterCounts addObject:@(allAnnotationsInCell.count)];
        });
        
        XCTAssertEqual(self.clusterCounts.count, (NSUInteger)198);
        XCTAssertEqualObjects(clusterCounts, self.clusterCounts);
    });
    
//    // Will also free data - bug?
//    TBFreeQuadTreeNode(root);
    
    NSLog(@"Duration %@: %f ms", NSStringFromSelector(_cmd), duration / 1E6);
}

- (void)testQTree
{
    QTree *tree = [[QTree alloc] init];
    for (QTreeAnnotation *annotation in self.annotations) {
        [tree insertObject:annotation];
    }

    double cellSize = self.cellSize;
    MKMapRect mapRect = self.mapRect;
    
    double duration = performAndTrackTime(NUM_PASSES, ^{
        NSMutableArray *clusterCounts = [NSMutableArray array];
        CCHMapClusterControllerEnumerateCells(mapRect, cellSize, ^(MKMapRect cellRect) {
            MKCoordinateRegion region = MKCoordinateRegionForMapRect(cellRect);
            NSArray* allAnnotationsInCell = [tree getObjectsInRegion:region minNonClusteredSpan:0];
            
            [clusterCounts addObject:@(allAnnotationsInCell.count)];
        });
        
        XCTAssertEqual(self.clusterCounts.count, (NSUInteger)198);
        XCTAssertEqualObjects(clusterCounts, self.clusterCounts);
    });
    
    NSLog(@"Duration %@: %f ms", NSStringFromSelector(_cmd), duration / 1E6);
}

@end
