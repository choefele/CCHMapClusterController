//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

@import CoreLocation;
@import MapKit;

#import "QTreeInsertable.h"

@interface QTree : NSObject

-(void)insertObject:(id<QTreeInsertable>)insertableObject;

@property(nonatomic, readonly) NSUInteger count;

- (void) cleanup;

-(NSArray*)getObjectsInRegion:(MKCoordinateRegion)region minNonClusteredSpan:(CLLocationDegrees)span;
// Returned array is sorted from the least to the most distant
-(NSArray*)neighboursForLocation:(CLLocationCoordinate2D)location limitCount:(NSUInteger)limit;

@end