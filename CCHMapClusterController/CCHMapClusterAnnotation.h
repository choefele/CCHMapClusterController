//
//  CCHMapClusterAnnotation.h
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
#import <MapKit/MapKit.h>

@protocol CCHMapClusterControllerDelegate;
@class CCHMapClusterController;

/**
 Container for clustered annotations.
 */
@interface CCHMapClusterAnnotation : NSObject<MKAnnotation>

@property (nonatomic, weak) CCHMapClusterController *mapClusterController;

/** The string containing the annotation's title. */
@property (nonatomic, copy) NSString *title;
/** The string containing the annotation's subtitle. */
@property (nonatomic, copy) NSString *subtitle;
/** The center point of the annotation. */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/** Custom titles and subtitles are retrieved via this delegate. */
@property (nonatomic, weak) id<CCHMapClusterControllerDelegate> delegate;

/** Annotations contained in this cluster. */
@property (nonatomic, copy) NSSet *annotations;

/** Returns YES if this cluster contains more than one annotation. */
- (BOOL)isCluster;
/** Returns YES if all annotations in this cluster have the same location. */
- (BOOL)isUniqueLocation;
- (BOOL)isOneLocation __deprecated;

/** The area that includes all annotations. */
- (MKMapRect)mapRect;

@end
