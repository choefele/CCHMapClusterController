//
//  CCHMapViewDelegateProxyReturnValueTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus on 18.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MapKit/MapKit.h>

#import "CCHMapViewDelegateProxy.h"

#define DEBUG_POLYGON_CLASS NSClassFromString(@"CCHMapClusterControllerDebugPolygon")
#define DUMMY_POLYGON_CLASS MKOverlayView.class

#if TARGET_OS_IPHONE
@interface MapViewDelegateReturnsValue : NSObject<MKMapViewDelegate>
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnsValue
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    return [[DUMMY_POLYGON_CLASS alloc] init];
}
@end

@interface MapViewDelegateReturnsNil : NSObject<MKMapViewDelegate>
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnsNil
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    return nil;
}
@end

@interface MapViewDelegateEmpty : NSObject<MKMapViewDelegate>
@end
@implementation MapViewDelegateEmpty
@end
#endif

// MKMapViewDelegate no viewForOverlay:
// MKMapViewDelegate viewForOverlay: returns nil
// MKMapViewDelegate viewForOverlay: returns object -> ok
// MKMapViewDelegate nil

// Refactor CCHMapViewDelegateProxy to check for return value then stop invocation
// Test 4x4 matrix
// Remove DEBUG_POLYGON_CLASS
// Move implementation tests/delete

@interface CCHMapViewDelegateProxyReturnValueTests : XCTestCase

@end

@implementation CCHMapViewDelegateProxyReturnValueTests

- (MKOverlayView *)viewForOverlay:(id<MKOverlay>)overlay withMapViewDelegate:(NSObject<MKMapViewDelegate> *)mapViewDelegate proxyDelegate:(NSObject<MKMapViewDelegate> *)proxyDelegate
{
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.delegate = mapViewDelegate;
    
    CCHMapViewDelegateProxy *delegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    (void)delegateProxy;
    
    MKOverlayView *overlayView = [mapView.delegate mapView:mapView viewForOverlay:overlay];
    return overlayView;
}

#pragma mark - Map view delegate returns value

- (void)testMapViewDelegateReturnsValueProxyReturnsValue
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] init];
    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:DUMMY_POLYGON_CLASS]);
}

- (void)testMapViewDelegateReturnsValueProxyReturnsNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsNil alloc] init];
    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:DUMMY_POLYGON_CLASS]);
}

- (void)testMapViewDelegateReturnsValueProxyEmpty
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateEmpty alloc] init];
    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:DUMMY_POLYGON_CLASS]);
}

- (void)testMapViewDelegateReturnsValueProxyNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:DUMMY_POLYGON_CLASS]);
}

//#pragma mark - Map view delegate returns nil
//
//- (void)testMapViewDelegateReturnsNilProxyReturnsValue
//{
//    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
//    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] init];
//    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
//    XCTAssertTrue([view isMemberOfClass:DEBUG_POLYGON_CLASS]);
//}
//
//- (void)testMapViewDelegateReturnsNilProxyReturnsNil
//{
//    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
//    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsNil alloc] init];
//    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
//    XCTAssertNil(view);
//}
//
//- (void)testMapViewDelegateReturnsNilProxyEmpty
//{
//    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
//    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateEmpty alloc] init];
//    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
//    XCTAssertNil(view);
//}
//
//- (void)testMapViewDelegateReturnsNilProxyNil
//{
//    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
//    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
//    MKOverlayView *view = [self viewForOverlay:nil withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
//    XCTAssertNil(view);
//}

#pragma mark - Test implementation

- (void)testOverlayClassCorrect
{
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] init];
    id<MKOverlay> overlay = [[DEBUG_POLYGON_CLASS alloc] init];
    MKOverlayView *view = [self viewForOverlay:overlay withMapViewDelegate:nil proxyDelegate:proxyDelegate];
    XCTAssertNotNil(view);
}

- (void)testOverlayClassWrong
{
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] init];
    id<MKOverlay> overlay = [[MKCircle alloc] init];
    MKOverlayView *view = [self viewForOverlay:overlay withMapViewDelegate:nil proxyDelegate:proxyDelegate];
    XCTAssertNil(view);
}

@end
