//
//  HelpViewController.m
//  HermesControllerApp
//
//  Created by Woody Allen on 2015-03-17.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"HelpPage" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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

@end
