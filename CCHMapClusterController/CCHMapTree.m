//
//  CCHMapTree.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "CCHMapTree.h"

#import "CCHMapTreeUtils.h"

@interface CCHMapTree()

@property (nonatomic, strong) NSMutableSet *mutableAnnotations;
@property (nonatomic, assign) CCHMapTreeNode *root;
@property (nonatomic, assign) NSUInteger nodeCapacity;

@end

@implementation CCHMapTree

- (id)init
{
    return [self initWithNodeCapacity:10 minLatitude:-85.0 maxLatitude:85.0 minLongitude:-180.0 maxLongitude:180.0];
}

- (id)initWithNodeCapacity:(NSUInteger)nodeCapacity minLatitude:(double)minLatitude maxLatitude:(double)maxLatitude minLongitude:(double)minLongitude maxLongitude:(double)maxLongitude
{
    self = [super init];
    if (self) {
        self.nodeCapacity = nodeCapacity;
        self.mutableAnnotations = [NSMutableSet set];
        CCHMapTreeBoundingBox world = CCHMapTreeBoundingBoxMake(minLatitude, minLongitude, maxLatitude, maxLongitude);
        self.root = CCHMapTreeBuildWithData(NULL, 0, world, nodeCapacity);
    }
    
    return self;
}

- (void)dealloc
{
    CCHMapTreeFreeQuadTreeNode(self.root);
}

- (NSSet *)annotations
{
    return self.mutableAnnotations;
}

- (void)addAnnotations:(NSArray *)annotations
{
    NSMutableSet *set = self.mutableAnnotations;
    for (id<MKAnnotation> annotation in annotations) {
        if (![set containsObject:annotation]) {
            CCHMapTreeNodeData data = CCHMapTreeNodeDataMake(annotation.coordinate.latitude, annotation.coordinate.longitude, (__bridge void *)annotation);
            if (CCHMapTreeNodeInsertData(_root, data, (int)_nodeCapacity)) {
                [set addObject:annotation];
            }
        }
    }
}

- (void)removeAnnotations:(NSArray *)annotations
{
    NSMutableSet *set = self.mutableAnnotations;
    for (id<MKAnnotation> annotation in annotations) {
        id<MKAnnotation> member = [set member:annotation];
        if (member) {
            CCHMapTreeNodeData data = CCHMapTreeNodeDataMake(annotation.coordinate.latitude, annotation.coordinate.longitude, (__bridge void *)member);
            if (CCHMapTreeNodeRemoveData(_root, data)) {
                [self.mutableAnnotations removeObject:annotation];
            }
        }
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
    CCHMapTreeUnsafeMutableArray *annotations = [[CCHMapTreeUnsafeMutableArray alloc] initWithCapacity:10];
    CCHMapTreeGatherDataInRange3(self.root, CCHMapTreeBoundingBoxForMapRect(mapRect), annotations);
    NSSet *annotationsAsSet = [NSSet setWithObjects:annotations.objects count:annotations.numObjects];
    
    return annotationsAsSet;
}
@end
