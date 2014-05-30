//
//  CCHMapClusterControllerUtils.m
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

#import "CCHMapClusterControllerUtils.h"

#import "CCHMapClusterAnnotation.h"

#import <float.h>

#define fequal(a, b) (fabs((a) - (b)) < __FLT_EPSILON__)
#define GEOHASH_LENGTH 9

MKMapRect CCHMapClusterControllerAlignMapRectToCellSize(MKMapRect mapRect, double cellSize)
{
    if (cellSize == 0) {
        return MKMapRectNull;
    }

    double startX = floor(MKMapRectGetMinX(mapRect) / cellSize) * cellSize;
    double startY = floor(MKMapRectGetMinY(mapRect) / cellSize) * cellSize;
    double endX = ceil(MKMapRectGetMaxX(mapRect) / cellSize) * cellSize;
    double endY = ceil(MKMapRectGetMaxY(mapRect) / cellSize) * cellSize;
    
    return MKMapRectMake(startX, startY, endX - startX, endY - startY);
}

CCHMapClusterAnnotation *CCHMapClusterControllerFindVisibleAnnotation(NSSet *annotations, NSSet *visibleAnnotations)
{
    for (id<MKAnnotation> annotation in annotations) {
        for (CCHMapClusterAnnotation *visibleAnnotation in visibleAnnotations) {
            if ([visibleAnnotation.annotations containsObject:annotation]) {
                return visibleAnnotation;
            }
        }
    }
    
    return nil;
}

#if TARGET_OS_IPHONE
double CCHMapClusterControllerMapLengthForLength(MKMapView *mapView, UIView *view, double length)
#else
double CCHMapClusterControllerMapLengthForLength(MKMapView *mapView, NSView *view, double length)
#endif
{
    // Convert points to coordinates
    CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:CGPointZero toCoordinateFromView:view];
    CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:CGPointMake(length, 0) toCoordinateFromView:view];
    
    // Convert coordinates to map points
    MKMapPoint leftMapPoint = MKMapPointForCoordinate(leftCoordinate);
    MKMapPoint rightMapPoint = MKMapPointForCoordinate(rightCoordinate);

    // Calculate distance between map points
    double xd = leftMapPoint.x - rightMapPoint.x;
    double yd = leftMapPoint.y - rightMapPoint.y;
    double mapLength = sqrt(xd*xd + yd*yd);
    
    // For very large lengths, we assume that we measured the other way around the world
    if (mapLength > (MKMapSizeWorld.width * 0.5)) {
        mapLength = MKMapSizeWorld.width - mapLength;
    }
    
    return mapLength;
}

double CCHMapClusterControllerAlignMapLengthToWorldWidth(double mapLength)
{
    if (mapLength == 0) {
        return 0;
    }

    mapLength = MKMapSizeWorld.width / floor(MKMapSizeWorld.width / mapLength);
    return mapLength;
}

BOOL CCHMapClusterControllerCoordinateEqualToCoordinate(CLLocationCoordinate2D coordinate0, CLLocationCoordinate2D coordinate1)
{
    BOOL isCoordinateUpToDate = fequal(coordinate0.latitude, coordinate1.latitude) && fequal(coordinate0.longitude, coordinate1.longitude);
    return isCoordinateUpToDate;
}

CCHMapClusterAnnotation *CCHMapClusterControllerClusterAnnotationForAnnotation(MKMapView *mapView, id<MKAnnotation> annotation, MKMapRect mapRect)
{
    CCHMapClusterAnnotation *annotationResult;
    
    NSSet *mapAnnotations = [mapView annotationsInMapRect:mapRect];
    for (id<MKAnnotation> mapAnnotation in mapAnnotations) {
        if ([mapAnnotation isKindOfClass:CCHMapClusterAnnotation.class]) {
            CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)mapAnnotation;
            if (mapClusterAnnotation.annotations) {
                if ([mapClusterAnnotation.annotations containsObject:annotation]) {
                    annotationResult = mapClusterAnnotation;
                    break;
                }
            }
        }
    }
    
    return annotationResult;
}

