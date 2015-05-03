//
//  TSONewsTableViewController.h
//  TimpleWriter
//
//  Created by Timple Soft on 27/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

@import UIKit;
@class TSONew;

@interface TSONewsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *model;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
