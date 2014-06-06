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

#if TARGET_OS_IPHONE
@interface TestOverlayView0 : MKOverlayView
@end
@implementation TestOverlayView0
@end

@interface TestOverlayView1 : MKOverlayView
@end
@implementation TestOverlayView1
@end

@interface MapViewDelegateReturnsValue : NSObject<MKMapViewDelegate>
@property (nonatomic, assign) Class valueClass;
- (instancetype)initWithValueClass:(Class)valueClass;
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
@end
@implementation MapViewDelegateReturnsValue
- (instancetype)initWithValueClass:(Class)valueClass {
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

#else   // TARGET_OS_IPHONE

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
#endif  // TARGET_OS_IPHONE

@interface CCHMapViewDelegateProxyOverlayTests : XCTestCase

@end

@implementation CCHMapViewDelegateProxyOverlayTests

#if TARGET_OS_IPHONE
- (MKOverlayView *)viewForOverlay:(id<MKOverlay>)overlay withMapViewDelegate:(NSObject<MKMapViewDelegate> *)mapViewDelegate proxyDelegate:(NSObject<MKMapViewDelegate> *)proxyDelegate
{
    MKMapView *mapView = [[MKMapView alloc] init];
    mapView.delegate = mapViewDelegate;
    
    CCHMapViewDelegateProxy *delegateProxy = [[CCHMapViewDelegateProxy alloc] initWithMapView:mapView delegate:proxyDelegate];
    (void)delegateProxy;
    
    MKOverlayView *overlayView;
    if ([mapView.delegate respondsToSelector:@selector(mapView:viewForOverlay:)]) {
        overlayView = [mapView.delegate mapView:mapView viewForOverlay:overlay];
    }
    
    return overlayView;
}
#else
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
#endif

#if TARGET_OS_IPHONE
- (void)testMapViewDelegateProxy
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}
#else
- (void)testMapViewDelegateProxy
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayRenderer *view = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonRenderer.class]);
}
#endif

#if TARGET_OS_IPHONE
- (void)testMapViewDelegateProxyWrongClass
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayView *view = [self viewForOverlay:[MKCircle new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertNil(view);
}
#else
- (void)testMapViewDelegateProxyWrongClass
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = nil;
    MKOverlayRenderer *renderer = [self rendererForOverlay:[MKCircle new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertNil(renderer);
}
#endif

#if TARGET_OS_IPHONE
- (void)testMapViewDelegateHasPriority
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView1.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:TestOverlayView0.class]);
}
#else
- (void)testMapViewDelegateHasPriority
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer1.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:TestOverlayRenderer0.class]);
}
#endif

#if TARGET_OS_IPHONE
- (void)testMapViewDelegateProxyIgnoredNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}
#else
- (void)testMapViewDelegateProxyIgnoredNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = nil;
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:MKPolygonRenderer.class]);
}
#endif

#if TARGET_OS_IPHONE
- (void)testMapViewDelegateProxyIgnoredReturnsNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}
#else
- (void)testMapViewDelegateProxyIgnoredReturnsNil
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateReturnsNil alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:MKPolygonRenderer.class]);
}
#endif

#if TARGET_OS_IPHONE
- (void)testMapViewDelegateProxyIgnoredEmpty
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateEmpty alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayView0.class];
    MKOverlayView *view = [self viewForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([view isMemberOfClass:MKPolygonView.class]);
}
#else
- (void)testMapViewDelegateProxyIgnoredEmpty
{
    NSObject<MKMapViewDelegate> *mapViewDelegate = [[MapViewDelegateEmpty alloc] init];
    NSObject<MKMapViewDelegate> *proxyDelegate = [[MapViewDelegateReturnsValue alloc] initWithValueClass:TestOverlayRenderer0.class];
    MKOverlayRenderer *renderer = [self rendererForOverlay:[CCHMapClusterControllerDebugPolygon new] withMapViewDelegate:mapViewDelegate proxyDelegate:proxyDelegate];
    XCTAssertTrue([renderer isMemberOfClass:MKPolygonRenderer.class]);
}
#endif

@end
