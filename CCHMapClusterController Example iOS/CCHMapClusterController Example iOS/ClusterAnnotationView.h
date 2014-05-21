//
//  ClusterAnnotationView.h
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 09.01.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ClusterAnnotationView : MKAnnotationView

@property (nonatomic) NSUInteger count;
@property (nonatomic, getter = isBlue) BOOL blue;
@property (nonatomic, getter = isUniqueLocation) BOOL uniqueLocation;

@end
