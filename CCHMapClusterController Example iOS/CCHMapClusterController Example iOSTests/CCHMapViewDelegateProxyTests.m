//
//  CCHMapViewDelegateProxyTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus on 17.02.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "CCHMapViewDelegateProxy.h"

#import <XCTest/XCTest.h>
#import <MapKit/MapKit.h>

@interface MapViewDelegate : NSObject<MKMapViewDelegate>
@property (nonatomic, assign) BOOL called;
@end
@implementation MapViewDelegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.called = YES;
}
@end

@interface CCHMapViewDelegateProxyTests : XCTestCase

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation CCHMapViewDelegateProxyTests

- (void)setUp
{
    [super setUp];
    
    self.mapView = [[MKMapView alloc] init];
}

- (void)testMapViewDelegate
{
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;

    MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate];
    XCTAssertEqual(self.mapView.delegate, mapViewDelegateProxy);
    XCTAssertEqual(mapViewDelegateProxy.target, mapViewDelegate);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, (NSUInteger)1);
    XCTAssertEqual(mapViewDelegateProxy.delegates.anyObject, proxyDelegate);
}

- (void)testMapViewDelegateChangeToNil
{
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;
    
    MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate];
    
    self.mapView.delegate = nil;
    
    XCTAssertEqual(self.mapView.delegate, mapViewDelegateProxy);
    XCTAssertNil(mapViewDelegateProxy.target);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, (NSUInteger)1);
    XCTAssertEqual(mapViewDelegateProxy.delegates.anyObject, proxyDelegate);
}

- (void)testMapViewNilDelegate
{
    MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate];
    XCTAssertEqual(self.mapView.delegate, mapViewDelegateProxy);
    XCTAssertNil(mapViewDelegateProxy.target);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, (NSUInteger)1);
    XCTAssertEqual(mapViewDelegateProxy.delegates.anyObject, proxyDelegate);
}

- (void)testMapViewNilDelegateChangeToInstance
{
    MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate];
    
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;

    XCTAssertEqual(self.mapView.delegate, mapViewDelegateProxy);
    XCTAssertEqual(mapViewDelegateProxy.target, mapViewDelegate);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, (NSUInteger)1);
    XCTAssertEqual(mapViewDelegateProxy.delegates.anyObject, proxyDelegate);
}

- (void)testDeallocDelegateProxy
{
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;
    
    @autoreleasepool {
        MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
        CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate];
        XCTAssertEqual(mapViewDelegateProxy.target, mapViewDelegate);
    }

    XCTAssertEqual(self.mapView.delegate, mapViewDelegate);
}

- (void)testDeallocMapView
{
    MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy;

    @autoreleasepool {
        MKMapView *mapView = [[MKMapView alloc] init];
        mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    }
    
    XCTAssertNil(mapViewDelegateProxy.target);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, (NSUInteger)1);
}

- (void)testAddMultipleDelegateProxies
{
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;
    
    MapViewDelegate *proxyDelegate0 = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate0];
    MapViewDelegate *proxyDelegate1 = [[MapViewDelegate alloc] init];
    [mapViewDelegateProxy addDelegate:proxyDelegate1];
    
    XCTAssertEqual(self.mapView.delegate, mapViewDelegateProxy);
    XCTAssertEqual(mapViewDelegateProxy.target, mapViewDelegate);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, (NSUInteger)2);
}

- (void)testRemoveMultipleDelegateProxies
{
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;
    
    @autoreleasepool {
        MapViewDelegate *proxyDelegate0 = [[MapViewDelegate alloc] init];
        CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate0];
        MapViewDelegate *proxyDelegate1 = [[MapViewDelegate alloc] init];
        [mapViewDelegateProxy addDelegate:proxyDelegate1];
    }
    
    XCTAssertEqual(self.mapView.delegate, mapViewDelegate);
}

- (void)testCallDelegates
{
    MapViewDelegate *mapViewDelegate = [[MapViewDelegate alloc] init];
    self.mapView.delegate = mapViewDelegate;
    MapViewDelegate *proxyDelegate0 = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate0];
    MapViewDelegate *proxyDelegate1 = [[MapViewDelegate alloc] init];
    [mapViewDelegateProxy addDelegate:proxyDelegate1];
    
    [mapViewDelegateProxy mapView:nil regionDidChangeAnimated:YES];

    XCTAssertTrue(mapViewDelegate.called);
    XCTAssertTrue(proxyDelegate0.called);
    XCTAssertTrue(proxyDelegate1.called);
}

@end
