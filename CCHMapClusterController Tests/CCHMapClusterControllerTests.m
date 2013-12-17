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

@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CCHMapClusterController *mapClusterController;
@property (nonatomic, assign) BOOL done;

@end

@implementation CCHMapClusterControllerTests

- (void)setUp
{
    [super setUp];

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [self.view addSubview:self.mapView];
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
    XCTAssertEqual(self.mapView.annotations.count, 0u, @"Wrong number of annotations");
}

- (void)testAddAnnotationsSimple
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    __weak CCHMapClusterControllerTests *weakSelf = self;
    [self.mapClusterController addAnnotations:@[annotation] withCompletionHandler:^{
        weakSelf.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqual(self.mapView.annotations.count, 1u, @"Wrong number of annotations");
}

- (void)testAddAnnotations
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.516221, 13.377829);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 45000, 45000);
    MKMapRect mapRect = CCHMapClusterControllerMapRectForCoordinateRegion(region);
    self.mapView.visibleMapRect = mapRect;
    
    // Read test data
    NSString *file = [NSBundle.mainBundle pathForResource:@"Data" ofType:@"json"];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:file];
    [inputStream open];
    NSArray *dataAsJson = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:nil];
    
    // Convert JSON into annotation objects
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSDictionary *annotationAsJSON in dataAsJson) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        NSString *latitudeAsString = [annotationAsJSON valueForKeyPath:@"location.coordinates.latitude"];
        NSString *longitudeAsString = [annotationAsJSON valueForKeyPath:@"location.coordinates.longitude"];
        annotation.coordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);
        
        [annotations addObject:annotation];
    }

    __weak CCHMapClusterControllerTests *weakSelf = self;
    [self.mapClusterController addAnnotations:annotations withCompletionHandler:^{
        weakSelf.done = YES;
    }];

    XCTAssertTrue([self waitForCompletion:1.0], @"Time out");
    XCTAssertEqual(self.mapView.annotations.count, 18u, @"Wrong number of annotations");
    
    NSUInteger numClusteredAnnotations = 0;
    for (CCHMapClusterAnnotation *annotation in self.mapView.annotations) {
        numClusteredAnnotations += annotation.annotations.count;
    }
    XCTAssertEqual(numClusteredAnnotations, annotations.count, @"Wrong number of clustered annotations");
}

@end
