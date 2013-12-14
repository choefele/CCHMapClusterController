//
//  CCHMapTreeTests.m
//  CCHMapClusterController Example iOS
//
//  Created by Claus on 15.12.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CCHMapTree.h"

@interface CCHMapTreeTests : XCTestCase

@property (nonatomic, strong) CCHMapTree *mapTree;

@end

@implementation CCHMapTreeTests

- (void)setUp
{
    [super setUp];
    
    self.mapTree = [[CCHMapTree alloc] init];
}

- (void)testContains
{
    
}
//    public void testContains() {
//        double[] key = new double[] {52.5191710, 13.40609120}; 
//        Object obj = new Object();
//        tree.add(key, obj);
//        double[] bottomLeft = new double[] {52.50, 13.40};
//        double[] topRight = new double[] {52.52, 13.41};
//        List<Object> list = tree.getRange(bottomLeft, topRight);
//        assertEquals(1, list.size());
//        assertTrue(list.contains(obj));
//    }

//    public void testContainsBorder() {
//        double[] bottomLeft = new double[] {52.50, 13.40};
//        double[] topRight = new double[] {52.52, 13.41};
//        Object obj0 = new Object();
//        tree.add(bottomLeft, obj0);
//        Object obj1 = new Object();
//        tree.add(topRight, obj1);
//        List<Object> list = tree.getRange(bottomLeft, topRight);
//        assertEquals(2, list.size());
//        assertTrue(list.contains(obj0));
//        assertTrue(list.contains(obj1));
//    }
//
//    public void testContainsSamePosition() {
//		double[] key = new double[] { 52.5191710, 13.40609120 };
//		Object obj0 = new Object();
//		tree.add(key, obj0);
//		Object obj1 = new Object();
//		tree.add(key, obj1);
//		double[] bottomLeft = new double[] { 52.50, 13.40 };
//		double[] topRight = new double[] { 52.52, 13.41 };
//		List<Object> list = tree.getRange(bottomLeft, topRight);
//		assertEquals(2, list.size());
//		assertTrue(list.contains(obj0));
//		assertTrue(list.contains(obj1));
//	}
//
//    public void testDoesNotContain(){
//        double[] key = new double[] {52.0, 13.40609120}; 
//        Object obj = new Object();
//        tree.add(key, obj);
//        double[] bottomLeft = new double[] {52.50, 13.40};
//        double[] topRight = new double[] {52.52, 13.41};
//        List<Object> list = tree.getRange(bottomLeft, topRight);
//        assertEquals(0, list.size());
//        assertFalse(list.contains(obj));
//    }

@end
