//
//  HelpViewController.m
//  HermesControllerApp
//
//  Created by Woody Allen on 2015-03-17.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "HelpViewController.h"
#import "LabeledPickerView.h"

@interface HelpViewController ()

@property (strong, nonatomic) LabeledPickerView *pickerView;
//@property (weak, nonatomic) IBOutlet LabeledPickerView *pickerView;

@end


@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.pickerView = [[LabeledPickerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200)];
    self.pickerView.hidden = NO;
    self.pickerView.delegate = self;
    //self.pickerView.backgroundColor = [UIColor lightGrayColor];
    [self.pickerView addLabel:@"min" forComponent:0 forLongestString:@"min"];
    [self.pickerView addLabel:@"sec" forComponent:1 forLongestString:@"sec"];
    [self.view addSubview:self.pickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 6;
    } else {
        return 60*201;
    }
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentRight];
    [paragraphStyle setTailIndent:-self.pickerView.frame.size.width/7];
    
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)row % 60]
                                           attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return (self.pickerView.frame.size.width/3 - 1);
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return self.pickerView.frame.size.height/5;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row < 60*100 || row >= (5 * 101) ) {
        row = row % 60;
        row += 60*100;
        [pickerView selectRow:row inComponent:component animated:NO];
    }
}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    return [NSString stringWithFormat:@"%ld", row];
//}

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    return 100;  // any value less than 106.6, assuming pickerView's width = 320
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
