//
//  TimeLapseModeTableViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeTableViewController.h"
#import "PositionViewController.h"
#import "LabeledPickerView.h"
#import "VMHPacket.h"
#import "MBProgressHUD.h"

static const int kDurationSection = 0;
static const int kPositionSection = 1;
static const int kOptionsSection = 2;


@interface TimeLapseModeTableViewController ()

@property (strong, nonatomic) LabeledPickerView *captureDurationPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property (weak, nonatomic) IBOutlet UILabel *startPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPositionStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *dampingLabel;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;
@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@property NSInteger startPositionSteps;
@property NSInteger endPositionSteps;
@property MBProgressHUD *HUD;

@end


@implementation TimeLapseModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods

- (IBAction)startButton:(id)sender {
    VMHPacket *packet = [self createPacket];
    [packet printPacket];
    
    [self displayStatus];
}

- (VMHPacket *)createPacket {
    NSInteger selectedHour = [self.captureDurationPicker selectedRowInComponent:0];
    NSInteger selectedMinute = [self.captureDurationPicker selectedRowInComponent:1] % 60;
    NSInteger durationSeconds = ((selectedHour * 60) + selectedMinute) * 60;
    
    VMHPacket *packet = [[VMHPacket alloc] init];
    [packet configureTimeLapseModePacketWithDurationSeconds:durationSeconds
                                         startPositionSteps:self.startPositionSteps
                                           endPositionSteps:self.endPositionSteps
                                             dampingPercent:(int)self.dampingSlider.value*100
                                                     repeat:self.repeatSwitch.on];
    return packet;
}

- (void)displayStatus {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.HUD];
    
    // Set determinate mode
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    self.HUD.delegate = self;
    self.HUD.labelText = @"Capturing...";
    
    // myProgressTask uses the HUD instance to update progress
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 2.0f) {
        progress += 0.01f;
        self.HUD.progress = progress;
        usleep(50000);
    }
}


- (IBAction)dampingSliderDidChange:(id)sender {
    self.dampingLabel.text = [NSString stringWithFormat:@"%.f%%", roundf(self.dampingSlider.value*100)];
}



#pragma mark - Picker View Delegate Methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 5; // 4 hour 59 minute max
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
    if (component == 0) {
        if (row == 1) {
            [self.captureDurationPicker updateLabel:@"hour" forComponent:0];
        } else {
            [self.captureDurationPicker updateLabel:@"hours" forComponent:0];
        }
    } else {
        if (row < 60*100 || row >= (60 * 101) ) {
            row = row % 60;
            row += 60*100;
            [pickerView selectRow:row inComponent:component animated:NO];
        }
    }
    
    // Set Next button hidden status
    if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"] &&
        ([self.captureDurationPicker selectedRowInComponent:0] != 0 || [self.captureDurationPicker selectedRowInComponent:1]%60 != 0)) {
        self.startButton.enabled = YES;
    } else {
        self.startButton.enabled = NO;
    }
}



#pragma mark - Table View Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // You can change the returning cell of static table view here...
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (self.captureDurationPicker == nil && indexPath.section == 0 && indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.captureDurationPicker = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, cell.frame.size.height)];
        self.captureDurationPicker.delegate = self;
        [self.captureDurationPicker addLabel:@"hours" forComponent:0 forLongestString:@"hours"];
        [self.captureDurationPicker addLabel:@"min" forComponent:1 forLongestString:@"min"];
        [cell.contentView addSubview:self.captureDurationPicker];
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
        
        // register as observer for update notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(positionDidUpdate:)
                                                     name:kPositionUpdateNotification
                                                   object:positionViewController];
        
        if (indexPath.row == 0) { // Prepare for segue to set start postition view
            positionViewController.setStartPosition = YES;
            
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{ self.startPositionStatusLabel.text = @"Set";
                if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"] &&
                    ([self.captureDurationPicker selectedRowInComponent:0] != 0 || [self.captureDurationPicker selectedRowInComponent:1]%60 != 0)) {
                    self.startButton.enabled = YES;
                }
            }];
        } else if (indexPath.row == 1) { // Set end position row
            positionViewController.setStartPosition = NO;
            
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.endPositionStatusLabel.text = @"Set";
                if ([self.startPositionStatusLabel.text isEqual: @"Set"] && [self.endPositionStatusLabel.text isEqual: @"Set"] &&
                    ([self.captureDurationPicker selectedRowInComponent:0] != 0 || [self.captureDurationPicker selectedRowInComponent:1]%60 != 0)) {
                    self.startButton.enabled = YES;
                }
            }];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)positionDidUpdate:(NSNotification *)notification {
    NSNumber *updatedPositionSteps = [notification.userInfo valueForKey:kPositionStepsKey];
    BOOL setStartPosition = [[notification.userInfo valueForKey:kSetStartPositionKey] boolValue];
    
    if (setStartPosition) {
        self.startPositionSteps = [updatedPositionSteps integerValue];
        NSLog(@"Updated Time Lapse Mode Start Position: %ld", self.startPositionSteps);
    } else {
        self.endPositionSteps = [updatedPositionSteps integerValue];
        NSLog(@"Updated Time Lapse Mode End Position: %ld", self.endPositionSteps);
    }
    
    // unregister for notificiations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPositionUpdateNotification object:nil];
}


@end
