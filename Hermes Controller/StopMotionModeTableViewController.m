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
#import "VMHHermesControllerManager.h"
#import "VMHPacket.h"

static const int kCaptureDurationSection = 0;
static const int kPlaybackDurationSection = 1;
static const int kPositionSection = 2;
static const int kOptionsSection = 3;


@interface StopMotionModeTableViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *startButton;
@property (nonatomic, weak) IBOutlet UILabel *startPositionStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *endPositionStatusLabel;
@property (nonatomic, weak) IBOutlet UILabel *dampingLabel;
@property (nonatomic, weak) IBOutlet UISlider *dampingSlider;
@property (nonatomic, strong) LabeledPickerView *captureDurationPicker;
@property (nonatomic, strong) LabeledPickerView *playbackDurationPicker;
@property (nonatomic, strong) NSNumber *startPositionSteps;
@property (nonatomic, strong) NSNumber *endPositionSteps;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end


@implementation StopMotionModeTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBAction Methods

- (IBAction)startButton:(id)sender {
    NSInteger captureHours = [self.captureDurationPicker selectedRowInComponent:0];
    NSInteger captureMinutes = [self.captureDurationPicker selectedRowInComponent:1] % 60;
    NSInteger captureTotalSeconds = ((captureHours * 60) + captureMinutes) * 60;
    NSInteger playbackTotalSeconds = [self.playbackDurationPicker selectedRowInComponent:0] % 60;
    
    [[VMHHermesControllerManager sharedInstance] beginStopMotionWithInterval:captureTotalSeconds/playbackTotalSeconds
                                                               startPosition:[self.startPositionSteps integerValue]
                                                                 endPosition:[self.endPositionSteps integerValue]
                                                                     damping:(int)self.dampingSlider.value*100];
}


- (IBAction)updateDampingLabel:(id)sender {
    self.dampingLabel.text = [NSString stringWithFormat:@"%.f%%", self.dampingSlider.value*100];
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
        NSLog(@"Updated Stop Motion Mode Start Position: %@", self.startPositionSteps);
    } else {
        self.endPositionSteps = updatedPositionSteps;
        NSLog(@"Updated Stop Motion Mode End Position: %@", self.endPositionSteps);
    }
    
    // Unregister for notificiations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPositionUpdateNotification object:nil];
}



#pragma mark - TableView Delegate Methods

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
        [self.playbackDurationPicker addLabel:@"sec" forComponent:0 forLongestString:@"sec"];
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
        // Prepare the positionViewController
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PositionViewController *positionViewController = [storyboard instantiateViewControllerWithIdentifier:@"PositionView"];
        [positionViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        
        // register as observer for update notification, will unregister after update received
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(positionDidUpdate:)
                                                     name:kPositionUpdateNotification
                                                   object:positionViewController];
        
        // Segue to positionViewController to set start/end position
        if (indexPath.row == 0) {
            positionViewController.setStartPosition = YES;
            
            [self.navigationController presentViewController:positionViewController animated:YES completion:^{
                self.startPositionStatusLabel.text = @"Set";
                [self updateStartButtonEnabled];
            }];
        } else if (indexPath.row == 1) {
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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.captureDurationPicker) {
        return 2;
    } else {
        return 1;
    }
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.captureDurationPicker && component == 0) {
        return 48; // 47 hour 59 minute capture duration max
    } else {
        return 60*201;
    }
}



#pragma mark - PickerView Delegate Methods

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


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width/3 - 1;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.captureDurationPicker.frame.size.height/6;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
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
    
    [self updateStartButtonEnabled];
}

@end
