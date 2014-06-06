//
//  DataReader.m
//  Macoun 2013
//
//  Created by Hoefele, Claus(choefele) on 20.09.13.
//  Copyright (c) 2013 Hoefele, Claus(choefele). All rights reserved.
//

#import "DataReader.h"

#import "DataReaderDelegate.h"

#import <MapKit/MapKit.h>

#define BATCH_COUNT 500
#define DELAY_BETWEEN_BATCHES 0.3

@interface DataReader()

@property (nonatomic) NSOperationQueue *operationQueue;

@end

@implementation DataReader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

- (void)startReadingBerlinData
{
    // Parse on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *file = [NSBundle.mainBundle pathForResource:@"Berlin-Data" ofType:@"json"];
        NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:file];
        [inputStream open];
        NSArray *dataAsJson = [NSJSONSerialization JSONObjectWithStream:inputStream options:0 error:nil];
        
        NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:BATCH_COUNT];
        for (NSDictionary *annotationAsJSON in dataAsJson) {
            // Convert JSON into annotation object
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            NSString *latitudeAsString = [annotationAsJSON valueForKeyPath:@"location.coordinates.latitude"];
            NSString *longitudeAsString = [annotationAsJSON valueForKeyPath:@"location.coordinates.longitude"];
            annotation.coordinate = CLLocationCoordinate2DMake(latitudeAsString.doubleValue, longitudeAsString.doubleValue);
            annotation.title = [annotationAsJSON valueForKeyPath:@"person.lastName"];

            [annotations addObject:annotation];
            
            if (annotations.count == BATCH_COUNT) {
                // Dispatch batch of annotations
                [self dispatchAnnotations:annotations];
                [annotations removeAllObjects];
            }
        }
        
        // Dispatch remaining annotations
        [self dispatchAnnotations:annotations];
    });
}

- (void)startReadingUSData
{
    // Parse on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *file = [NSBundle.mainBundle pathForResource:@"USA-HotelMotel" ofType:@"csv"];
        NSArray *lines = [[NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:nil] componentsSeparatedByString:@"\n"];
        
        NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:BATCH_COUNT];
        for (NSString *line in lines) {
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if (trimmedLine.length > 0) {
                // Convert CSV into annotation object
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                NSArray *components = [line componentsSeparatedByString:@","];
                annotation.coordinate = CLLocationCoordinate2DMake([components[1] doubleValue], [components[0] doubleValue]);
                annotation.title = [components[2] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                
                [annotations addObject:annotation];
                
                if (annotations.count == BATCH_COUNT) {
                    // Dispatch batch of annotations
                    [self dispatchAnnotations:annotations];
                    [annotations removeAllObjects];
                }
            }
        }
        
        // Dispatch remaining annotations
        [self dispatchAnnotations:annotations];
    });
}

- (void)stopReadingData
{
    [self.operationQueue cancelAllOperations];
}
        
- (void)dispatchAnnotations:(NSArray *)annotations
{
    // Dispatch on main thread with some delay to simulate network requests
    NSArray *annotationsToDispatch = [annotations copy];
    [self.operationQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate dataReader:self addAnnotations:annotationsToDispatch];
        });
        [NSThread sleepForTimeInterval:DELAY_BETWEEN_BATCHES];
    }];
}

@end
