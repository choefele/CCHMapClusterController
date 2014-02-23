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
#import "CCHMapClusterControllerDebugPolygon.h"

@interface TestOverlayView0 : MKOverlayView
@end
@implementation TestOverlayView0
@end

@interface TestOverlayView1 : MKOverlayView
@end
@implementation TestOverlayView1
@end

#if TARGET_OS_IPHONE
@interface MapViewDelegateReturnsValue : NSObject<MKMapViewDelegate>
@property (nonatomic, assign) Class valueClass;
- (id)initWithValueClass:(Class)valueClass;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnsValue
- (id)initWithValueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        self.valueClass = valueClass;
    }
    return self;
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    return [[self.valueClass alloc] init];
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

// Remove DEBUG_POLYGON_CLASS

@interface CCHMapViewDelegateProxyViewForOverlayTests : XCTestCase

@end

@implementation CCHMapViewDelegateProxyViewForOverlayTests

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

- (void)testMapViewDelegateProxy
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}

- (void)testMapViewDelegateProxyWrongClass
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayView *view = [self viewForOverlay:[MKCircle new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertNil(view);
}

- (void)testMapViewDelegateHasPriority
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView1.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:TestOverlayView0.class]);
}

- (void)testMapViewDelegateProxyIgnoredNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}

- (void)testMapViewDelegateProxyIgnoredReturnsNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}

- (void)testMapViewDelegateProxyIgnoredEmpty
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateEmpty alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}

//#pragma mark - Test implementation
//
//- (void)testOverlayClassCorrect
//{
//    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] init];
//    id<MKOverlay> overlay = [[DEBUG_POLYGON_CLASS alloc] init];
//    MKOverlayView *view = [self viewForOverlay:overlay withMapViewDelegate:nil proxyDelegate:proxyDelegate];
//    XCTAssertNotNil(view);
//}
//
//- (void)testOverlayClassWrong
//{
//    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] init];
//    id<MKOverlay> overlay = [[MKCircle alloc] init];
//    MKOverlayView *view = [self viewForOverlay:overlay withMapViewDelegate:nil proxyDelegate:proxyDelegate];
//    XCTAssertNil(view);
//}
//
@end
