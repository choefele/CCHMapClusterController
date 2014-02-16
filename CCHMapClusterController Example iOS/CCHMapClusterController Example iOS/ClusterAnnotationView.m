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

- (void)setBlue:(BOOL)blue
{
    _blue = blue;
    [self update];
}

- (void)update
{
    self.countLabel.frame = self.bounds;
    
    // Images are faster than using drawRect:
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

    NSString *prefix = self.isBlue ? @"CircleBlue" : @"CircleRed";
    self.image = [UIImage imageNamed:[prefix stringByAppendingString:suffix]];
}

@end
