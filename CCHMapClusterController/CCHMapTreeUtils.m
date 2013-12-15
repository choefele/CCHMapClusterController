//
//  TBQuadTree.m
//  TBQuadTree
//
//  Created by Theodore Calmes on 9/19/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "CCHMapTreeUtils.h"

#pragma mark - Constructors

CCHMapTreeNodeData CCHMapTreeNodeDataMake(double x, double y, void* data)
{
    CCHMapTreeNodeData d; d.x = x; d.y = y; d.data = data;
    return d;
}

CCHMapTreeBoundingBox CCHMapTreeBoundingBoxMake(double x0, double y0, double xf, double yf)
{
    CCHMapTreeBoundingBox bb; bb.x0 = x0; bb.y0 = y0; bb.xf = xf; bb.yf = yf;
    return bb;
}

CCHMapTreeNode* CCHMapTreeNodeMake(CCHMapTreeBoundingBox boundary, int bucketCapacity)
{
    CCHMapTreeNode* node = malloc(sizeof(CCHMapTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;

    node->boundingBox = boundary;
    node->bucketCapacity = bucketCapacity;
    node->count = 0;
    node->points = malloc(sizeof(CCHMapTreeNodeData) * bucketCapacity);

    return node;
}

#pragma mark - Bounding Box Functions

bool CCHMapTreeBoundingBoxContainsData(CCHMapTreeBoundingBox box, CCHMapTreeNodeData data)
{
    bool containsX = box.x0 <= data.x && data.x <= box.xf;
    bool containsY = box.y0 <= data.y && data.y <= box.yf;

    return containsX && containsY;
}

bool CCHMapTreeBoundingBoxIntersectsBoundingBox(CCHMapTreeBoundingBox b1, CCHMapTreeBoundingBox b2)
{
    return (b1.x0 <= b2.xf && b1.xf >= b2.x0 && b1.y0 <= b2.yf && b1.yf >= b2.y0);
}

#pragma mark - Quad Tree Functions

void CCHMapTreeNodeSubdivide(CCHMapTreeNode* node)
{
    CCHMapTreeBoundingBox box = node->boundingBox;

    double xMid = (box.xf + box.x0) / 2.0;
    double yMid = (box.yf + box.y0) / 2.0;

    CCHMapTreeBoundingBox northWest = CCHMapTreeBoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = CCHMapTreeNodeMake(northWest, node->bucketCapacity);

    CCHMapTreeBoundingBox northEast = CCHMapTreeBoundingBoxMake(xMid, box.y0, box.xf, yMid);
    node->northEast = CCHMapTreeNodeMake(northEast, node->bucketCapacity);

    CCHMapTreeBoundingBox southWest = CCHMapTreeBoundingBoxMake(box.x0, yMid, xMid, box.yf);
    node->southWest = CCHMapTreeNodeMake(southWest, node->bucketCapacity);

    CCHMapTreeBoundingBox southEast = CCHMapTreeBoundingBoxMake(xMid, yMid, box.xf, box.yf);
    node->southEast = CCHMapTreeNodeMake(southEast, node->bucketCapacity);
}

bool CCHMapTreeNodeInsertData(CCHMapTreeNode* node, CCHMapTreeNodeData data)
{
    if (!CCHMapTreeBoundingBoxContainsData(node->boundingBox, data)) {
        return false;
    }

    if (node->count < node->bucketCapacity) {
        node->points[node->count++] = data;
        return true;
    }

    if (node->northWest == NULL) {
        CCHMapTreeNodeSubdivide(node);
    }

    if (CCHMapTreeNodeInsertData(node->northWest, data)) return true;
    if (CCHMapTreeNodeInsertData(node->northEast, data)) return true;
    if (CCHMapTreeNodeInsertData(node->southWest, data)) return true;
    if (CCHMapTreeNodeInsertData(node->southEast, data)) return true;

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

CCHMapTreeNode* CCHMapTreeBuildWithData(CCHMapTreeNodeData *data, int count, CCHMapTreeBoundingBox boundingBox, int capacity)
{
    CCHMapTreeNode* root = CCHMapTreeNodeMake(boundingBox, capacity);
    for (int i = 0; i < count; i++) {
        CCHMapTreeNodeInsertData(root, data[i]);
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
