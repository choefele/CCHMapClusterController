//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "QTree.h"
#import "QNode.h"

@interface QTree()

@property(nonatomic, strong) QNode* rootNode;

@end

@implementation QTree

-(id)init
{
	self = [super init];
	if( !self ) {
    return nil;
  }
	[self cleanup];
	return self;
}

- (void) cleanup
{
    self.rootNode = [[QNode alloc] initWithRegion:MKCoordinateRegionForMapRect(MKMapRectWorld)];
}

-(void)insertObject:(id<QTreeInsertable>)insertableObject
{
  [self.rootNode insertObject:insertableObject];
}

-(NSUInteger)count
{
  return self.rootNode.count;
}

-(NSArray*)getObjectsInRegion:(MKCoordinateRegion)region minNonClusteredSpan:(CLLocationDegrees)span
{
	return [self.rootNode getObjectsInRegion:region minNonClusteredSpan:span];
}

-(NSArray*)neighboursForLocation:(CLLocationCoordinate2D)location limitCount:(NSUInteger)limit
{
	return [self.rootNode neighboursForLocation:location limitCount:limit];
}

@end
