//
//  CCHFadeInOutMapAnimatorTests.m
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

#import "CCHFadeInOutMapAnimator.h"

#import <XCTest/XCTest.h>
#import <MapKit/MapKit.h>

@interface CCHFadeInOutMapAnimatorTests : XCTestCase

@property (nonatomic) CCHFadeInOutMapAnimator *animator;
@property (nonatomic) BOOL done;

@end

@implementation CCHFadeInOutMapAnimatorTests

- (void)setUp
{
    [super setUp];

    self.animator = [[CCHFadeInOutMapAnimator alloc] init];
    self.done = NO;
}

#if TARGET_OS_IPHONE
- (void)testFadeIn
{
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] init];
    annotationView.alpha = 0;
    [self.animator mapClusterController:nil didAddAnnotationViews:@[annotationView]];
    XCTAssertEqualWithAccuracy(annotationView.alpha, 1.0, __FLT_EPSILON__);
}
#endif

- (void)testFadeOutCompletionBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.animator mapClusterController:nil willRemoveAnnotations:nil withCompletionHandler:^{
        self.done = YES;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:NULL];
}

@end
