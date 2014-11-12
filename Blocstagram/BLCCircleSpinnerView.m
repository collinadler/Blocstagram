//
//  BLCCircleSpinnerView.m
//  Blocstagram
//
//  Created by Collin Adler on 11/11/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCCircleSpinnerView.h"

@interface BLCCircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@end

@implementation BLCCircleSpinnerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 1;
        self.radius = 12;
        self.strokeColor = [UIColor purpleColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
}

//override the getter method for the circleLayer property, and create it the first time it's called (i.e. lazy instantiation
- (CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        //calcs a CGPoint representing the center of the arc
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        //this is a rectangle where our spinning circle will fit
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        
        //a BezierPath path is a path that can have both straight and curved line segments. the start and end angle are in radians
        //basically, smoothedPath represents a smooth circular path
        UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        //we create a new CAShapeLayer, made from a bezier path
        _circleLayer = [CAShapeLayer layer];
        //set its contentScale (just like setting a UIImage scale)
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale];
        //set the frame to the same rect as earlier
        _circleLayer.frame = rect;
        //make the center transparent (so we can see the heart)
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        //make the border to be the defined strokeColor (note that core animation properties take CGColorRefs instead of UIColor objects, so we convert them using the CGColor property
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        //specifies the shape of the ends of the line
        _circleLayer.lineCap = kCALineCapRound;
        //specifies the shape of the joints between parts of the line
        _circleLayer.lineJoin = kCALineJoinBevel;
        //give the layer the path from the UIBezierPath object
        _circleLayer.path = smoothedPath.CGPath;
        
        //a mask layer is an image or other layer that changes the opacity of it's layers content. this allows our circle to have a gradient on it
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        //set its size to be the same as the circleLayer
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        CFTimeInterval animationDuration = 1;
        //specify a linear animation (speed stays the same throughout the entire animation
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        //the fromValue and toValue specify that this animation will animate the layer's rotation from 0 to pi*2 (a full circular turn)
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        //it will be repeated an infinite number of times
        animation.repeatCount = INFINITY;
        //fillMode specifies what happens when the animation is complete (you can opt to hide layers once an animation has ended). kCAFillModeForwards leaves the layer on the screen
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        //add teh animation to the layer
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        //create two CABasicAnimations. The first animates the start of the stroke and the other animates the end. Both are added to CAAnimationGroup, which allows multiple animations to run concurrently
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animation.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
    }
    return _circleLayer;
}

//create a method to ensure that the circle animation is positioned properly. this code positions the circle layer in the center of the view
- (void)layoutAnimatedLayer {
    [self.layer addSublayer:self.circleLayer];
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

//When we add a subview to another view using [UIView -addSubview:], the subview can react to this in [UIView -willMoveToSuperview:]. Let's implement this method to ensure our positioning is accurate
- (void) willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        [self layoutAnimatedLayer];
    } else {
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
    }
}

//We'll also need to update the position of the layer if the frame changes
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.superview != nil) {
        [self layoutAnimatedLayer];
    }
}

//If we change the radius of the circle, that will affect positioning as well. We can update this by recreating the circle layer any time the radius changes
- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    [self layoutAnimatedLayer];
}

//we should also inform self.circleLayer if the other two properties change (stroke width or color)
- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
}

- (void)setStrokeThickness:(CGFloat)strokeThickness {
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