void CCHMapClusterControllerEnumerateCells(MKMapRect mapRect, double cellSize, void (^block)(MKMapRect cellMapRect))
{
    NSCAssert(block != NULL, @"Block argument can't be NULL");
    if (block == nil) {
        return;
    }
    
    MKMapRect cellRect = MKMapRectMake(0, MKMapRectGetMinY(mapRect), cellSize, cellSize);
    while (MKMapRectGetMinY(cellRect) < MKMapRectGetMaxY(mapRect)) {
        cellRect.origin.x = MKMapRectGetMinX(mapRect);
        
        while (MKMapRectGetMinX(cellRect) < MKMapRectGetMaxX(mapRect)) {
            // Wrap around the origin's longitude
            MKMapRect rect = MKMapRectMake(fmod(cellRect.origin.x, MKMapSizeWorld.width), cellRect.origin.y, cellRect.size.width, cellRect.size.height);
            block(rect);
            
            cellRect.origin.x += MKMapRectGetWidth(cellRect);
        }
        cellRect.origin.y += MKMapRectGetWidth(cellRect);
    }
}

MKMapRect CCHMapClusterControllerMapRectForCoordinateRegion(MKCoordinateRegion coordinateRegion)
{
    CLLocationCoordinate2D topLeftCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude + (coordinateRegion.span.latitudeDelta / 2.0), coordinateRegion.center.longitude - (coordinateRegion.span.longitudeDelta / 2.0));
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate = CLLocationCoordinate2DMake(coordinateRegion.center.latitude - (coordinateRegion.span.latitudeDelta / 2.0), coordinateRegion.center.longitude + (coordinateRegion.span.longitudeDelta / 2.0));
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x, topLeftMapPoint.y, fabs(bottomRightMapPoint.x - topLeftMapPoint.x), fabs(bottomRightMapPoint.y - topLeftMapPoint.y));
    
    return mapRect;
}

NSSet *CCHMapClusterControllerClusterAnnotationsForAnnotations(NSArray *annotations, CCHMapClusterController *mapClusterController)
{
    NSSet *filteredAnnotations = [NSMutableSet setWithArray:annotations];
    filteredAnnotations = [filteredAnnotations filteredSetUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        BOOL evaluation = NO;
        if ([evaluatedObject isKindOfClass:CCHMapClusterAnnotation.class]) {
            CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)evaluatedObject;
            evaluation = (clusterAnnotation.mapClusterController == mapClusterController);
        }
        return evaluation;
    }]];
    
    return filteredAnnotations;
}

NS_INLINE double originXForLongitudeAtZoomLevel22(CLLocationDegrees longitude)
{
    const double MERCATOR_OFFSET = 536870912;  // (width in points at zoom level 22) / 2
    const double MERCATOR_RADIUS_SCALE = MERCATOR_OFFSET / 180.0;
    
    return MERCATOR_OFFSET + MERCATOR_RADIUS_SCALE * longitude;
}

double CCHMapClusterControllerZoomLevelForRegion(CLLocationDegrees longitudeCenter, CLLocationDegrees longitudeDelta, CGFloat width)
{
    // Based on http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/
    // Adjusted so that at zoom level 0, the entire world fits into a single 256 point tile.
    const double LOG_2 = 0.69314718055994529;  // log(2)
    
    double centerPointX = originXForLongitudeAtZoomLevel22(longitudeCenter);
    double topLeftPointX = originXForLongitudeAtZoomLevel22(longitudeCenter - longitudeDelta / 2);
    
    double scaledMapWidth = (centerPointX - topLeftPointX) * 2;
    double zoomScale = scaledMapWidth / width;
    double zoomExponent = log(zoomScale) / LOG_2;
    double zoomLevel = 22 - zoomExponent;
    
    return zoomLevel;
}

#define MAX_HASH_LENGTH 22

