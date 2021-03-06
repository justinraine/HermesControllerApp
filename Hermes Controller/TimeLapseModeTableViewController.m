//
//  TimeLapseModeTableViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeTableViewController.h"
#import "PositionViewController.h"
#import "InProgressViewController.h"
#import "LabeledPickerView.h"
#import "VMHHermesControllerManager.h"
#import "VMHPacket.h"

static const int kDurationSection = 0;
static const int kPositionSection = 1;
static const int kOptionsSection = 2;


@interface TimeLapseModeTableViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *startButton;
@property (nonatomic, weak) IBOutlet UILabel *startPositionStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *endPositionStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *dampingLabel;
@property (nonatomic, weak) IBOutlet UISlider *dampingSlider;
@property (nonatomic, weak) IBOutlet UISwitch *repeatSwitch;
@property (nonatomic, strong) LabeledPickerView *captureDurationPicker;
@property (nonatomic, strong) NSNumber *startPositionSteps;
@property (nonatomic, strong) NSNumber *endPositionSteps;

@end


@implementation TimeLapseModeTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[VMHHermesControllerManager sharedInstance] addObserver:self
                                                  forKeyPath:@"status"
                                                     options:0
                                                     context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods

- (IBAction)startButton:(id)sender {
    NSLog(@"Start button pressed -- Send command to Arduino to begin time lapse");
    
    // Send command to Hermes Controller
    NSInteger selectedHour = [self.captureDurationPicker selectedRowInComponent:0];
    NSInteger selectedMinute = [self.captureDurationPicker selectedRowInComponent:1] % 60;
    NSInteger durationSeconds = ((selectedHour * 60) + selectedMinute) * 60;
    [[VMHHermesControllerManager sharedInstance] beginTimeLapseWithDurationSeconds:durationSeconds
                                                                startPositionSteps:[self.startPositionSteps integerValue]
                                                                  endPositionSteps:[self.endPositionSteps integerValue]
                                                                    dampingPercent:(int)roundf(self.dampingSlider.value*100)
                                                                              loop:self.repeatSwitch.on];
    
    // Segue to InProgress view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    InProgressViewController *inProgressViewController = [storyboard instantiateViewControllerWithIdentifier:@"InProgressView"];
    inProgressViewController.timeLapseMode = YES;
    [inProgressViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [rootView presentViewController:inProgressViewController animated:YES completion:nil];
}


- (IBAction)dampingSliderDidChange:(id)sender {
    self.dampingLabel.text = [NSString stringWithFormat:@"%.f%%", roundf(self.dampingSlider.value*100)];
}



#pragma mark - Private Methods

- (void)updateStartButtonEnabled {
    if (self.startPositionSteps && self.endPositionSteps &&
        ([self.captureDurationPicker selectedRowInComponent:0] != 0 || [self.captureDurationPicker selectedRowInComponent:1]%60 != 0)) {
        self.startButton.enabled = YES;
    } else {
        self.startButton.enabled = NO;
    }
}



#pragma mark - Notification Handler

- (void)positionDidUpdate:(NSNotification *)notification {
    NSNumber *updatedPositionSteps = [notification.userInfo valueForKey:kPositionStepsKey];
    BOOL setStartPosition = [[notification.userInfo valueForKey:kSetStartPositionKey] boolValue];
    
    if (setStartPosition) {
        self.startPositionSteps = updatedPositionSteps;
        NSLog(@"Updated Time Lapse Mode Start Position: %d", (short)[self.startPositionSteps intValue]);
    } else {
        self.endPositionSteps = updatedPositionSteps;
        NSLog(@"Updated Time Lapse Mode End Position: %d", (short)[self.endPositionSteps intValue]);
    }
    
    // Unregister for notificiations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPositionUpdateNotification object:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"] && [VMHHermesControllerManager sharedInstance].status == kDisconnected) {
        NSLog(@"Bluetooth disconnection detected. Resetting stored Time Lapse positions");
        self.startPositionSteps = nil;
        self.endPositionSteps = nil;
        self.startPositionStatusLabel.text = @"Not Set";
        self.endPositionStatusLabel.text = @"Not Set";
        [self updateStartButtonEnabled];
    }
}



#pragma mark - TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Create captureDurationPicker in row 0 if nil
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
        PositionViewController *positionViewController = [storyboard instantiateViewControllerWithIdentifier:@"PositionView"];
        [positionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        
        // register as observer for update notification, will unregister after update received
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(positionDidUpdate:)
                                                     name:kPositionUpdateNotification
                                                   object:positionViewController];
        
        if (indexPath.row == 0) { // Prepare for segue to set start postition view
            positionViewController.setStartPosition = YES;
            
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.startPositionStatusLabel.text = @"Set";
                [self updateStartButtonEnabled];
            }];
        } else if (indexPath.row == 1) { // Set end position row
            positionViewController.setStartPosition = NO;
            
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.endPositionStatusLabel.text = @"Set";
                [self updateStartButtonEnabled];
            }];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - PickerView DataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 5; // 4 hour 59 minute max
    } else {
        return 60*201;
    }
}



#pragma mark - PickerView Delegate Methods

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width/3 - 1;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.captureDurationPicker.frame.size.height/6;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        // Update hours label
        if (row == 1) {
            [self.captureDurationPicker updateLabel:@"hour" forComponent:0];
        } else {
            [self.captureDurationPicker updateLabel:@"hours" forComponent:0];
        }
    } else {
        // Recenter minute slider at center
        if (row < 60*100 || row >= (60 * 101) ) {
            int selectedRow = row % 60;
            row = 60*100 + selectedRow;
            [pickerView selectRow:row inComponent:component animated:NO];
        }
    }
    
    [self updateStartButtonEnabled];
}


- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    
    // Hacky solution to numbers inside/outside selector not remaining aligned
    if (component == 0) {
        [paragraphStyle setTailIndent:self.captureDurationPicker.frame.size.width*0.1]; // * Scaling factor determined experimentally
    } else {
        [paragraphStyle setTailIndent:self.captureDurationPicker.frame.size.width*0.14];
    }
    
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)row % 60]
                                           attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
}

@end
