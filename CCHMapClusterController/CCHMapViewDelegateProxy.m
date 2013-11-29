//
//  MapClusterMapViewDelegateProxy.m
//  CCHMapClusterController
//
//  Copyright (C) 2013 Claus Höfele
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

@interface CCHMapViewDelegateProxy()

@property (nonatomic, weak) NSObject<MKMapViewDelegate> *delegate;
@property (nonatomic, weak) NSObject<MKMapViewDelegate> *target;
@property (nonatomic, weak) MKMapView *mapView;

@end

@implementation CCHMapViewDelegateProxy

- (id)initWithMapView:(MKMapView *)mapView delegate:(NSObject<MKMapViewDelegate> *)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;   // must be set before swapDelegates
        self.mapView = mapView;
        self.target = mapView.delegate;
        [self swapDelegates];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    [self swapDelegates];
}

- (void)swapDelegates
{
    self.target = self.mapView.delegate;
    self.mapView.delegate = self;
    [self.mapView addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:NULL];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    id forwardingTarget;
    
    if ([self.delegate respondsToSelector:selector]) {
        forwardingTarget = self.delegate;
    } else if ([self.target respondsToSelector:selector]) {
        forwardingTarget = self.target;
    } else {
        forwardingTarget = [super forwardingTargetForSelector:selector];
    }
    
    return forwardingTarget;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    BOOL respondsToSelector;
    
    if ([self.delegate respondsToSelector:selector]) {
        respondsToSelector = YES;
    } else if ([self.target respondsToSelector:selector]) {
        respondsToSelector = YES;
    } else {
        respondsToSelector = [super respondsToSelector:selector];
    }
    
    return respondsToSelector;
}

@end
