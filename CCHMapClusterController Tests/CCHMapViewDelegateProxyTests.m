//
//  CCHMapViewDelegateProxyTests.m
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

@property (nonatomic) MKMapView *mapView;

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
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, 1);
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
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, 1);
    XCTAssertEqual(mapViewDelegateProxy.delegates.anyObject, proxyDelegate);
}

- (void)testMapViewNilDelegate
{
    MapViewDelegate *proxyDelegate = [[MapViewDelegate alloc] init];
    CCHMapViewDelegateProxy *mapViewDelegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:self.mapView delegate:proxyDelegate];
    XCTAssertEqual(self.mapView.delegate, mapViewDelegateProxy);
    XCTAssertNil(mapViewDelegateProxy.target);
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, 1);
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
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, 1);
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
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, 1);
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
    XCTAssertEqual(mapViewDelegateProxy.delegates.count, 2);
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
    
    [mapViewDelegateProxy mapView:self.mapView regionDidChangeAnimated:YES];

    XCTAssertTrue(mapViewDelegate.called);
    XCTAssertTrue(proxyDelegate0.called);
    XCTAssertTrue(proxyDelegate1.called);
}

@end
