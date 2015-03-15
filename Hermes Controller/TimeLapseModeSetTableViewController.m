//
//  TimeLapseModeSetTableViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeSetTableViewController.h"

int const kDurationSection = 0;
int const kPositionSection = 1;
int const kDampingSection = 2;
int const kRepeatSection = 3;

int const kDurationPickerCellRow = 1;
int const kStartPositionSetCellRow = 1;
int const kEndPositionSetCellRow = 3;
int const kDampingSliderCellRow = 1;

@interface TimeLapseModeSetTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *durationPickerCell;
@property (weak, nonatomic) IBOutlet UIPickerView *durationPicker;

@property (weak, nonatomic) IBOutlet UITableViewCell *startPositionSetCell;
@property (weak, nonatomic) IBOutlet UIButton *startPositionSetButton;
@property (weak, nonatomic) IBOutlet UIButton *startPositionLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *startPositionRightButton;

@property (weak, nonatomic) IBOutlet UITableViewCell *endPositionSetCell;
@property (weak, nonatomic) IBOutlet UIButton *endPositionSetButton;
@property (weak, nonatomic) IBOutlet UIButton *endPositionLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *endPositionRightButton;

@property (weak, nonatomic) IBOutlet UILabel *dampingLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *dampingSliderCell;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;

@property BOOL durationPickerCellIsShowing;
@property BOOL startPositionSetCellIsShowing;
@property BOOL endPositionSetCellIsShowing;
@property BOOL dampingSliderCellIsShowing;

@end

@implementation TimeLapseModeSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeTable];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeTable {
    self.startPositionSetButton.hidden = YES;
    self.startPositionLeftButton.hidden = YES;
    self.startPositionRightButton.hidden = YES;
    self.endPositionSetButton.hidden = YES;
    self.endPositionLeftButton.hidden = YES;
    self.endPositionRightButton.hidden = YES;
    self.dampingSlider.hidden = YES;
    
    self.durationPickerCellIsShowing = NO;
    self.startPositionSetCellIsShowing = NO;
    self.endPositionSetCellIsShowing = NO;
    self.dampingSliderCellIsShowing = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table view data source

// Configure tableView separator lines to display across whole view
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

// Hide interactive cells by default
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    
    if (indexPath.section == kDurationSection && indexPath.row == kDurationPickerCellRow) {
        if (self.durationPickerCellIsShowing) {
            height = 162.0f;
        } else {
            height = 0.0f;
        }
    } else if (indexPath.section == kPositionSection && indexPath.row == kStartPositionSetCellRow) {
        if (self.startPositionSetCellIsShowing) {
            height = 127.0;
        } else {
            height = 0.0f;
        }
    } else if (indexPath.section == kPositionSection && indexPath.row == kEndPositionSetCellRow) {
        if (self.endPositionSetCellIsShowing) {
            height = 127.0;
        } else {
            height = 0.0f;
        }
    } else if (indexPath.section == kDampingSection && indexPath.row == kDampingSliderCellRow) {
        if (self.dampingSliderCellIsShowing) {
            height = 44.0f;
        } else {
            height = 0.0f;
        }
    } else {
        height = 44.0f;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    
    if (indexPath.section == kDurationSection && indexPath.row == kDurationPickerCellRow) {
        if (self.durationPickerCellIsShowing) {
            height = 162.0f;
        } else {
            height = 0.0f;
        }
    } else if (indexPath.section == kPositionSection && indexPath.row == kStartPositionSetCellRow) {
        if (self.startPositionSetCellIsShowing) {
            height = 127.0;
        } else {
            height = 0.0f;
        }
    } else if (indexPath.section == kPositionSection && indexPath.row == kEndPositionSetCellRow) {
        if (self.endPositionSetCellIsShowing) {
            height = 127.0;
        } else {
            height = 0.0f;
        }
    } else if (indexPath.section == kDampingSection && indexPath.row == kDampingSliderCellRow) {
        if (self.dampingSliderCellIsShowing) {
            height = 44.0f;
        } else {
            height = 0.0f;
        }
    } else {
        height = 44.0f;
    }
    
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == kDurationSection && indexPath.row == kDurationPickerCellRow-1) {
        if (self.durationPickerCellIsShowing) {
            [self hideDurationPickerCell];
        } else {
            if (self.startPositionSetCellIsShowing) {
                [self hideStartPositionCell];
            } else if (self.endPositionSetCellIsShowing) {
                [self hideEndPositionCell];
            } else if (self.dampingSliderCellIsShowing) {
                [self hideDampingSliderCell];
            }
            
            [self showDurationPickerCell];
        }
    } else if (indexPath.section == kPositionSection && indexPath.row == kStartPositionSetCellRow-1) {
        if (self.startPositionSetCellIsShowing) {
            [self hideStartPositionCell];
        } else {
            if (self.durationPickerCellIsShowing) {
                [self hideDurationPickerCell];
            } else if (self.endPositionSetCellIsShowing) {
                [self hideEndPositionCell];
            } else if (self.dampingSliderCellIsShowing) {
                [self hideDampingSliderCell];
            }
            
            [self showStartPositionCell];
        }
    } else if (indexPath.section == kPositionSection && indexPath.row == kEndPositionSetCellRow-1) {
        if (self.endPositionSetCellIsShowing) {
            [self hideEndPositionCell];
        } else {
            if (self.durationPickerCellIsShowing) {
                [self hideDurationPickerCell];
            } else if (self.startPositionSetCellIsShowing) {
                [self hideStartPositionCell];
            } else if (self.dampingSliderCellIsShowing) {
                [self hideDampingSliderCell];
            }
            
            [self showEndPositionCell];
        }
    } else if (indexPath.section == kDampingSection && indexPath.row == kDampingSliderCellRow-1) {
        if (self.dampingSliderCellIsShowing) {
            [self hideDampingSliderCell];
        } else {
            if (self.durationPickerCellIsShowing) {
                [self hideDurationPickerCell];
            } else if (self.startPositionSetCellIsShowing) {
                [self hideStartPositionCell];
            } else if (self.endPositionSetCellIsShowing) {
                [self hideEndPositionCell];
            }
            
            [self showDampingSliderCell];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Cell Show/Hide Methods

- (void)hideDurationPickerCell {
    self.durationPickerCellIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.durationPicker.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.durationPicker.hidden = YES;
    }];
}


- (void)showDurationPickerCell {
    self.durationPickerCellIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.durationPicker.hidden = NO;
    self.durationPicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.durationPicker.alpha = 1.0f;
    }];
}


