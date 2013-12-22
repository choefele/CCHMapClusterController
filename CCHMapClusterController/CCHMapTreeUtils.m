//
//  TBQuadTree.m
//  TBQuadTree
//
//  Created by Theodore Calmes on 9/19/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "CCHMapTreeUtils.h"

#pragma mark - Constructors

CCHMapTreeNode* CCHMapTreeNodeMake(CCHMapTreeBoundingBox boundary, int bucketCapacity)
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

void CCHMapTreeNodeSubdivide(CCHMapTreeNode* node, int bucketCapacity)
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

bool CCHMapTreeNodeInsertData(CCHMapTreeNode* node, CCHMapTreeNodeData data, int bucketCapacity)
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

void CCHMapTreeGatherDataInRange(CCHMapTreeNode* node, CCHMapTreeBoundingBox range, TBDataReturnBlock block)
{
    if (!CCHMapTreeBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) {
        return;
    }

    for (int i = 0; i < node->count; i++) {
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

void CCHMapTreeGatherDataInRange2(CCHMapTreeNode* node, CCHMapTreeBoundingBox range, __unsafe_unretained NSMutableSet *annotations)
{
    if (!CCHMapTreeBoundingBoxIntersectsBoundingBox(node->boundingBox, range)) {
        return;
    }
    
    for (int i = 0; i < node->count; i++) {
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

void CCHMapTreeTraverse(CCHMapTreeNode* node, CCHMapTreeTraverseBlock block)
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

CCHMapTreeNode* CCHMapTreeBuildWithData(CCHMapTreeNodeData *data, int count, CCHMapTreeBoundingBox boundingBox, int bucketCapacity)
{
    CCHMapTreeNode* root = CCHMapTreeNodeMake(boundingBox, bucketCapacity);
    for (int i = 0; i < count; i++) {
        CCHMapTreeNodeInsertData(root, data[i], bucketCapacity);
    }

    return root;
}

void CCHMapTreeFreeQuadTreeNode(CCHMapTreeNode* node)
{
    if (node->northWest != NULL) CCHMapTreeFreeQuadTreeNode(node->northWest);
    if (node->northEast != NULL) CCHMapTreeFreeQuadTreeNode(node->northEast);
    if (node->southWest != NULL) CCHMapTreeFreeQuadTreeNode(node->southWest);
    if (node->southEast != NULL) CCHMapTreeFreeQuadTreeNode(node->southEast);

//    for (int i=0; i < node->count; i++) {
//        free(node->points[i].data);
//    }
    free(node->points);
    free(node);
}
