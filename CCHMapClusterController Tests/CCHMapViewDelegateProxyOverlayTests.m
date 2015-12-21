//
//  CCHMapViewDelegateProxyOverlayTests.m
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
#import "CCHMapClusterControllerDebugPolygon.h"

#import <XCTest/XCTest.h>
#import <MapKit/MapKit.h>

@interface TestOverlayRenderer0 : MKOverlayRenderer
@end
@implementation TestOverlayRenderer0
@end

@interface TestOverlayRenderer1 : MKOverlayRenderer
@end
@implementation TestOverlayRenderer1
@end

@interface MapViewDelegateReturnsValue : NSObject<MKMapViewDelegate>
@property (nonatomic, assign) Class valueClass;
- (instancetype)initWithValueClass:(Class)valueClass;
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnsValue
- (instancetype)initWithValueClass:(Class)valueClass {
    self = [super init];
    if (self) {
        self.valueClass = valueClass;
    }
    return self;
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [[self.valueClass alloc] init];
}
@end

@interface MapViewDelegateReturnsNil : NSObject<MKMapViewDelegate>
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnsNil
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return nil;
}
@end

@interface MapViewDelegateEmpty : NSObject<MKMapViewDelegate>
@end
@implementation MapViewDelegateEmpty
@end

@interface CCHMapViewDelegateProxyOverlayTests : XCTestCase

@end

@implementation CCHMapViewDelegateProxyOverlayTests

- (MKOverlayRenderer *)rendererForOverlay:(id<MKOverlay>)overlay withMapViewDelegate:(NSObject<MKMapViewDelegate> *)mapViewDelegate proxyDelegate:(NSObject<MKMapViewDelegate> *)proxyDelegate
{
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.delegate = mapViewDelegate;
    
    CCHMapViewDelegateProxy *delegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    (void)delegateProxy;
    
    MKOverlayRenderer *overlayRenderer;
    if ([mapView.delegate respondsToSelector:@selector(mapView:rendererForOverlay:)]) {
        overlayRenderer = [mapView.delegate mapView:mapView rendererForOverlay:overlay];
    }
    return overlayRenderer;
}

- (void)testMapViewDelegateProxy
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayRenderer *view = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonRenderer.class]);
}

- (void)testMapViewDelegateProxyWrongClass
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayRenderer *renderer = [self rendererForOverlay:[MKCircle new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertNil(renderer);
}

- (void)testMapViewDelegateHasPriority
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer1.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:TestOverlayRenderer0.class]);
}

- (void)testMapViewDelegateProxyIgnoredNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:MKPolygonRenderer.class]);
}

- (void)testMapViewDelegateProxyIgnoredReturnsNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:MKPolygonRenderer.class]);
}

- (void)testMapViewDelegateProxyIgnoredEmpty
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateEmpty alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:MKPolygonRenderer.class]);
}

@end
