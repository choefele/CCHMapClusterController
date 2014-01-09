//
//  ClusterAnnotationView.m
//  CCHMapClusterController Example iOS
//
//  Created by Hoefele, Claus(choefele) on 09.01.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

// Based on https://github.com/thoughtbot/TBAnnotationClustering/blob/master/TBAnnotationClustering/TBClusterAnnotationView.m by Theodore Calmes

#import "ClusterAnnotationView.h"

static inline CGPoint TBRectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static inline CGRect TBCenterRectRounded(CGRect rect, CGPoint center)
{
    CGRect r = CGRectMake(roundf(center.x - rect.size.width/2.0),
                          roundf(center.y - rect.size.height/2.0),
                          roundf(rect.size.width),
                          roundf(rect.size.height));
    return r;
}

static CGFloat const TBScaleFactorAlpha = 0.3;
static CGFloat const TBScaleFactorBeta = 0.4;

static inline CGFloat TBScaledValueForValue(CGFloat value)
{
    return 1.0 / (1.0 + expf(-1 * TBScaleFactorAlpha * powf(value, TBScaleFactorBeta)));
}

@interface ClusterAnnotationView ()

@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation ClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupLabel];
        [self setCount:1];
    }
    return self;
}

- (void)setupLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.frame];
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont boldSystemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    CGPoint oldCenter = self.center;
    CGRect newBounds = CGRectMake(0, 0, 44 * TBScaledValueForValue(count), 44 * TBScaledValueForValue(count));
    self.frame = TBCenterRectRounded(newBounds, oldCenter);
    self.center = oldCenter;

    self.countLabel.text = [@(count) stringValue];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, true);
    
    UIColor *outerCircleStrokeColor = [UIColor colorWithWhite:0 alpha:0.25];
    UIColor *innerCircleStrokeColor = [UIColor whiteColor];
    UIColor *innerCircleFillColor = [UIColor colorWithRed:(255.0 / 255.0) green:(95 / 255.0) blue:(42 / 255.0) alpha:1.0];
    
    CGRect circleFrame = CGRectInset(rect, 4, 4);
    
    [outerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 5.0);
    CGContextStrokeEllipseInRect(context, circleFrame);
    
    [innerCircleStrokeColor setStroke];
    CGContextSetLineWidth(context, 4);
    CGContextStrokeEllipseInRect(context, circleFrame);
    
    [innerCircleFillColor setFill];
    CGContextFillEllipseInRect(context, circleFrame);
}

@end
