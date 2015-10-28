//
//  LWPRecorderViewController.h
//  Lewp
//
//  Created by Ethan Geller on 2/18/14.
//  Copyright (c) 2014 Ethan Geller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWPScheduler.h"

@interface LWPRecorderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *panicButton;


@property (weak, nonatomic) IBOutlet UILabel *beatLabel;
@property (weak, nonatomic) IBOutlet UILabel *stackLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *instrumentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *circle;

@property NSMutableArray* circles;
@property int lastBeat, lastLewp, lastStack;
@property float animateTime;
@property CGRect circleStartingBounds, circleEndingBounds, circleActiveBounds;
@property UIImage* circleImage;

@property NSString* segueString;

- (void)redraw:(NSTimer*)theTimer;

-(void)animateQuoteWithImage: (NSString*)imageName;

-(void)SwitchLewpCircle;
- (void)rotationAnimation;
@end
