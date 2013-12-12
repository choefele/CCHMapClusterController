//
// Copyright 2012 Bryan Bonczek
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class KPAnnotation;

@protocol KPTreeControllerDelegate;

@interface KPTreeController : NSObject

@property (nonatomic, weak) id<KPTreeControllerDelegate> delegate;
@property (nonatomic) CGSize gridSize;
@property (nonatomic) CGSize annotationSize;
@property (nonatomic) CGPoint annotationCenterOffset;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) UIViewAnimationOptions animationOptions;
@property (nonatomic) BOOL clusteringEnabled;
@property (nonatomic) BOOL debuggingEnabled;

/**
 If debuggingEnabled is YES, returns a list of polylines for the grid to be shown on the map
 */
@property (nonatomic, readonly) NSArray *gridPolylines;

- (id)initWithMapView:(MKMapView *)mapView;
- (void)setAnnotations:(NSArray *)annoations;
- (void)refresh:(BOOL)animated;

@end


@protocol KPTreeControllerDelegate<NSObject>

@optional

- (void)treeController:(KPTreeController *)tree configureAnnotationForDisplay:(KPAnnotation *)annotation;
- (void)treeController:(KPTreeController *)tree willAnimateAnnotation:(KPAnnotation *)annotation fromAnnotation:(KPAnnotation *)fromAnntation toAnnotation:(KPAnnotation *)toAnnotation;
- (void)treeController:(KPTreeController *)tree didAnimateAnnotation:(KPAnnotation *)annotation fromAnnotation:(KPAnnotation *)fromAnntation toAnnotation:(KPAnnotation *)toAnnotation;

@end
