//
//  AppDelegate.h
//  CCHMapClustering Example OS X
//
//  Created by Claus on 25.11.13.
//  Copyright (c) 2013 Claus Höfele. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
