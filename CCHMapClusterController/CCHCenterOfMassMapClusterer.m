//
//  CCHCenterOfMassMapClusterer.m
//  CCHMapClusterController
//
//  Copyright (C) 2013 Claus Höfele
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CCHCenterOfMassMapClusterer.h"

@implementation CCHCenterOfMassMapClusterer

- (CLLocationCoordinate2D)mapClusterController:(CCHMapClusterController *)mapClusterController coordinateForAnnotations:(NSSet *)annotations inMapRect:(MKMapRect)mapRect
{
    double latitude = 0, longitude = 0;
    for (id<MKAnnotation> annotation in annotations) {
        latitude += annotation.coordinate.latitude;
        longitude += annotation.coordinate.longitude;
    }
    
    CLLocationCoordinate2D coordinate;
    if (annotations.count > 0) {
        double count = (double)annotations.count;
        coordinate = CLLocationCoordinate2DMake(latitude / count, longitude / count);
    } else {
        coordinate = CLLocationCoordinate2DMake(0, 0);
    }
    
    return coordinate;
}

@end
