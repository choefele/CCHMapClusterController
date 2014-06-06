//
//  CCHFadeInOutMapAnimator.m
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

#import "CCHFadeInOutMapAnimator.h"

#import "CCHMapClusterController.h"

#import <MapKit/MapKit.h>

@implementation CCHFadeInOutMapAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _duration = 0.2;
    }
    return self;
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController didAddAnnotationViews:(NSArray *)annotationViews
{
    // Animate annotations that get added
#if TARGET_OS_IPHONE
    for (MKAnnotationView *annotationView in annotationViews)
    {
        annotationView.alpha = 0.0;
    }
    
    [UIView animateWithDuration:self.duration animations:^{
        for (MKAnnotationView *annotationView in annotationViews) {
            annotationView.alpha = 1.0;
        }
    }];
#endif
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willRemoveAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)())completionHandler
{
#if TARGET_OS_IPHONE
    MKMapView *mapView = mapClusterController.mapView;
    [UIView animateWithDuration:self.duration animations:^{
        for (id<MKAnnotation> annotation in annotations) {
            MKAnnotationView *annotationView = [mapView viewForAnnotation:annotation];
            annotationView.alpha = 0.0;
        }
    } completion:^(BOOL finished) {
        if (completionHandler) {
            completionHandler();
        }
    }];
#else
    if (completionHandler) {
        completionHandler();
    }
#endif
}

@end
