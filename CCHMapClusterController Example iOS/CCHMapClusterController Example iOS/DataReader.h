//
//  DataReader.h
//  Macoun 2013
//
//  Created by Hoefele, Claus(choefele) on 20.09.13.
//  Copyright (c) 2013 Hoefele, Claus(choefele). All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKPointAnnotation;

@protocol DataReaderDelegate;

@interface DataReader : NSObject

@property (nonatomic, weak) id<DataReaderDelegate> delegate;

- (void)startReadingBerlinData;
- (void)startReadingUSData;
- (void)stopReadingData;

@property (nonatomic, strong) MKPointAnnotation *eastAnnotation;
@property (nonatomic, strong) MKPointAnnotation *westAnnotation;

@end
