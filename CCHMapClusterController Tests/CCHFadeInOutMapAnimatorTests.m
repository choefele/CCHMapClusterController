//
//  CCHFadeInOutMapAnimatorTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 16.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerUtils.h"
#import "CCHFadeInOutMapAnimator.h"

@interface CCHFadeInOutMapAnimatorTests : XCTestCase

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CCHMapClusterController *mapClusterController;
@property (nonatomic, strong) CCHFadeInOutMapAnimator *animator;
@property (nonatomic, assign) BOOL done;

@end

@implementation CCHFadeInOutMapAnimatorTests

- (void)setUp
{
    [super setUp];

    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.animator = [[CCHFadeInOutMapAnimator alloc] init];
    self.mapClusterController.animator = _animator;
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

- (void)testFadeInOut
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(52.5, 13.5);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, MKCoordinateSpanMake(3, 3));
    self.mapView.region = region;
    
    __weak CCHFadeInOutMapAnimatorTests *weakSelf = self;
    [self.mapClusterController addAnnotations:@[annotation] withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqual(self.mapView.annotations.count, (NSUInteger)1, @"Wrong number of annotations");

    // Get the cluster UIView
    NSSet *annotationsInMapRect = [self.mapView annotationsInMapRect:self.mapView.visibleMapRect];
    XCTAssertEqual(annotationsInMapRect.count, (NSUInteger)1, @"Wrong number of annotations");

    CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotationsInMapRect.anyObject;
    UIView *clusterView = [self.mapView viewForAnnotation:clusterAnnotation];
    
    XCTAssert(clusterAnnotation, @"Expected a cluster");
    XCTAssert(clusterView, @"Expected a view");
    XCTAssertEqualWithAccuracy(clusterView.alpha, 1.0, __FLT_EPSILON__, @"Wrong alpha");
    
    // Fade Out
    self.done = NO;
    [self.mapClusterController removeAnnotations:@[annotation] withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqualWithAccuracy(clusterView.alpha, 0.0, __FLT_EPSILON__, @"Wrong alpha");

    // Fade In
    self.done = NO;
    [self.mapClusterController addAnnotations:@[annotation] withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqualWithAccuracy(clusterView.alpha, 1.0, __FLT_EPSILON__, @"Wrong alpha");
}

@end
