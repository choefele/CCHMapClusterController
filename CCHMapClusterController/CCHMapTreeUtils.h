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
    double x;
    double y;
    void* data;
} CCHMapTreeNodeData;
CCHMapTreeNodeData CCHMapTreeNodeDataMake(double x, double y, void* data);

typedef struct CCHMapTreeBoundingBox {
    double x0; double y0;
    double xf; double yf;
} CCHMapTreeBoundingBox;
CCHMapTreeBoundingBox CCHMapTreeBoundingBoxMake(double x0, double y0, double xf, double yf);

typedef struct quadTreeNode {
    struct quadTreeNode* northWest;
    struct quadTreeNode* northEast;
    struct quadTreeNode* southWest;
    struct quadTreeNode* southEast;
    CCHMapTreeBoundingBox boundingBox;
    int bucketCapacity;
    CCHMapTreeNodeData *points;
    int count;
} CCHMapTreeNode;
CCHMapTreeNode* CCHMapTreeNodeMake(CCHMapTreeBoundingBox boundary, int bucketCapacity);

void CCHMapTreeFreeQuadTreeNode(CCHMapTreeNode* node);

bool CCHMapTreeBoundingBoxContainsData(CCHMapTreeBoundingBox box, CCHMapTreeNodeData data);
bool CCHMapTreeBoundingBoxIntersectsBoundingBox(CCHMapTreeBoundingBox b1, CCHMapTreeBoundingBox b2);

typedef void(^CCHMapTreeTraverseBlock)(CCHMapTreeNode* currentNode);
void CCHMapTreeTraverse(CCHMapTreeNode* node, CCHMapTreeTraverseBlock block);

typedef void(^TBDataReturnBlock)(CCHMapTreeNodeData data);
void CCHMapTreeGatherDataInRange(CCHMapTreeNode* node, CCHMapTreeBoundingBox range, TBDataReturnBlock block);

bool CCHMapTreeNodeInsertData(CCHMapTreeNode* node, CCHMapTreeNodeData data);
CCHMapTreeNode* CCHMapTreeBuildWithData(CCHMapTreeNodeData *data, int count, CCHMapTreeBoundingBox boundingBox, int capacity);
