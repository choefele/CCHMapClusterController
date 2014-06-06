//
//  ClusterAnnotationView.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 09.01.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

// Based on https://github.com/thoughtbot/TBAnnotationClustering/blob/master/TBAnnotationClustering/TBClusterAnnotationView.m by Theodore Calmes

#import "ClusterAnnotationView.h"

@interface ClusterAnnotationView ()

@property (nonatomic) UILabel *countLabel;

@end

@implementation ClusterAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
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
    [self setNeedsLayout];
}

- (void)setBlue:(BOOL)blue
{
    _blue = blue;
    [self setNeedsLayout];
}

- (void)setUniqueLocation:(BOOL)uniqueLocation
{
    _uniqueLocation = uniqueLocation;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    // Images are faster than using drawRect:
    UIImage *image;
    CGPoint centerOffset;
    CGRect countLabelFrame;
    if (self.isUniqueLocation) {
        NSString *imageName = self.isBlue ? @"SquareBlue" : @"SquareRed";
        image = [UIImage imageNamed:imageName];
        centerOffset = CGPointMake(0, image.size.height * 0.5);
        CGRect frame = self.bounds;
        frame.origin.y -= 2;
        countLabelFrame = frame;
    } else {
        NSString *suffix;
        if (self.count > 1000) {
            suffix = @"39";
        } else if (self.count > 500) {
            suffix = @"38";
        } else if (self.count > 200) {
            suffix = @"36";
        } else if (self.count > 100) {
            suffix = @"34";
        } else if (self.count > 50) {
            suffix = @"31";
        } else if (self.count > 20) {
            suffix = @"28";
        } else if (self.count > 10) {
            suffix = @"25";
        } else if (self.count > 5) {
            suffix = @"24";
        } else {
            suffix = @"21";
        }
        
        NSString *imageName = [NSString stringWithFormat:@"%@%@", self.isBlue ? @"CircleBlue" : @"CircleRed", suffix];
        image = [UIImage imageNamed:imageName];

        centerOffset = CGPointZero;
        countLabelFrame = self.bounds;
    }
    
    self.countLabel.frame = countLabelFrame;
    self.image = image;
    self.centerOffset = centerOffset;
}

@end
