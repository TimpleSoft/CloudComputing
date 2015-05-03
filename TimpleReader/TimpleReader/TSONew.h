//
//  TSONew.h
//  TimpleWriter
//
//  Created by Timple Soft on 27/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import UIKit;


@interface TSONew : NSObject

@property (nonatomic, readonly) BOOL hasLocation;

@property (strong, nonatomic) NSString *azureId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *author;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSInteger rating;
@property (nonatomic) BOOL published;
@property (nonatomic, strong) NSDate *creationDate;
@property (strong, nonatomic) UIImage *image;


-(id) initWithTitle:(NSString *) title
               text:(NSString *) text;

// incializador para celdas
-(id) initWithTitle:(NSString *) title
            azureId:(NSString *) azureId
             author:(NSString *) author
          thumbnail:(NSString *) thumbnail;

-(id) initWithDictionary:(NSDictionary *) dict;

-(NSDictionary *) newToDictionary;
-(NSDictionary *) newForRating;

@end