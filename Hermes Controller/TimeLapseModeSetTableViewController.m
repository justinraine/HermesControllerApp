//
//  TimeLapseModeSetTableViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeSetTableViewController.h"
#import "TimeLapseModeReviewTableViewController.h"
#import "PositionViewController.h"
#import "LabeledPickerView.h"

static const int kDurationSection = 0;
static const int kPositionSection = 1;
static const int kOptionsSection = 2;


@interface TimeLapseModeSetTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet LabeledPickerView *captureDurationPicker;
@property (strong, nonatomic) LabeledPickerView *test;
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UITableViewCell *testCell;
@property (weak, nonatomic) IBOutlet UIView *testCellView;
@property (weak, nonatomic) IBOutlet UIView *testCellView1;
@property (weak, nonatomic) IBOutlet UILabel *startPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dampingLabel;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;
@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@property NSInteger startPositionSteps;
@property NSInteger endPositionSteps;

@end


@implementation TimeLapseModeSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateComponents *durationComponents = [[NSDateComponents alloc] init];
    
    // Set Capture Duration value
    [durationComponents setHour:0]; // set hours
    [durationComponents setMinute:5]; // set minutes
    NSDate *defaultDuration = [[NSCalendar currentCalendar] dateFromComponents:durationComponents];
    [self.picker setDate:defaultDuration animated:TRUE];
    
//    self.test = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 162)];
//    self.test.hidden = NO;
//    self.test.delegate = self;
//    [self.test addLabel:@"min" forComponent:0 forLongestString:@"min"];
//    [self.test addLabel:@"sec" forComponent:1 forLongestString:@"sec"];
//    [self.testCellView1 addSubview:self.test];
//    
//    NSLog(@"picker height: %f", self.test.frame.size.height);
//    NSLog(@"picker width: %f", self.test.frame.size.width);
//    NSLog(@"cell height: %f", self.testCellView1.frame.size.height);
//    NSLog(@"cell height: %f", self.testCellView1.frame.size.width);
//
//    
//    // Set default durationPicker value
//    [self.captureDurationPicker selectRow:1 inComponent:0 animated:NO]; // 1 hour
//    [self.captureDurationPicker selectRow:0 inComponent:1 animated:NO]; // 0 minutes
//    [self.captureDurationPicker addLabel:@"hour" forComponent:0 forLongestString:@"hours"];
//    [self.captureDurationPicker addLabel:@"min" forComponent:1 forLongestString:@"min"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods

//- (IBAction)processUpdatedCaptureDuration:(id)sender {
//    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"HH:mm"];
//    
//    //self.durationLabel.text = [dateformatter stringFromDate:[self.durationPicker date]];
//    NSLog(@"UI Action: duration changed to %@", [dateformatter stringFromDate:[self.captureDurationPicker date]]);
//}

- (IBAction)updateDampingLabel:(id)sender {
    self.dampingLabel.text = [NSString stringWithFormat:@"%.f%%", self.dampingSlider.value*100];
}



#pragma mark - Labeled Picker View Methods

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // You can change the returning cell of static table view here...
//    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    
//    if (self.test == nil && indexPath.section == 0 && indexPath.row == 0) {
//            NSLog(@"cell height: %f", cell.contentView.frame.size.height);
//            NSLog(@"cell width: %f", cell.contentView.frame.size.width);
//        
//        self.test = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//        self.test.hidden = NO;
//        self.test.delegate = self;
//        [self.test addLabel:@"min" forComponent:0 forLongestString:@"min"];
//        [self.test addLabel:@"sec" forComponent:1 forLongestString:@"sec"];
//        [cell addSubview:self.test];
//    }
//    
//    return cell;
//}
//
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    return 2;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    if (component == 0) {
//        return 5; // 4 hour 59 minute max
//    } else {
//        return 60*201;
//    }
//}
//
//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle setAlignment:NSTextAlignmentRight];
//    [paragraphStyle setTailIndent:50];
//    
//    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)row % 60]
//                                           attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    return (self.captureDurationPicker.frame.size.width/3 - 1);
//}
//
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    if (component == 0) {
//        if (row == 1) {
//            [self.captureDurationPicker updateLabel:@"hour" forComponent:0];
//        } else {
//            [self.captureDurationPicker updateLabel:@"hours" forComponent:0];
//        }
//    } else {
//        if (row < 60*100 || row >= (5 * 101) ) {
//            row = row % 60;
//            row += 60*100;
//            [pickerView selectRow:row inComponent:component animated:NO];
//        }
//    }
//}



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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Temp dummy values
    self.startPositionSteps = 100;
    self.endPositionSteps = 2000;
    
    TimeLapseModeReviewTableViewController *reviewController = [segue destinationViewController];
    NSInteger selectedHour = [self.captureDurationPicker selectedRowInComponent:0];
    NSInteger selectedMinute = [self.captureDurationPicker selectedRowInComponent:1];
    reviewController.captureDurationSeconds = ((selectedHour * 60) + selectedMinute) * 60;
    reviewController.startPositionSteps = self.startPositionSteps;
    reviewController.endPositionSteps = self.endPositionSteps;
    reviewController.dampingPercent = self.dampingSlider.value*100;
}


@end
