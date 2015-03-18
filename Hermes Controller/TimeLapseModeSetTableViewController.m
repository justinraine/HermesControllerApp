//
//  TimeLapseModeSetTableViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeSetTableViewController.h"
#import "PositionViewController.h"

static const int kDurationSection = 0;
static const int kPositionSection = 1;
static const int kOptionsSection = 2;


@interface TimeLapseModeSetTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *captureDurationPicker;
@property (weak, nonatomic) IBOutlet UILabel *startPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dampingLabel;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;
@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;

@end


@implementation TimeLapseModeSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set default durationPicker value
    [self initializeDurationPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeDurationPicker {
    NSDateComponents *durationComponents = [[NSDateComponents alloc] init];
    [durationComponents setHour:0]; // set hours
    [durationComponents setMinute:5]; // set minutes
    NSDate *defaultDuration = [[NSCalendar currentCalendar] dateFromComponents:durationComponents];
    [self.captureDurationPicker setDate:defaultDuration animated:TRUE];
}



#pragma mark - IBAction Methods

- (IBAction)processUpdatedCaptureDuration:(id)sender {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    
    //self.durationLabel.text = [dateformatter stringFromDate:[self.durationPicker date]];
    NSLog(@"UI Action: duration changed to %@", [dateformatter stringFromDate:[self.captureDurationPicker date]]);
}

- (IBAction)updateDampingLabel:(id)sender {
    self.dampingLabel.text = [NSString stringWithFormat:@"%.f%%", self.dampingSlider.value*100];
}



#pragma mark - Table View Delegate Methods

// Configure tableView separator lines to display across whole view
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    
    if (indexPath.section == kDurationSection) {
        height = 162.0f;
    } else if (indexPath.section == kOptionsSection && indexPath.row == 0) {
        height = 83.0f;
    }else {
        height = 44.0f;
    }
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kPositionSection) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PositionViewController *positionViewController = [storyboard instantiateViewControllerWithIdentifier:@"positionViewController"];
        [positionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        
        if (indexPath.row == 0) { // Set start position row
            positionViewController.customMessage = @"Move the camera to the desired start position and press Set.";
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.startPositionStatusLabel.text = @"Set";
                if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"]) {
                    self.nextButton.enabled = YES;
                }
            }];
        } else if (indexPath.row == 1) { // Set end position row
            positionViewController.customMessage = @"Move the camera to the desired end position and press Set.";
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.endPositionStatusLabel.text = @"Set";
                if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"]) {
                    self.nextButton.enabled = YES;
                }
            }];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
