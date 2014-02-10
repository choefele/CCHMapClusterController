//
//  ClusterAnnotationView.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 09.01.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

// Based on https://github.com/thoughtbot/TBAnnotationClustering/blob/master/TBAnnotationClustering/TBClusterAnnotationView.m by Theodore Calmes

#import "ClusterAnnotationView.h"
#import "CCHMapClusterAnnotation.h"

@interface ClusterAnnotationView ()

@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation ClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpLabel];
        [self setCount:1];
    }
    return self;
}

- (void)setUpLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.minimumScaleFactor = 2;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont boldSystemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    self.countLabel.text = [@(count) stringValue];
    [self update];
}

- (void)update
{
    self.countLabel.frame = self.bounds;
    
    // Images are faster than using drawRect:
    UIImage *image;
    if (self.count > 1000) {
        image = [UIImage imageNamed:@"Circle39"];
    } else if (self.count > 500) {
        image = [UIImage imageNamed:@"Circle38"];
    } else if (self.count > 200) {
        image = [UIImage imageNamed:@"Circle36"];
    } else if (self.count > 100) {
        image = [UIImage imageNamed:@"Circle34"];
    } else if (self.count > 50) {
        image = [UIImage imageNamed:@"Circle31"];
    } else if (self.count > 20) {
        image = [UIImage imageNamed:@"Circle28"];
    } else if (self.count > 10) {
        image = [UIImage imageNamed:@"Circle25"];
    } else if (self.count > 5) {
        image = [UIImage imageNamed:@"Circle24"];
    } else {
        image = [UIImage imageNamed:@"Circle21"];
    }
    self.image = image;
    
    
    if ([self.annotation isKindOfClass:[CCHMapClusterAnnotation class]]) {
        CCHMapClusterAnnotation * anno = self.annotation;
        
        if (anno.identifier == [NSNumber numberWithInt:1]) {
            self.image = [self image:image withColor:[UIColor blueColor]];
        }
    }
}


-(UIImage *)image:(UIImage *)img withColor:(UIColor *)color {
    // load the image
    
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
