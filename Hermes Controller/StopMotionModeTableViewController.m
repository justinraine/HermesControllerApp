//
//  StopMotionModeTableViewController.m
//  HermesControllerApp
//
//  Created by Woody Allen on 2015-03-17.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "StopMotionModeTableViewController.h"
#import "PositionViewController.h"
#import "LabeledPickerView.h"

static const int kCaptureDurationSection = 0;
static const int kPlaybackDurationSection = 1;
static const int kPositionSection = 2;
static const int kOptionsSection = 3;


@interface StopMotionModeTableViewController ()

@property (strong, nonatomic) LabeledPickerView *captureDurationPicker;
@property (strong, nonatomic) LabeledPickerView *playbackDurationPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *startPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dampingLabel;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;

@end


@implementation StopMotionModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set default Capture Duration and Playback Duration values
    //[self initializeDurationPickers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods

- (IBAction)updateDampingLabel:(id)sender {
    self.dampingLabel.text = [NSString stringWithFormat:@"%.f%%", self.dampingSlider.value*100];
}



#pragma mark - Picker View Delegate Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.captureDurationPicker && component == 0) {
        return 23; // 23 hour 59 minute capture duration max
    } else {
        return 60*201;
    }
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    
    // Hacky solution to numbers inside/outside selector not remaining aligned
    if (component == 0) {
        [paragraphStyle setTailIndent:self.captureDurationPicker.frame.size.width*0.1]; // * value determined experimentally
    } else {
        [paragraphStyle setTailIndent:self.captureDurationPicker.frame.size.width*0.14];
    }
    
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)row % 60]
                                           attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width/3 - 1;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.captureDurationPicker.frame.size.height/6;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.captureDurationPicker) {
        if (component == 0 && row == 1) {
            [self.captureDurationPicker updateLabel:@"hour" forComponent:0];
        } else if (component == 0 && row != 1) {
            [self.captureDurationPicker updateLabel:@"hours" forComponent:0];
        }
    }
    
    if ((pickerView == self.captureDurationPicker && component != 0) || pickerView == self.playbackDurationPicker) {
        if (row < 60*100 || row >= (60 * 101) ) {
            row = row % 60;
            row += 60*100;
            [pickerView selectRow:row inComponent:component animated:NO];
        }
    }
    
    // Set Next button hidden status
    if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"] &&
        ([self.captureDurationPicker selectedRowInComponent:0] != 0 || [self.captureDurationPicker selectedRowInComponent:1]%60 != 0) &&
        ([self.playbackDurationPicker selectedRowInComponent:0]%60 != 0 || [self.playbackDurationPicker selectedRowInComponent:1]%60 != 0)) {
        self.nextButton.enabled = YES;
    } else {
        self.nextButton.enabled = NO;
    }
}


#pragma mark - Table View Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // You can change the returning cell of static table view here...
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (self.captureDurationPicker == nil && indexPath.section == kCaptureDurationSection) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.captureDurationPicker = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cell.frame.size.height)];
        self.captureDurationPicker.delegate = self;
        [self.captureDurationPicker addLabel:@"hours" forComponent:0 forLongestString:@"hours"];
        [self.captureDurationPicker addLabel:@"min" forComponent:1 forLongestString:@"min"];
        [cell.contentView addSubview:self.captureDurationPicker];
    }
    
    if (self.playbackDurationPicker == nil && indexPath.section == kPlaybackDurationSection) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.playbackDurationPicker = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cell.frame.size.height)];
        self.playbackDurationPicker.delegate = self;
        [self.playbackDurationPicker addLabel:@"min" forComponent:0 forLongestString:@"min"];
        [self.playbackDurationPicker addLabel:@"sec" forComponent:1 forLongestString:@"sec"];
        [cell.contentView addSubview:self.playbackDurationPicker];
    }
    
    return cell;
}


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
    
    if (indexPath.section == kCaptureDurationSection || indexPath.section == kPlaybackDurationSection) {
        height = 162.0f;
    } else if (indexPath.section == kOptionsSection) {
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
            //positionViewController.customMessage = @"Move the camera to the desired start position and press Set.";
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.startPositionStatusLabel.text = @"Set";
                if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"]) {
                    self.nextButton.enabled = YES;
                }
            }];
        } else if (indexPath.row == 1) { // Set end position row
            //positionViewController.customMessage = @"Move the camera to the desired end position and press Set.";
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
