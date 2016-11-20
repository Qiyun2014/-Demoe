//
//  WTMelodyBinViewController.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/18.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "WTMelodyBinViewController.h"

static const int maxNumber_count = 200;

@interface WTMelodyBinViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIImageView   *topImageView;      /* configure add */
@property (nonatomic, strong) UITextView    *textView;          /* configure description */
@property (nonatomic, strong) UILabel       *statisticLabel;

@end

@implementation WTMelodyBinViewController


#pragma mark    -   懒加载

- (UIImageView *)topImageView{
    
    if (!_topImageView) {
        
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 40)];
        _topImageView.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedStringFromTableInBundle(@"wt_melody_configure_defaule", @"WTString", [NSBundle mainBundle], @"default configure");
        [_topImageView addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:NSLocalizedStringFromTableInBundle(@"wt_melody_configure_add", @"WTString", [NSBundle mainBundle], @"") forState:UIControlStateNormal];
        [button setFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 100, 0, 80, 40)];
        [_topImageView addSubview:button];
        
        [_topImageView setUserInteractionEnabled:YES];
        [button addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topImageView;
}

- (UITextView *)textView{
    
    if (!_textView) {
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.topImageView.bounds) + 64, CGRectGetWidth(self.view.bounds), 120)];
        _textView.text = @"please input text...";
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor orangeColor];
        
        _statisticLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_textView.bounds) - 100, CGRectGetHeight(_textView.bounds) - 35, 95, 30)];
        _statisticLabel.text = NSLocalizedStringFromTableInBundle(@"wt_melody_default_numberCount", @"WTString", [NSBundle mainBundle], @"");
        _statisticLabel.textAlignment = NSTextAlignmentRight;
        [_textView addSubview:_statisticLabel];
    }
    return _textView;
}


#pragma mark    -   点击事件

- (void)addAction:(UIButton *)button{
    
    NSLog(@"add...");
}


#pragma mark    -   系统控件代理

- (void)textViewDidChange:(UITextView *)textView{
    
    _statisticLabel.text = [NSString stringWithFormat:@"%lu字",maxNumber_count - textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    return (textView.text.length + text.length - range.length) <= maxNumber_count;
}


#pragma mark    -   公开，私有方法


#pragma mark    -   生命周期

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"~~~";
    
    [self.view addSubview:self.topImageView];
    [self.view addSubview:self.textView];
    _statisticLabel.text = [NSString stringWithFormat:@"%lu字",maxNumber_count - self.textView.text.length];

    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
