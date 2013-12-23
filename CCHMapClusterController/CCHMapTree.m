//
//  CCHMapTree.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import "CCHMapTree.h"

#import "CCHMapTreeUtils.h"

@interface UnsafeMutableArray()

@property (nonatomic, assign) id __unsafe_unretained *objects;
@property (nonatomic, assign) NSUInteger numObjects;
@property (nonatomic, assign) NSUInteger capacity;

@end

@implementation UnsafeMutableArray

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        _objects = (__unsafe_unretained id *)malloc(capacity * sizeof(id));
        _numObjects = 0;
        _capacity = capacity ? capacity : 1;
    }
    return self;
}

- (void)dealloc
{
    free(_objects);
}

- (void)addObject:(__unsafe_unretained id)object
{
    if (_numObjects >= _capacity) {
        _capacity *= 2;
        _objects = (__unsafe_unretained id *)realloc(_objects, _capacity * sizeof(id));
    }
    _objects[_numObjects++] = object;
}

@end

@interface CCHMapTree()

@property (nonatomic, strong) NSMutableSet *annotations;
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
        self.annotations = [NSMutableSet set];
        CCHMapTreeBoundingBox world = CCHMapTreeBoundingBoxMake(minLatitude, minLongitude, maxLatitude, maxLongitude);
        self.root = CCHMapTreeBuildWithData(NULL, 0, world, nodeCapacity);
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
        CCHMapTreeNodeInsertData(_root, data, (int)_nodeCapacity);
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

- (UnsafeMutableArray *)annotationsInMapRect:(MKMapRect)mapRect
{
    UnsafeMutableArray *array = [[UnsafeMutableArray alloc] initWithCapacity:10];
    CCHMapTreeGatherDataInRange3(self.root, CCHMapTreeBoundingBoxForMapRect(mapRect), array);
    
    return array;
}

@end