#define SET_BIT(bits, mid, range, value, offset) \
    mid = ((range)->max + (range)->min) / 2.0; \
    if ((value) >= mid) { \
        (range)->min = mid; \
        (bits) |= (0x1 << (offset)); \
    } else { \
        (range)->max = mid; \
        (bits) |= (0x0 << (offset)); \
    }

static const char BASE32_ENCODE_TABLE[33] = "0123456789bcdefghjkmnpqrstuvwxyz";

typedef struct {
    double max;
    double min;
} GEOHASH_range;

static char *GEOHASH_encode(double lat, double lon, unsigned long len)
{
    unsigned long i;
    char *hash;
    unsigned char bits = 0;
    double mid;
    GEOHASH_range lat_range = {  90,  -90 };
    GEOHASH_range lon_range = { 180, -180 };
    
    double val1, val2, val_tmp;
    GEOHASH_range *range1, *range2, *range_tmp;
    
    assert(lat >= -90.0);
    assert(lat <= 90.0);
    assert(lon >= -180.0);
    assert(lon <= 180.0);
    assert(len <= MAX_HASH_LENGTH);
    
    hash = (char *)malloc(sizeof(char) * (len + 1));
    if (hash == NULL)
        return NULL;
    
    val1 = lon; range1 = &lon_range;
    val2 = lat; range2 = &lat_range;
    
    for (i=0; i < len; i++) {
        
        bits = 0;
        
        SET_BIT(bits, mid, range1, val1, 4);
        SET_BIT(bits, mid, range2, val2, 3);
        SET_BIT(bits, mid, range1, val1, 2);
        SET_BIT(bits, mid, range2, val2, 1);
        SET_BIT(bits, mid, range1, val1, 0);
        
        hash[i] = BASE32_ENCODE_TABLE[bits];
        
        val_tmp   = val1;
        val1      = val2;
        val2      = val_tmp;
        range_tmp = range1;
        range1    = range2;
        range2    = range_tmp;
    }
    
    hash[len] = '\0';
    return hash;
}

static NSString *hashForCoordinate(CLLocationCoordinate2D coordinate, NSUInteger length)
{
    // Based on https://github.com/lyokato/objc-geohash
    NSString *geohashAsString;
    
    char *geohash = GEOHASH_encode(coordinate.latitude, coordinate.longitude, length);
    if (geohash) {
        geohashAsString = [NSString stringWithCString:geohash encoding:NSASCIIStringEncoding];
    }
    free(geohash);
    
    return geohashAsString;
}

NSArray *CCHMapClusterControllerAnnotationSetsByUniqueLocations(NSSet *annotations, NSUInteger maxUniqueLocations)
{
    NSMutableDictionary *annotationsByGeohash;
    
    if (maxUniqueLocations > 0) {
        annotationsByGeohash = [NSMutableDictionary dictionary];
        
        for (id<MKAnnotation> annotation in annotations) {
            // Add annotation to unique locations
            NSString *geohash = hashForCoordinate(annotation.coordinate, GEOHASH_LENGTH);
            NSMutableSet *annotationsAtLocation = [annotationsByGeohash objectForKey:geohash];
            if (!annotationsAtLocation) {
                annotationsAtLocation = [NSMutableSet set];
            }
            [annotationsAtLocation addObject:annotation];
            [annotationsByGeohash setObject:annotationsAtLocation forKey:geohash];
            
            // Return nil if max has been reached
            if (annotationsByGeohash.count > maxUniqueLocations) {
                annotationsByGeohash = nil;
                break;
            }
        }
    }
    
    return [annotationsByGeohash allValues];
}

BOOL CCHMapClusterControllerIsUniqueLocation(NSSet *annotations)
{
    NSString *geohash;
    for (id<MKAnnotation> annotation in annotations) {
        NSString *updatedGeohash = hashForCoordinate(annotation.coordinate, GEOHASH_LENGTH);
        if (geohash == nil) {
            geohash = updatedGeohash;
        } else if (![geohash isEqualToString:updatedGeohash]) {
            geohash = nil;
            break;
        }
    }
    
    return (geohash != nil);
}