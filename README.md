CCHMapClusterController
=======================

[![Build Status](https://travis-ci.org/choefele/CCHMapClusterController.png?branch=master)](https://travis-ci.org/choefele/CCHMapClusterController)

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

<p align="center" >
  <img src="MapClustering.png" alt="AFNetworking" title="Map Clustering">
</p>

## Installation

Use [CocoaPods](http://cocoapods.org) for easily integrating `CCHMapClusterController` into your project. Minum deployment targets are 6.0 for iOS and 10.9 for OS X.

```ruby
platform :ios, '6.0'
pod "CCHMapClusterController"
```

```ruby
platform :osx, '10.9'
pod "CCHMapClusterController"
```

## Customizing annotation views

Your code can customize titles and subtitles of the clustered annotations by setting itself as `CCHMapClusterControllerDelegate` and implementing two delegate methods. Here is an example:

```Objective-C
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
```

Further customization of the annotation view is possible via the standard `mapView:viewForAnnotation:` method that's part of `MKMapViewDelegate`.

## Cell size and margin factor

The clustering algorithm splits a rectangular area of the map into a grid of square cells. For each cell, a representation for the annotations in this cell is selected and displayed. 

`CCHMapClusterController` has a property `cellSize` to configure the size of the cell. The unit is points (1 point = 2 pixels on Retina displays). This way, you can select a cell size that is large enough to display map icons with minimal overlap. More likely, however, you will choose the cell size to optimize clustering performance (the larger the size, the better the performance).

The `marginFactor` property configures the additional map area around the visible area that's included for clustering. This avoids sudden changes at the edges of the visible map area when the user pans the map. Ideally, you would set this value to 1.0 (100% additional map area on each side), as this is the maximum scroll area a user can achieve with a paning gesture. However, this is affects performance as this will cover 9x the map area for clustering. The default is 0.5 (50% additional area on each side).

To debug these settings, set the `debugEnabled` property to `YES`. This will display the grid used for clustering overlayed onto the map.

## Selecting annotations

A common use case is to have a search field where the user can look for a specific annotation. Selecting this annotation would then zoom to its position on the map. 

For this to work, you have to figure out which cluster contains the selected annotation. In addition, the clustering changes while zooming thus requiring an incremental approach to finding the cluster that contains the annotation the user is looking for.

`CCHMapClusterController` contains an easy to use interface to help you with this:

```Objective-C
[self.mapClusterController selectAnnotation:annotation 
       andZoomToRegionWithLatitudinalMeters:1000 
                         longitudinalMeters:1000];
``` 

## License (MIT)

Copyright (C) 2013 Claus Höfele

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
