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

@implementation DataReader

- (void)startReading
{
    // Parse on background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *file = [NSBundle.mainBundle pathForResource:@"Data" ofType:@"json"];
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
        
- (void)dispatchAnnotations:(NSArray *)annotations
{
    // Dispatch on main thread with some delay to simulate network requests
    NSArray *annotationsToDispatch = [annotations copy];
    static int counter = 0;
    double delayInSeconds = counter++ * 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.delegate dataReader:self addAnnotations:annotationsToDispatch];
    });
}

@end
