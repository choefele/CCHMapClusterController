//
//  DataReader.h
//  Macoun 2013
//
//  Created by Hoefele, Claus(choefele) on 20.09.13.
//  Copyright (c) 2013 Hoefele, Claus(choefele). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataReaderDelegate;

@interface DataReader : NSObject

@property (nonatomic, weak) id<DataReaderDelegate> delegate;

- (void)startReadingBerlinData;
- (void)startReadingUSData;
- (void)stopReadingData;

@end
