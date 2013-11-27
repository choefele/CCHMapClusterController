CCHMapClustering
================

If you have your project set up with an `MKMapView`, integrating clustering will take 4 lines of code:

<pre>
<b>#import "CCHMapClusterController.h"</b>
  
@interface ViewController()

<b>@property (strong, nonatomic) CCHMapClusterController *mapClusterController;</b>

@end

- (void)viewDidLoad
{
  [super viewDidLoad]
    
  NSArray annotations = ...
  <b>self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
  [self.mapClusterController addAnnotations:annotations withCompletionHandler:NULL];</b>
}
</pre>

![Map Clustering](MapClustering.png "Map Clustering")

## Customizing annotation views

Your code can customize titles and subtitles of the clustered annotations by setting itself as `CCHMapClusterControllerDelegate` and implementing two delegate methods. Here is an example:

    - (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController
        titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
    {
        NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;
        NSString *unit = numAnnotations > 1 ? @"annotations" : @"annotation";
        return [NSString stringWithFormat:@"%tu %@", numAnnotations, unit];
    }

    - (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController
        subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
    {
        NSUInteger numAnnotations = MIN(mapClusterAnnotation.annotations.count, 5);
        NSArray *annotations = [mapClusterAnnotation.annotations subarrayWithRange:NSMakeRange(0, numAnnotations)];
        NSArray *titles = [annotations valueForKey:@"title"];
        return [titles componentsJoinedByString:@", "];
    }

Further customization of the annotation view is possible via the standard `mapView:viewForAnnotation:` method that's part of `MKMapViewDelegate`.

## Debugging

## License (MIT)

Copyright (C) 2013 Option-U Software

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
