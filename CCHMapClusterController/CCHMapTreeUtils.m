//
//  CCHMapTreeUtils.m
//  CCHMapClusterController
//
//  Copyright (C) 2013 Theodore Calmes
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

#import "CCHMapTreeUtils.h"

#pragma mark - Unsafe Mutable Array

@interface CCHMapTreeUnsafeMutableArray()

@property (nonatomic, assign) id __unsafe_unretained *objects;
@property (nonatomic) NSUInteger numObjects;
@property (nonatomic) NSUInteger capacity;

@end

@implementation CCHMapTreeUnsafeMutableArray

- (instancetype)initWithCapacity:(NSUInteger)capacity
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

#pragma mark - Constructors

CCHMapTreeNode *CCHMapTreeNodeMake(CCHMapTreeBoundingBox boundary, unsigned long bucketCapacity)
{
    CCHMapTreeNode* node = malloc(sizeof(CCHMapTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;

    node->boundingBox = boundary;
    node->count = 0;
    node->points = malloc(sizeof(CCHMapTreeNodeData) * bucketCapacity);

    return node;
}

#pragma mark - Bounding Box Functions

static inline bool CCHMapTreeBoundingBoxContainsData(CCHMapTreeBoundingBox box, CCHMapTreeNodeData data)
{
    return (box.x0 <= data.x && data.x <= box.xf && box.y0 <= data.y && data.y <= box.yf);
}

static inline bool CCHMapTreeBoundingBoxIntersectsBoundingBox(CCHMapTreeBoundingBox b1, CCHMapTreeBoundingBox b2)
{
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0);
}

#pragma mark - Quad Tree Functions

void CCHMapTreeNodeSubdivide(CCHMapTreeNode *node, unsigned long bucketCapacity)
{
    CCHMapTreeBoundingBox box = node->boundingBox;

    double xMid = (box.xf + box.x0) / 2.0;
    double yMid = (box.yf + box.y0) / 2.0;

    CCHMapTreeBoundingBox northWest = CCHMapTreeBoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = CCHMapTreeNodeMake(northWest, bucketCapacity);

    CCHMapTreeBoundingBox northEast = CCHMapTreeBoundingBoxMake(xMid, box.y0, box.xf, yMid);
    node->northEast = CCHMapTreeNodeMake(northEast, bucketCapacity);

    CCHMapTreeBoundingBox southWest = CCHMapTreeBoundingBoxMake(box.x0, yMid, xMid, box.yf);
    node->southWest = CCHMapTreeNodeMake(southWest, bucketCapacity);

    CCHMapTreeBoundingBox southEast = CCHMapTreeBoundingBoxMake(xMid, yMid, box.xf, box.yf);
    node->southEast = CCHMapTreeNodeMake(southEast, bucketCapacity);
}

CCHMapTreeNode *CCHMapTreeBuildWithData(CCHMapTreeNodeData *data, unsigned long count, CCHMapTreeBoundingBox boundingBox, unsigned long bucketCapacity)
{
    CCHMapTreeNode *root = CCHMapTreeNodeMake(boundingBox, bucketCapacity);
    for (unsigned long i = 0; i < count; i++) {
        CCHMapTreeNodeInsertData(root, data[i], bucketCapacity);
    }
    
    return root;
}

bool CCHMapTreeNodeInsertData(CCHMapTreeNode *node, CCHMapTreeNodeData data, unsigned long bucketCapacity)
{
    if (!CCHMapTreeBoundingBoxContainsData(node->boundingBox, data)) {
        return false;
    }

    if (node->count < bucketCapacity) {
        node->points[node->count++] = data;
        return true;
    }

    if (node->northWest == NULL) {
        CCHMapTreeNodeSubdivide(node, bucketCapacity);
    }

    if (CCHMapTreeNodeInsertData(node->northWest, data, bucketCapacity)) return true;
    if (CCHMapTreeNodeInsertData(node->northEast, data, bucketCapacity)) return true;
    if (CCHMapTreeNodeInsertData(node->southWest, data, bucketCapacity)) return true;
    if (CCHMapTreeNodeInsertData(node->southEast, data, bucketCapacity)) return true;

    return false;
}

bool CCHMapTreeNodeRemoveData(CCHMapTreeNode *node, CCHMapTreeNodeData data)
{
    if (!CCHMapTreeBoundingBoxContainsData(node->boundingBox, data)) {
        return false;
    }
    
    for (unsigned long i = 0; i < node->count; i++) {
        CCHMapTreeNodeData *nodeData = &node->points[i];
        if (nodeData->data == data.data) {
            node->points[i] = node->points[node->count - 1];
            node->count--;
            return true;
        }
    }
    
    if (node->northWest == NULL) {
        return false;
    }
    
    if (CCHMapTreeNodeRemoveData(node->northWest, data)) return true;
    if (CCHMapTreeNodeRemoveData(node->northEast, data)) return true;
    if (CCHMapTreeNodeRemoveData(node->southWest, data)) return true;
    if (CCHMapTreeNodeRemoveData(node->southEast, data)) return true;
    
    return false;
}

void CCHMapTreeGatherDataInRange(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, TBDataReturnBlock block)
{
    if (!CCHMapTreeBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) {
        return;
    }

    for (unsigned long i = 0; i < node->count; i++) {
        if (CCHMapTreeBoundingBoxContainsData(range, node->points[i])) {
            block(node->points[i]);
        }
    }

    if (node->northWest == NULL) {
        return;
    }

    CCHMapTreeGatherDataInRange(node->northWest, range, block);
    CCHMapTreeGatherDataInRange(node->northEast, range, block);
    CCHMapTreeGatherDataInRange(node->southWest, range, block);
    CCHMapTreeGatherDataInRange(node->southEast, range, block);
}

void CCHMapTreeGatherDataInRange2(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, __unsafe_unretained NSMutableSet *annotations)
{
    if (!CCHMapTreeBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) {
        return;
    }
    
    for (unsigned long i = 0; i < node->count; i++) {
        if (CCHMapTreeBoundingBoxContainsData(range, node->points[i])) {
            [annotations addObject:(__bridge id)node->points[i].data];
        }
    }
    
    if (node->northWest == NULL) {
        return;
    }
    
    CCHMapTreeGatherDataInRange2(node->northWest, range, annotations);
    CCHMapTreeGatherDataInRange2(node->northEast, range, annotations);
    CCHMapTreeGatherDataInRange2(node->southWest, range, annotations);
    CCHMapTreeGatherDataInRange2(node->southEast, range, annotations);
}

void CCHMapTreeGatherDataInRange3(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, __unsafe_unretained CCHMapTreeUnsafeMutableArray *annotations)
{
    if (!CCHMapTreeBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) {
        return;
    }

    for (unsigned long i = 0; i < node->count; i++) {
        if (CCHMapTreeBoundingBoxContainsData(range, node->points[i])) {
            [annotations addObject:(__bridge id)node->points[i].data];
        }
    }

    if (node->northWest == NULL) {
        return;
    }

    CCHMapTreeGatherDataInRange3(node->northWest, range, annotations);
    CCHMapTreeGatherDataInRange3(node->northEast, range, annotations);
    CCHMapTreeGatherDataInRange3(node->southWest, range, annotations);
    CCHMapTreeGatherDataInRange3(node->southEast, range, annotations);
}

void CCHMapTreeTraverse(CCHMapTreeNode *node, CCHMapTreeTraverseBlock block)
{
    block(node);

    if (node->northWest == NULL) {
        return;
    }

    CCHMapTreeTraverse(node->northWest, block);
    CCHMapTreeTraverse(node->northEast, block);
    CCHMapTreeTraverse(node->southWest, block);
    CCHMapTreeTraverse(node->southEast, block);
}

void CCHMapTreeFreeQuadTreeNode(CCHMapTreeNode *node)
{
    if (node->northWest != NULL) CCHMapTreeFreeQuadTreeNode(node->northWest);
    if (node->northEast != NULL) CCHMapTreeFreeQuadTreeNode(node->northEast);
    if (node->southWest != NULL) CCHMapTreeFreeQuadTreeNode(node->southWest);
    if (node->southEast != NULL) CCHMapTreeFreeQuadTreeNode(node->southEast);

    free(node->points);
    free(node);
}