- (void)hideStartPositionCell {
    self.startPositionSetCellIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.startPositionSetButton.alpha = 0.0f;
        self.startPositionLeftButton.alpha = 0.0f;
        self.startPositionRightButton.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.startPositionSetButton.hidden = YES;
        self.startPositionLeftButton.hidden = YES;
        self.startPositionRightButton.hidden = YES;
    }];
}


- (void)showStartPositionCell {
    self.startPositionSetCellIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.startPositionSetButton.hidden = NO;
    self.startPositionLeftButton.hidden = NO;
    self.startPositionRightButton.hidden = NO;
    
    self.startPositionSetButton.alpha = 0.0f;
    self.startPositionLeftButton.alpha = 0.0f;
    self.startPositionRightButton.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.startPositionSetButton.alpha = 1.0f;
        self.startPositionLeftButton.alpha = 1.0f;
        self.startPositionRightButton.alpha = 1.0f;
    }];
}


- (void)hideEndPositionCell {
    self.endPositionSetCellIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.endPositionSetButton.alpha = 0.0f;
        self.endPositionLeftButton.alpha = 0.0f;
        self.endPositionRightButton.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.endPositionSetButton.hidden = YES;
        self.endPositionLeftButton.hidden = YES;
        self.endPositionRightButton.hidden = YES;
    }];
}


- (void)showEndPositionCell {
    self.endPositionSetCellIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.endPositionSetButton.hidden = NO;
    self.endPositionLeftButton.hidden = NO;
    self.endPositionRightButton.hidden = NO;
    
    self.endPositionSetButton.alpha = 0.0f;
    self.endPositionLeftButton.alpha = 0.0f;
    self.endPositionRightButton.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.endPositionSetButton.alpha = 1.0f;
        self.endPositionLeftButton.alpha = 1.0f;
        self.endPositionRightButton.alpha = 1.0f;
    }];
}


- (void)hideDampingSliderCell {
    self.dampingSliderCellIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.dampingSlider.alpha = 0.0f;
    } completion:^(BOOL finished){
        self.dampingSlider.hidden = YES;
    }];
}


- (void)showDampingSliderCell {
    self.dampingSliderCellIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.dampingSlider.hidden = NO;
    self.dampingSlider.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.dampingSlider.alpha = 1.0f;
    }];
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
