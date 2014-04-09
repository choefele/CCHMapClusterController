Changes
=======

## Upcoming version

- `CCHMapClusterController` now has a new property `maxZoomLevelForClustering`, which disables clustering if the current zoom level exceeds this value. When disabled, all cluster annotations on the map cluster will have one unique location. The current zoom level can be queried with the property `zoomLevel`. Thanks to tspacek for the code and onato and iGriever for suggesting this feature.
- Renamed property `isOneLocation` in `CCHMapClusterAnnotation` to `isUniqueLocation`

## 1.5.0

- Multiple `CCHMapClusterController`s can now use the same `MKMapView` instance. This allows you to have multiple groups of clusters where each group has its own settings (thanks to eikebartles for ideas and suggestions)
- `selectAnnotation:andZoomToRegionWithLatitudinalMeters:longitudinalMeters:` will now assert that the right annotation has been passed in. The documentation has also been updated with a better example on how to use this API (thanks to tspacek for the request)
- Added the method `mapRect` to `CCHMapClusterAnnotation` to calculate the area that includes all clustered annotations. Also added a code recipe on how to use this method to zoom in to a cluster.
- Updated code recipe for centering the map without changing the zoom level (thanks to plu for suggesting this)
- Added code recipe for showing callout accessory views dynamically (thanks to SSA111 for suggesting this)
- Added unit tests for animation code (thanks to nferruzzi for the pull request)

## 1.4.1

- Fixed issue where non-clustered `MKAnnotation`s would be removed from the map view (thanks to rosskimes for the pull request)
- Fixed bug that was causing `MKOverlayView`s/`MKOverlayRenderer`s to not show up (thanks to rosskimes for the pull request)
- Added a settings UI in example to configure clustering
- Updated annotation view in example to use pre-rendered images instead of `drawRect:` for best performance

## 1.4.0

- Added `removeAnnotations:withCompletionHandler:` to `CCHMapClusterController` to remove annotations from clustering (thanks to zeyadsalloum for suggesting this feature)
- Fixed bug when rotating map view

## 1.3.0

- Added new delegate method `mapClusterController:willReuseMapClusterAnnotation:` to `CCHMapClusterControllerDelegate` that's called when cluster annotations are reused
- Example updated to demonstrate annotation views which adapt to current cluster size
- Bugfixes and performance improvements
- Thanks to onato for suggesting these changes

## 1.2.0

- Switched to quad tree based on `TBQuadTree` to speed up performance
- Clustering now happens on a background thread for improved responsiveness
- Fixed issues when panning across the 180th meridian

## 1.1.0

- Added option to configure positioning of cluster annotations
- Added option to enable/disable reusing existing cluster annotations
- Added option to configure how cluster annotations are animated
- Added more unit tests and documentation

## 1.0.1

- Initial release
