//
//  IDYIJKPlayerViewController.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/16.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "IDYIJKPlayerViewController.h"
#import "IDYPlayerView.h"

@interface IDYIJKPlayerViewController ()

@property (nonatomic, strong) IDYPlayerView *playerView;

@end

@implementation IDYIJKPlayerViewController


- (IDYPlayerView *)playerView{
    
    if (!_playerView) {
        
        _playerView = [[IDYPlayerView alloc] initWithFrame:self.view.bounds contentUrl:[NSURL URLWithString:@"udp://10.5.5.9:8554"]];
    }
    return _playerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.playerView];
    [self.playerView.player play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    
    [self.playerView removeFromSuperview];
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
