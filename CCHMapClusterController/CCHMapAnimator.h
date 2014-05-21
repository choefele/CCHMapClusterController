//
//  CCHMapAnimator.h
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

#import <Foundation/Foundation.h>

@class CCHMapClusterController;

/**
 A custom strategy that defines how annotation views for `CCHClusterAnnotation`s are animated 
 must implement this protocol.
 */
@protocol CCHMapAnimator <NSObject>

/**
 Called on the main thread to animate in the given annotation views. At this point, the views' annotations
 have already been added to the map view.
 @param mapClusterController map cluster controller.
 @param annotationViews .
 */
- (void)mapClusterController:(CCHMapClusterController *)mapClusterController didAddAnnotationViews:(NSArray *)annotationViews;

/**
 Called on the main thread to animate out the given annotations. The views' annotations will be removed
 when calling the completion handler.
 @param mapClusterController map cluster controller.
 @param annotations annotations to animate (annotations are of type `CCHMapClusterAnnotation`).
 @param completionHandler this completion handler must be called after the animation has finished.
 */
- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willRemoveAnnotations:(NSArray *)annotations withCompletionHandler:(void (^)())completionHandler;

@end
