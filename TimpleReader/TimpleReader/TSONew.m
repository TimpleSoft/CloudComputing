//
//  TSONew.m
//  TimpleWriter
//
//  Created by Timple Soft on 27/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

#import "TSONew.h"
@import CoreLocation;

@interface TSONew () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end



@implementation TSONew

-(BOOL) hasLocation{
    return (nil != self.location);
}


-(id) initWithTitle:(NSString *) title
               text:(NSString *) text{
    
    if (self = [super init]) {
        _title = title;
        _text = text;
        _published = NO;
        
        // solo guardamos la localizacion de noticias nuevas
        [self setupLocation];
    }
    
    return self;
    
}

// incializador para celdas
-(id) initWithTitle:(NSString *) title
            azureId:(NSString *) azureId
             author:(NSString *) author
          thumbnail:(NSString *) thumbnail{
    
    if (self = [super init]) {
        _azureId = azureId;
        _title = title;
        _author = author;
        if ([thumbnail class] == [NSNull class]) {
            _image = [UIImage imageNamed:@"no_photo_cell.png"];
        }
    }
    
    return self;
    
}


-(id) initWithDictionary:(NSDictionary *) dict{
    
    if (self = [super init]) {
        _azureId = dict[@"id"];
        _title = dict[@"title"];
        _author = dict[@"author"];
        _text = dict[@"text"];
        _published = [dict[@"published"] boolValue];
        if ([dict[@"rating"] class] != [NSNull class]) {
            _rating = [dict[@"rating"] integerValue];
        }
        if ([dict[@"image"] class] == [NSNull class]) {
            _image = [UIImage imageNamed:@"nophoto.png"];
        }
        if ([dict[@"latitude"] class] != [NSNull class] &&
            [dict[@"longitude"] class] != [NSNull class]){
            _location = [[CLLocation alloc] initWithLatitude:[dict[@"latitude"] floatValue]
                                                   longitude:[dict[@"longitude"] floatValue]];
        }
    }
    
    return self;
    
}



-(NSDictionary *) newToDictionary{
    
    if (self.azureId) {
        // pasamos el id
        return @{@"id": self.azureId,
                 @"title": self.title,
                 @"text": self.text,
                 @"author": self.author,
                 @"published": [NSNumber numberWithBool:self.published]};
    }else{
        if (!self.location) {
            return @{@"title": self.title,
                     @"text": self.text,
                     @"author": self.author,
                     @"published": [NSNumber numberWithBool:self.published]};
        }
        // pasamos la localizacion
        return @{@"title": self.title,
                 @"text": self.text,
                 @"author": self.author,
                 @"latitude": [NSNumber numberWithFloat:self.location.coordinate.latitude],
                 @"longitude": [NSNumber numberWithFloat:self.location.coordinate.longitude],
                 @"published": [NSNumber numberWithBool:self.published]};
    }
    
}


-(NSDictionary *) newForRating{
    
    return @{@"id": self.azureId,
             @"rating": [NSNumber numberWithInteger:self.rating]};
    
}


# pragma mark - Location
-(void) setupLocation{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (((status == kCLAuthorizationStatusAuthorizedAlways) ||
         (status == kCLAuthorizationStatusNotDetermined) ||
         (status == kCLAuthorizationStatusAuthorizedWhenInUse)) &&
        [CLLocationManager locationServicesEnabled]) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
        
        // solo me interesan datos recientes
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self zapLocationManager];
        });
    }
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    // lo paramos para ahorrar batería
    [self zapLocationManager];
    
    if (!self.location) {

        // La guardamos
        self.location = [locations lastObject];
        
    }else{
        
        NSLog(@"No deberíamos llegar aquí nunca");
        
    }
    
    
}

-(void) zapLocationManager{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}


@end
