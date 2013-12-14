//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

@import CoreLocation;

#import "QTreeInsertable.h"

@interface QCluster : NSObject

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, assign) NSInteger objectsCount;
@property(nonatomic, assign) CLLocationDegrees radius;

@end
