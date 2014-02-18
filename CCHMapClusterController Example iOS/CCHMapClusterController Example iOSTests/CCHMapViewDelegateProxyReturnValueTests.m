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

#if TARGET_OS_IPHONE
@interface MapViewDelegateReturnValue : NSObject<MKMapViewDelegate>
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnValue
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    return [[MKOverlayView alloc] init];
}
@end
@interface MapViewDelegateReturnNil : NSObject<MKMapViewDelegate>
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnNil
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    return nil;
}
@end
#endif

// MKMapViewDelegate no viewForOverlay:
// MKMapViewDelegate viewForOverlay: returns nil
// MKMapViewDelegate viewForOverlay: returns object -> ok
// MKMapViewDelegate nil
// Wrong overlay class


@interface CCHMapViewDelegateProxyReturnValueTests : XCTestCase

@end

@implementation CCHMapViewDelegateProxyReturnValueTests

- (void)testDelegateReturnsValue
{
     NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnValue alloc] init];
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.delegate = mapViewDelegate;
    
     NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnValue alloc] init];
    CCHMapViewDelegateProxy *delegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    (void)delegateProxy;
    
    MKOverlayView *view = [mapView.delegate mapView:nil viewForOverlay:nil];
    XCTAssertTrue([view isMemberOfClass:MKOverlayView.class]);
}

- (void)testDelegateReturnsNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnNil alloc] init];
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.delegate = mapViewDelegate;
    
     NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnValue alloc] init];
    CCHMapViewDelegateProxy *delegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    (void)delegateProxy;
    
    id<MKOverlay> overlay = [[DEBUG_POLYGON_CLASS alloc] init];
    MKOverlayView *view = [mapView.delegate mapView:nil viewForOverlay:overlay];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}

- (void)testDelegateReturnsNilWrongOverlay
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnNil alloc] init];
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.delegate = mapViewDelegate;
    
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnValue alloc] init];
    CCHMapViewDelegateProxy *delegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    (void)delegateProxy;
    
    id<MKOverlay> overlay = [[MKCircle alloc] init];
    MKOverlayView *view = [mapView.delegate mapView:nil viewForOverlay:overlay];
    XCTAssertNil(view);
}

@end
