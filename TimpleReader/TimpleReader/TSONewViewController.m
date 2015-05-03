//
//  TSONewViewController.m
//  TimpleReader
//
//  Created by Timple Soft on 29/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "TSONewViewController.h"
#import "TSONew.h"
#import "Settings.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface TSONewViewController (){
    MSClient *client;
}

@end

@implementation TSONewViewController


-(id) initWithNewId:(NSString *) Id{
    
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        _azureId = Id;
        
    }
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TimpleReader";
    
    // Creamos y configuramos la conexión a azure
    [self warmupMSClient];
    
    // descargamos la noticia completa
    [self getNewFromAzure];
    self.screenName = [@"Visited new with ID-" stringByAppendingString:self.azureId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Utils
-(void) syncViewWithModel{
    
    self.titleLabel.text = self.model.title;
    self.authorLabel.text = self.model.author;
    self.textView.text = self.model.text;
    if (self.model.image) {
        self.image.image = self.model.image;
    }
    if (self.model.location) {
        [self.locationLabel setHidden:NO];
        self.locationLabel.text = [NSString stringWithFormat:@"Location: %f, %f",
                                   self.model.location.coordinate.latitude,
                                   self.model.location.coordinate.longitude];
    }
    
    
}


#pragma mark - Azure
-(void) warmupMSClient{
    
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    
}



-(void) getNewFromAzure{
    
    MSTable *table = [client tableWithName:@"news"];
    [table readWithId:self.azureId completion:^(NSDictionary *item, NSError *error) {
        if(error) {
            NSLog(@"Error reading new -> %@", error);
        } else {
            self.model = [[TSONew alloc] initWithDictionary:item];
            [self syncViewWithModel];
        }
    }];
    
}

#pragma mark - Actions

- (IBAction)rateNew:(id)sender {
    
    
    [self.activity setHidden:NO];
    [self.activity startAnimating];
    
    MSTable *news = [client tableWithName:@"news"];
    
    self.model.rating = [self.rateLabel.text integerValue];
    NSDictionary *newDict = [self.model newForRating];
        
    [news update:newDict completion:^(NSDictionary *item, NSError *error) {
        
        if (error) {
            NSLog(@"Error rating the new %@", error.userInfo[@"NSLocalizedDescription"]);
            
            UIAlertView *errorUpdatingAlert = [[UIAlertView alloc] initWithTitle:@"Error rating new"
                                                                         message:error.userInfo[@"NSLocalizedDescription"]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"Accept"
                                                               otherButtonTitles:nil];
            [errorUpdatingAlert show];
            
            [self.activity stopAnimating];
            
        }else{
            NSLog(@"New successfully rated -> %@", item);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *newUpdatedAlert = [[UIAlertView alloc] initWithTitle:@"New rated"
                                                                          message:@"New successfully rated"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"Accept"
                                                                otherButtonTitles:nil];
                [newUpdatedAlert show];
                [self.activity stopAnimating];
                
                // Enviamos evento a analitycs
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"NewRated"
                                                                      action:@"Rating"
                                                                       label:self.model.title
                                                                       value:nil] build]];
                
            });
        }
        
    }];
    
}

- (IBAction)rateChanged:(UIStepper *)sender {
    
    NSInteger value = [sender value];
    self.rateLabel.text = [NSString stringWithFormat:@"%ld", (long)value];
    
}


@end
