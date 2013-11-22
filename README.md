CCHMapClustering
================

High-performance map clustering for MapKit. Integrate with 3 lines of code.

````
  #import "MapClusterController.h"
  
  - (void)viewDidLoad
  {
    ...
    self.mapClusterController = [[MapClusterController alloc] initWithMapView:self.mapView];
    [self.mapClusterController addAnnotations:annotations withCompletionHandler:NULL];
  }

````
