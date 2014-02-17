//
//  CCHMapViewDelegateProxy.m
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

@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, weak) NSObject<MKMapViewDelegate> *target;
@property (nonatomic, weak) MKMapView *mapView;

@end

@implementation CCHMapViewDelegateProxy

- (id)initWithMapView:(MKMapView *)mapView delegate:(NSObject<MKMapViewDelegate> *)delegate
{
    self = [super init];
    if (self) {
        _delegates = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [_delegates addObject:delegate];
        _target = mapView.delegate;
        _mapView = mapView;
        [self swapDelegates];
    }
    return self;
}

- (void)addDelegate:(NSObject<MKMapViewDelegate> *)delegate
{
    [self.delegates addObject:delegate];
}

- (void)dealloc
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    self.mapView.delegate = self.target;
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

- (BOOL)respondsToSelector:(SEL)selector
{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:selector]) {
            return YES;
        }
    }
    
    return [self.target respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:selector]) {
            return [delegate methodSignatureForSelector:selector];
        }
    }

    return [self.target methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }
    
    if ([self.target respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.target];
    }
    
    }
}

@end
