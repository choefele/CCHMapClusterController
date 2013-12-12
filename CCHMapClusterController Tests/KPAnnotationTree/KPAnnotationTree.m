//
// Copyright 2012 Bryan Bonczek
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "KPAnnotationTree.h"
#import "KPTreeNode.h"
#import "KPAnnotation.h"

#if 0
#define BBTreeLog(...) NSLog(__VA_ARGS__)
#else
#define BBTreeLog(...) ((void) 0)
#endif

@interface KPAnnotationTree ()

@property (nonatomic) KPTreeNode *root;
@property (nonatomic, readwrite) NSSet *annotations;

@end

@implementation KPAnnotationTree

- (id)initWithAnnotations:(NSArray *)annotations {
    
    self = [super init];
    
    if(self){
        self.annotations = [NSSet setWithArray:annotations];
        self.root = [self buildTree:annotations level:0];
    }
    
    return self;
}

#pragma mark - Search

- (NSArray *)annotationsInMapRect:(MKMapRect)rect {
    
    NSMutableArray *result = [NSMutableArray array];
    
    [self doSearchInMapRect:rect
         mutableAnnotations:result
                    curNode:self.root
                   curLevel:0];
    
    return result;
}


- (void)doSearchInMapRect:(MKMapRect)mapRect 
       mutableAnnotations:(NSMutableArray *)annotations 
                  curNode:(KPTreeNode *)curNode
                 curLevel:(NSInteger)level {
    
    if(curNode == nil){
        return;
    }
    
    MKMapPoint mapPoint = curNode.mapPoint;
   
    BBTreeLog(@"Testing (%f, %f)...", [curNode.annotation coordinate].latitude, [curNode.annotation coordinate].longitude);
    
    if(MKMapRectContainsPoint(mapRect, mapPoint)){
        BBTreeLog(@"YES");
        [annotations addObject:curNode.annotation];
    }
    else {
        BBTreeLog(@"RECT: NO");
    }
    
    BOOL useY = (BOOL)(level % 2);

    float val = (useY ? mapPoint.y : mapPoint.x);
    float minVal = (useY ? mapRect.origin.y : mapRect.origin.x);
    float maxVal = (useY ? (mapRect.origin.y + mapRect.size.height) : (mapRect.origin.x + mapRect.size.width));
    
    if(maxVal < val){
        
        [self doSearchInMapRect:mapRect
             mutableAnnotations:annotations
                        curNode:curNode.left
                       curLevel:(level + 1)];
    }
    else if(minVal > val){
        
        [self doSearchInMapRect:mapRect
             mutableAnnotations:annotations
                        curNode:curNode.right
                       curLevel:(level + 1)];
    }
    else {
        
        [self doSearchInMapRect:mapRect
             mutableAnnotations:annotations
                        curNode:curNode.left
                       curLevel:(level + 1)];
        
        [self doSearchInMapRect:mapRect
             mutableAnnotations:annotations
                        curNode:curNode.right
                       curLevel:(level + 1)];
    }
    
}

#pragma mark - MKMapView


#pragma mark - Tree Building (Private)


- (KPTreeNode *)buildTree:(NSArray *)annotations level:(NSInteger)curLevel {
    
    NSInteger count = [annotations count];
    
    if(count == 0){
        return nil;
    }
    
    KPTreeNode *n = [[KPTreeNode alloc] init];
        
    BOOL sortY = (BOOL)(curLevel % 2);
    
    //TODO: build the tree without sorting at every level
    NSArray *sortedAnnotations = [self sortedAnnotations:annotations sortY:sortY];
    
    // store median in tree and recurse through left and right sub arrays
    NSInteger medianIdx = [sortedAnnotations count] / 2;
    
    n.annotation = [sortedAnnotations objectAtIndex:medianIdx];
    n.mapPoint = MKMapPointForCoordinate(n.annotation.coordinate);

    n.left = [self buildTree:[sortedAnnotations subarrayWithRange:NSMakeRange(0, medianIdx)] 
                       level:(curLevel + 1)];
    
    
    n.right = [self buildTree:[sortedAnnotations subarrayWithRange:NSMakeRange((medianIdx + 1), (count - (medianIdx + 1)))]
                        level:(curLevel + 1)];
    
    
    return n;
}

- (NSArray *)sortedAnnotations:(NSArray *)annotations sortY:(BOOL)sortY {
    
    return [annotations sortedArrayUsingComparator:^NSComparisonResult(id<MKAnnotation> a1, id<MKAnnotation> a2) {
        
        MKMapPoint p1 = MKMapPointForCoordinate([a1 coordinate]);
        MKMapPoint p2 = MKMapPointForCoordinate([a2 coordinate]);
        
        float val1 = (sortY ? p1.y : p1.x);
        float val2 = (sortY ? p2.y : p2.x);
        
        if(val1 > val2){
            return NSOrderedDescending;
        }
        else if(val1 < val2){
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }

    }];
    
}

@end
