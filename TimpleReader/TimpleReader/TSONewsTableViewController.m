//
//  TSONewsTableViewController.m
//  TimpleWriter
//
//  Created by Timple Soft on 27/4/15.
//  Copyright (c) 2015 TimpleSoft. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "TSONewsTableViewController.h"
#import "Settings.h"
#import "TSONew.h"
#import "TSONewViewController.h"

@interface TSONewsTableViewController (){
    
    MSClient *client;

}@end

@implementation TSONewsTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    self.title = @"TimpleReader - News";
    
    self.model = [@[] mutableCopy];
    [self populateModelFromAzure];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(populateModelFromAzure)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.model.count;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Latest news";
    
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Averiguar la noticia
    TSONew *new = [self.model objectAtIndex:indexPath.row];
    
    // Creamos la celda
    static NSString *cellId = @"newCellId";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    // Configuramos la celda
    cell.imageView.image = new.image;
    cell.textLabel.text = new.title;
    cell.detailTextLabel.text = new.author;
    // para la segue
    cell.tag = indexPath.row;
    
    return cell;
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UITableViewCell *cell = sender;
    TSONew *new = [self.model objectAtIndex:cell.tag];
    
    TSONewViewController *newVC = segue.destinationViewController;
    newVC.azureId = new.azureId;
    
}

#pragma mark - Azure

-(void)populateModelFromAzure{
    
    [self.activity setHidden:NO];
    [self.activity startAnimating];
    
    client = [MSClient clientWithApplicationURL:[NSURL URLWithString:AZUREMOBILESERVICE_ENDPOINT]
                                 applicationKey:AZUREMOBILESERVICE_APPKEY];
    NSPredicate *predicate;
    
    predicate = [NSPredicate predicateWithFormat:@"visible==true AND published==true"];

    MSTable *table = [client tableWithName:@"news"];
    
    // Hacemos la consulta
    MSQuery *queryModel = [table queryWithPredicate:predicate];
    queryModel.selectFields = @[@"title", @"author", @"id", @"thumbnail"];
    [queryModel orderByDescending:@"__createdAt"];
    
    [queryModel readWithCompletion:^(MSQueryResult *result, NSError *error) {
        if (error) {
            NSLog(@"Error reading news: %@", error.userInfo);
        }else{
            NSLog(@"News succesfully readed.");
            
            NSArray *azureData = result.items;
            
            // primero borramos las noticias ya existentes
            [self.model removeAllObjects];
            
            for (id item in azureData) {
                TSONew *new = [[TSONew alloc] initWithTitle:item[@"title"]
                                                    azureId:item[@"id"]
                                                     author:item[@"author"]
                                                  thumbnail:item[@"thumbnail"]];
                [self.model addObject:new];
            }
            
            [self.tableView reloadData];
            [self.activity stopAnimating];
            [self.refreshControl endRefreshing];
            
        }
    }];
    
}

@end
