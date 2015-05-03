//
//  TSONewViewController.h
//  TimpleReader
//
//  Created by Timple Soft on 29/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

@import UIKit;
@class TSONew;
#import "GAITrackedViewController.h"

@interface TSONewViewController : GAITrackedViewController

@property (strong, nonatomic) NSString *azureId;
@property (strong, nonatomic) TSONew *model;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;


- (IBAction)rateNew:(id)sender;
- (IBAction)rateChanged:(id)sender;

-(id) initWithNewId:(NSString *) azureId;


@end
