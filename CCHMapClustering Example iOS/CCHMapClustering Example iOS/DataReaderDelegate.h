//
//  DataReaderDelegate.h
//  Macoun 2013
//
//  Created by Hoefele, Claus(choefele) on 20.09.13.
//  Copyright (c) 2013 Hoefele, Claus(choefele). All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataReader;

@protocol DataReaderDelegate <NSObject>

- (void)dataReader:(DataReader *)dataReader addAnnotations:(NSArray *)annotations;

@end
