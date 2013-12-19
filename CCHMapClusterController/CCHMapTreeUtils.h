//
//  TBQuadTree.h
//  TBQuadTree
//
//  Created by Theodore Calmes on 9/19/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

// Theodore Calmes @theocalmes
// @claushoefele, the source is under MIT, feel free to use it however you want. Cheers!
// 13 Dezember

#import <Foundation/Foundation.h>

typedef struct CCHMapTreeNodeData {
    double x, y;
    void *data;
} CCHMapTreeNodeData;
NS_INLINE CCHMapTreeNodeData CCHMapTreeNodeDataMake(double x, double y, void *data) {
    return (CCHMapTreeNodeData){x, y, data};
}

typedef struct CCHMapTreeBoundingBox {
    double x0, y0, xf, yf;
} CCHMapTreeBoundingBox;
NS_INLINE CCHMapTreeBoundingBox CCHMapTreeBoundingBoxMake(double x0, double y0, double xf, double yf) {
    return (CCHMapTreeBoundingBox){x0, y0, xf, yf};
}

typedef struct CCHMapTreeNode {
    CCHMapTreeBoundingBox boundingBox;
    struct CCHMapTreeNode *northWest;
    struct CCHMapTreeNode *northEast;
    struct CCHMapTreeNode *southWest;
    struct CCHMapTreeNode *southEast;
    CCHMapTreeNodeData *points;
    int count;
} CCHMapTreeNode;
CCHMapTreeNode *CCHMapTreeNodeMake(CCHMapTreeBoundingBox boundary, int bucketCapacity);
void CCHMapTreeFreeQuadTreeNode(CCHMapTreeNode *node);

typedef void(^CCHMapTreeTraverseBlock)(CCHMapTreeNode *currentNode);
void CCHMapTreeTraverse(CCHMapTreeNode *node, CCHMapTreeTraverseBlock block);

typedef void(^TBDataReturnBlock)(CCHMapTreeNodeData data);
void CCHMapTreeGatherDataInRange(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, TBDataReturnBlock block);

bool CCHMapTreeNodeInsertData(CCHMapTreeNode* node, CCHMapTreeNodeData data, int bucketCapacity);
CCHMapTreeNode *CCHMapTreeBuildWithData(CCHMapTreeNodeData *data, int count, CCHMapTreeBoundingBox boundingBox, int bucketCapacity);
