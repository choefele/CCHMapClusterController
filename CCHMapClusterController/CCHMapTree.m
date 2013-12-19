//
//  CCHMapTree.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "CCHMapTree.h"

#import "CCHMapTreeUtils.h"

#define BUCKET_CAPACITY 10

@interface CCHMapTree()

@property (nonatomic, strong) NSMutableSet *annotations;
@property (nonatomic, assign) CCHMapTreeNode *root;

@end

@implementation CCHMapTree

- (id)init
{
    self = [super init];
    if (self) {
        self.annotations = [NSMutableSet set];
        CCHMapTreeBoundingBox world = CCHMapTreeBoundingBoxMake(-180, -85, 180, 85); // minLat, minLon, maxLat, maxLon
        self.root = CCHMapTreeBuildWithData(NULL, 0, world, BUCKET_CAPACITY);
    }
    
    return self;
}

- (void)dealloc
{
    CCHMapTreeFreeQuadTreeNode(self.root);
}

- (void)addAnnotations:(NSArray *)annotations
{
    [self.annotations addObjectsFromArray:annotations];
    for (id<MKAnnotation> annotation in _annotations) {
        CCHMapTreeNodeData data = CCHMapTreeNodeDataMake(annotation.coordinate.latitude, annotation.coordinate.longitude, (__bridge void *)annotation);
        CCHMapTreeNodeInsertData(_root, data, BUCKET_CAPACITY);
    }
}

CCHMapTreeBoundingBox CCHMapTreeBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return CCHMapTreeBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
    NSMutableSet *annotations = [NSMutableSet set];
    CCHMapTreeGatherDataInRange(self.root, CCHMapTreeBoundingBoxForMapRect(mapRect), ^(CCHMapTreeNodeData data) {
        [annotations addObject:(__bridge id)data.data];
    });

    return annotations;
}

@end
