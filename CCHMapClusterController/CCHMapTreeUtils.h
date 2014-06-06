//
//  CCHMapTreeUtils.h
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

#import <Foundation/Foundation.h>

@interface CCHMapTreeUnsafeMutableArray : NSObject

@property (nonatomic, assign, readonly) id __unsafe_unretained *objects;
@property (nonatomic, readonly) NSUInteger numObjects;

- (instancetype)initWithCapacity:(NSUInteger)capacity;
- (void)addObject:(__unsafe_unretained id)object;

@end

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
    unsigned long count;
} CCHMapTreeNode;
CCHMapTreeNode *CCHMapTreeNodeMake(CCHMapTreeBoundingBox boundary, unsigned long bucketCapacity);
void CCHMapTreeFreeQuadTreeNode(CCHMapTreeNode *node);

typedef void(^CCHMapTreeTraverseBlock)(CCHMapTreeNode *currentNode);
void CCHMapTreeTraverse(CCHMapTreeNode *node, CCHMapTreeTraverseBlock block);

typedef void(^TBDataReturnBlock)(CCHMapTreeNodeData data);
void CCHMapTreeGatherDataInRange(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, TBDataReturnBlock block);
void CCHMapTreeGatherDataInRange2(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, __unsafe_unretained NSMutableSet *annotations);
void CCHMapTreeGatherDataInRange3(CCHMapTreeNode *node, CCHMapTreeBoundingBox range, __unsafe_unretained CCHMapTreeUnsafeMutableArray *annotations);

CCHMapTreeNode *CCHMapTreeBuildWithData(CCHMapTreeNodeData *data, unsigned long count, CCHMapTreeBoundingBox boundingBox, unsigned long bucketCapacity);
bool CCHMapTreeNodeInsertData(CCHMapTreeNode* node, CCHMapTreeNodeData data, unsigned long bucketCapacity);
bool CCHMapTreeNodeRemoveData(CCHMapTreeNode* node, CCHMapTreeNodeData data); // only removes first matching item