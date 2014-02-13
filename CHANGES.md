Changes
=======

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
