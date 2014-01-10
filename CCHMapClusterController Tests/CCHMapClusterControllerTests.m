//
//  CCHMapClusterControllerTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 16.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerUtils.h"

@interface CCHMapClusterControllerTests : XCTestCase

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CCHMapClusterController *mapClusterController;
@property (nonatomic, assign) BOOL done;

@end

@implementation CCHMapClusterControllerTests

- (void)setUp
{
    [super setUp];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.done = NO;
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if (timeoutDate.timeIntervalSinceNow < 0.0) {
            break;
        }
    } while (!self.done);
    
    return self.done;
}

- (void)testAddAnnotationsNil
{
    __weak CCHMapClusterControllerTests *weakSelf = self;
    [self.mapClusterController addAnnotations:nil withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqual(self.mapView.annotations.count, (NSUInteger)0, @"Wrong number of annotations");
}

- (void)testAddAnnotationsSimple
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52.5, 13.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(3, 3));
    self.mapView.region = region;
    
    __weak CCHMapClusterControllerTests *weakSelf = self;
    [self.mapClusterController addAnnotations:@[annotation] withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqual(self.mapView.annotations.count, (NSUInteger)1, @"Wrong number of annotations");
}

- (void)testAddAnnotations
{
    // 3x3 grid
    self.mapView.frame = CGRectMake(0, 0, 300, 300);
    self.mapClusterController.marginFactor = 0;
    self.mapClusterController.cellSize = 100;

    // Grid panning 51-54 lng, 12-15 lat
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5, 13.5), MKCoordinateSpanMake(3, 3));
    MKMapRect visibleMapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    self.mapView.visibleMapRect = visibleMapRect;

    // Bottom left
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(51.1, 12.1);
    
    // Top right
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
    annotation3.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation4 = [[MKPointAnnotation alloc] init];
    annotation4.coordinate = CLLocationCoordinate2DMake(53.9, 14.9);
    MKPointAnnotation *annotation5 = [[MKPointAnnotation alloc] init];
    annotation5.coordinate = CLLocationCoordinate2DMake(53.9, 14.6);

    NSArray *annotations = @[annotation0, annotation1, annotation2, annotation3, annotation4, annotation5];
    __weak CCHMapClusterControllerTests *weakSelf = self;
    [self.mapClusterController addAnnotations:annotations withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqual(self.mapView.annotations.count, (NSUInteger)2, @"Wrong number of annotations");

    // Origin MKCoordinateRegion -> bottom left, MKMapRect -> top left
    double cellWidth = visibleMapRect.size.width / 3;
    double cellHeight = visibleMapRect.size.height / 3;
    MKMapPoint cellOrigin = visibleMapRect.origin;

    // Bottom left
    MKMapRect bottomLeftMapRect = MKMapRectMake(cellOrigin.x, cellOrigin.y + 2 * cellHeight, cellWidth, cellHeight);
    NSSet *annotationsInMapRect = [self.mapView annotationsInMapRect:bottomLeftMapRect];
    XCTAssertEqual(annotationsInMapRect.count, (NSUInteger)1, @"Wrong number of annotations");
    CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotationsInMapRect.anyObject;
    XCTAssertEqual(clusterAnnotation.annotations.count, (NSUInteger)1, @"Wrong number of annotations");

    // Top right
    MKMapRect topRightMapRect = MKMapRectMake(cellOrigin.x + 2 * cellWidth, cellOrigin.y, cellWidth, cellHeight);
    annotationsInMapRect = [self.mapView annotationsInMapRect:topRightMapRect];
    XCTAssertEqual(annotationsInMapRect.count, (NSUInteger)1, @"Wrong number of annotations");
    clusterAnnotation = (CCHMapClusterAnnotation *)annotationsInMapRect.anyObject;
    XCTAssertEqual(clusterAnnotation.annotations.count, (NSUInteger)5, @"Wrong number of annotations");

    // Center
    MKMapRect middleMapRect = MKMapRectMake(cellOrigin.x + cellWidth, cellOrigin.y + cellHeight, cellWidth, cellHeight);
    annotationsInMapRect = [self.mapView annotationsInMapRect:middleMapRect];
    XCTAssertEqual(annotationsInMapRect.count, (NSUInteger)0, @"Wrong number of annotations");
}

@end
