Changes
=======
## 1.7.0
- Set minimum deployment target to iOS 7.0 and fix deprecation warnings.

## 1.6.6
- Fix implementation of `annotations` property. Thanks to tarbrain for the code.

## 1.6.5
- Make `annotations` property thread-safe. Thanks for alxon and nverinaud for reporting this problem.

## 1.6.4
- The completion handlers for `addAnnotations:withCompletionHandler:` and `removeAnnotations:withCompletionHandler:` are now guaranteed to be called on the main thread. Thanks to robertjpayne for the pull request

## 1.6.3
- `CCHMapClusterController` now builds with Xcode 6/iOS 8 (thanks to detouch for the pull request and rosskimes for letting me know about the problem)

## 1.6.2
- Excluded private header files from pod
- Updated documentation

## 1.6.1

- Bug fix for missing `CCHMapClusterController` instance in delegate methods (thanks to Palleas for the pull request)
- Added recipe to describe how `MKMapView` handles taps on annotation views (thanks to thomasouk for the question)

## 1.6.0

- `CCHMapClusterController` now has a new property `maxZoomLevelForClustering`, which disables clustering if the current zoom level exceeds this value. When disabled, all cluster annotations on the map cluster will have one unique location. The current zoom level can be queried with the property `zoomLevel`. Thanks to tspacek for the code and onato and iGriever for suggesting this feature.
- There's also a new property `minUniqueLocationsForClustering` that controls clustering for a cell based on the number of unique locations in a cell. Clustering is disabled if the number of unique locations in a cell is below this value.
- Renamed property `isOneLocation` in `CCHMapClusterAnnotation` to `isUniqueLocation`
- Removed asserts that triggered the exception 'Invalid map length' because my assumption that this could never happen was wrong. Thanks to zeyadsalloum and jas54 for helping me find this issue
- Fixed crash that was happening occasionally because the map view was accessed on a background thread. Thanks to zeyadsalloum, bpoplauschi, igordla, and rosskimes for helping me debug this issue

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
