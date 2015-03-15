//
//  TimeLapseModeViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeViewController.h"
#import "LabeledPickerView.h"

@interface TimeLapseModeViewController ()

@property (strong, nonatomic) NSMutableArray *hours;
@property (strong, nonatomic) NSMutableArray *minutes;
@property (strong, nonatomic) NSMutableArray *seconds;
@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation TimeLapseModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add pickerView
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
#define toolbarHeight           40.0
    CGFloat pickerTop = screenRect.size.height - toolbarHeight - pickerSize.height;
    CGRect pickerRect = CGRectMake(0.0, pickerTop, pickerSize.width, pickerSize.height);
    self.pickerView.frame = pickerRect;
    
    // Add label on top of pickerView
    CGFloat top = pickerTop + 2;
    CGFloat height = pickerSize.height - 2;
    [self addPickerLabel:@"x" rightX:123.0 top:top height:height];
    [self addPickerLabel:@"y" rightX:183.0 top:top height:height];
    
    
    //    // Do any additional setup after loading the view.
//    NSUInteger viewWidth = self.view.frame.size.width;
//    LabeledPickerView *myPickerView = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 200, viewWidth, 200)];
//    myPickerView.delegate = self;
//    myPickerView.showsSelectionIndicator = YES;
//    [self.view addSubview:myPickerView];
//    [myPickerView addLabel:@"hours" forComponent:0 forLongestString:@"5 hours"];
//    [myPickerView addLabel:@"min" forComponent:1 forLongestString:@"59 min"];
//    [myPickerView addLabel:@"sec" forComponent:2 forLongestString:@"59 sec"];
}

- (void)addPickerLabel:(NSString *)labelString rightX:(CGFloat)rightX top:(CGFloat)top height:(CGFloat)height {
#define PICKER_LABEL_FONT_SIZE 18
#define PICKER_LABEL_ALPHA 0.7
    UIFont *font = [UIFont boldSystemFontOfSize:PICKER_LABEL_FONT_SIZE];
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGFloat x = rightX - [labelString sizeWithAttributes:attributes].width;
    
    // White label 1 pixel below, to simulate embossing.
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, top + 1, rightX, height)];
    label.text = labelString;
    label.font = font;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.alpha = PICKER_LABEL_ALPHA;
    [self.view addSubview:label];
    
    // Actual label.
    label = [[UILabel alloc] initWithFrame:CGRectMake(x, top, rightX, height)];
    label.text = labelString;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.alpha = PICKER_LABEL_ALPHA;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPickerViewDataSource



# pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
}


// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) { // hours
        return 5;
    } else { // minutes or seconds
        return 60;
    }
}


// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2; // hours, minutes, seconds
}


// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", row];
}


// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 175;
    
    return sectionWidth;
}

@end
