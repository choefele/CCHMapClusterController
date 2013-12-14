//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "QTreeGeometryUtils.h"

BOOL MKCoordinateRegionIntersectsRegion(MKCoordinateRegion region1, MKCoordinateRegion region2)
{
  const CLLocationDegrees dstLat = ABS(region1.center.latitude - region2.center.latitude);
  const CLLocationDegrees dstLng = ABS(region1.center.longitude - region2.center.longitude);
  return (dstLat < (region1.span.latitudeDelta + region2.span.latitudeDelta) / 2)
      && (dstLng < (region1.span.longitudeDelta + region2.span.longitudeDelta) / 2);
}

BOOL MKCoordinateRegionContainsCoordinate(MKCoordinateRegion region, CLLocationCoordinate2D coordinate)
{
  CLLocationDegrees dstLat = ABS(region.center.latitude - coordinate.latitude);
  CLLocationDegrees dstLng = ABS(region.center.longitude - coordinate.longitude);
  return (dstLat < region.span.latitudeDelta / 2) && (dstLng < region.span.longitudeDelta / 2);
}

CLLocationDistance CLMetersBetweenCoordinates(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
  return MKMetersBetweenMapPoints(MKMapPointForCoordinate(c1), MKMapPointForCoordinate(c2));
}

