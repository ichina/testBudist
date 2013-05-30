//
//  AnnotationsListController.m
//  iSeller
//
//  Created by Paul Semionov on 08.04.13.
//  Copyright (c) 2013 CloudTeam. All rights reserved.
//

#import "AnnotationsListController.h"

#import "AdvertisementController.h"

#import "AnnotationCell.h"

#import "Annotation.h"

@interface AnnotationsListController ()

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end

@implementation AnnotationsListController

@synthesize tableView = _tableView;

@synthesize annotations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:BG_IMAGE]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return annotations.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AnnotationCell *cell = (AnnotationCell *)[tableView dequeueReusableCellWithIdentifier:@"AnnotationsCell"];
    
    if(cell == nil) {
        
        cell = [[AnnotationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AnnotationsCell"];
        
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setProsition:tableView withIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell setAdvertisementInfo:[(Annotation *)[annotations objectAtIndex:indexPath.row] ad]];
                    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:kSegueFromAnnotationListToAd]) {
        
        ((AdvertisementController*)segue.destinationViewController).ad = [(Annotation *)[annotations objectAtIndex:[self.tableView indexPathForCell:sender].row] ad];
        
    }
        
}

@end
