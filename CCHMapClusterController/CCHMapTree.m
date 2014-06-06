//
//  CCHMapTree.m
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

#import "CCHMapTree.h"

#import "CCHMapTreeUtils.h"

@interface CCHMapTree()

@property (nonatomic) NSMutableSet *mutableAnnotations;
@property (nonatomic) CCHMapTreeNode *root;
@property (nonatomic) NSUInteger nodeCapacity;

@end

@implementation CCHMapTree

- (instancetype)init
{
    return [self initWithNodeCapacity:10 minLatitude:-85.0 maxLatitude:85.0 minLongitude:-180.0 maxLongitude:180.0];
}

- (instancetype)initWithNodeCapacity:(NSUInteger)nodeCapacity minLatitude:(double)minLatitude maxLatitude:(double)maxLatitude minLongitude:(double)minLongitude maxLongitude:(double)maxLongitude
{
    self = [super init];
    if (self) {
        _nodeCapacity = nodeCapacity;
        _mutableAnnotations = [NSMutableSet set];
        CCHMapTreeBoundingBox world = CCHMapTreeBoundingBoxMake(minLatitude, minLongitude, maxLatitude, maxLongitude);
        _root = CCHMapTreeBuildWithData(NULL, 0, world, nodeCapacity);
    }
    
    return self;
}

- (void)dealloc
{
    CCHMapTreeFreeQuadTreeNode(self.root);
}

- (NSSet *)annotations
{
    return [self.mutableAnnotations copy];
}

- (BOOL)addAnnotations:(NSArray *)annotations
{
    BOOL updated = NO;
    
    NSMutableSet *mutableAnnotations = self.mutableAnnotations;
    for (id<MKAnnotation> annotation in annotations) {
        if (![mutableAnnotations containsObject:annotation]) {
            CCHMapTreeNodeData data = CCHMapTreeNodeDataMake(annotation.coordinate.latitude, annotation.coordinate.longitude, (__bridge void *)annotation);
            if (CCHMapTreeNodeInsertData(_root, data, (int)_nodeCapacity)) {
                updated = YES;
                [mutableAnnotations addObject:annotation];
            }
        }
    }
    
    return updated;
}

- (BOOL)removeAnnotations:(NSArray *)annotations
{
    BOOL updated = NO;

    NSMutableSet *mutableAnnotations = self.mutableAnnotations;
    for (id<MKAnnotation> annotation in annotations) {
        id<MKAnnotation> member = [mutableAnnotations member:annotation];
        if (member) {
            CCHMapTreeNodeData data = CCHMapTreeNodeDataMake(annotation.coordinate.latitude, annotation.coordinate.longitude, (__bridge void *)member);
            if (CCHMapTreeNodeRemoveData(_root, data)) {
                updated = YES;
                [mutableAnnotations removeObject:annotation];
            }
        }
    }
    
    return updated;
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
