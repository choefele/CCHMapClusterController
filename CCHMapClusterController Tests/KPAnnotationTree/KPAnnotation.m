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

#import "KPAnnotation.h"

@interface KPAnnotation ()

@property (nonatomic, readwrite) NSSet *annotations;
@property (nonatomic, readwrite) float radius;

@end

@implementation KPAnnotation


- (id)initWithAnnotations:(NSArray *)annotations {
    return [self initWithAnnotationSet:[NSSet setWithArray:annotations]];
}

- (id)initWithAnnotationSet:(NSSet *)set {
    self = [super init];
    
    if(self){
        self.annotations = set;
        self.title = [NSString stringWithFormat:@"%i things", [self.annotations count]];;
        [self calculateValues];
    }
    
    return self;
}

- (BOOL)isCluster {
    return (self.annotations.count > 1);
}

#pragma mark - Private

- (void)calculateValues {
    
    CLLocationDegrees minLat = INT_MAX;
    CLLocationDegrees minLng = INT_MAX;
    CLLocationDegrees maxLat = -INT_MAX;
    CLLocationDegrees maxLng = -INT_MAX;
    
    CLLocationDegrees totalLat = 0;
    CLLocationDegrees totalLng = 0;
    
    for(id<MKAnnotation> a in self.annotations){
        
        CLLocationDegrees lat = [a coordinate].latitude;
        CLLocationDegrees lng = [a coordinate].longitude;
        
        minLat = MIN(minLat, lat);
        minLng = MIN(minLng, lng);
        maxLat = MAX(maxLat, lat);
        maxLng = MAX(maxLng, lng);
        
        totalLat += lat;
        totalLng += lng;
    }
    
    
    self.coordinate = CLLocationCoordinate2DMake(totalLat / self.annotations.count,
                                                 totalLng / self.annotations.count);
    
    self.radius = [[[CLLocation alloc] initWithLatitude:minLat
                                              longitude:minLng]
                   distanceFromLocation:[[CLLocation alloc] initWithLatitude:maxLat
                                                                   longitude:maxLng]] / 2.f;
}



@end
