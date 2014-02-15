//
//  CCHFadeInOutMapAnimatorTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 16.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MapKit/MapKit.h>

#import "CCHFadeInOutMapAnimator.h"

@interface CCHFadeInOutMapAnimatorTests : XCTestCase

@property (nonatomic, strong) CCHFadeInOutMapAnimator *animator;
@property (nonatomic, assign) BOOL done;

@end

@implementation CCHFadeInOutMapAnimatorTests

- (void)setUp
{
    [super setUp];

    self.animator = [[CCHFadeInOutMapAnimator alloc] init];
    self.done = NO;
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if (timeoutDate.timeIntervalSinceNow < 0.0) {
            break;
        }
    } while (!self.done);
    
    return self.done;
}

- (void)testFadeIn
{
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] init];
    annotationView.alpha = 0;
    [self.animator mapClusterController:nil didAddAnnotationViews:@[annotationView]];
    XCTAssertEqualWithAccuracy(annotationView.alpha, 1.0, __FLT_EPSILON__);
}

- (void)testFadeOutCompletionBlock
{
    [self.animator mapClusterController:nil willRemoveAnnotations:nil withCompletionHandler:^{
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:1.0]);
}

@end
