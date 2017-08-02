//
//  ViewController.m
//  NSURLSession下载和断点续传
//
//  Created by 李洞洞 on 2/9/16.
//  Copyright © 2016年 Minte. All rights reserved.
//

#import "ViewController.h"
//#import "AFNetworking.h"

@interface ViewController ()<NSURLSessionDelegate>
{
    NSURLSessionDownloadTask * _task;
    NSData * _data;
    NSURLSession * _session;
    NSURLRequest * _request;
    UIProgressView * _pro;
    UIImageView * _imageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    _imageView.center=self.view.center;
    [self.view addSubview:_imageView];
    
    _pro=[[UIProgressView alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y+300, 300, 40)];
    
    [self.view addSubview:_pro];
    UIButton * button=[[UIButton alloc] initWithFrame:CGRectMake(50, _imageView.frame.origin.y+340, 50, 40)];
    button.backgroundColor=[UIColor blueColor];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ddLoad) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth=1;
    button.layer.borderColor=[UIColor blueColor].CGColor;
    button.layer.cornerRadius=5;
    [self.view addSubview:button];
    
    
    UIButton * button1=[[UIButton alloc] initWithFrame:CGRectMake(120, _imageView.frame.origin.y+340, 50, 40)];
    button1.backgroundColor=[UIColor blueColor];
    [button1 setTitle:@"暂停" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    button1.layer.borderWidth=1;
    button1.layer.borderColor=[UIColor blueColor].CGColor;
    button1.layer.cornerRadius=5;
    [self.view addSubview:button1];
    
    
    
    
    UIButton * button2=[[UIButton alloc] initWithFrame:CGRectMake(190, _imageView.frame.origin.y+340, 50, 40)];
    button2.backgroundColor=[UIColor blueColor];
    [button2 setTitle:@"恢复" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    button2.layer.borderWidth=1;
    button2.layer.borderColor=[UIColor blueColor].CGColor;
    button2.layer.cornerRadius=5;
    [self.view addSubview:button2];
    
}
- (void) ddLoad{
    
    NSURLSessionConfiguration * config=[NSURLSessionConfiguration defaultSessionConfiguration];
    
    _session=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    //
    NSURL *url=[NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    
    _request=[NSURLRequest requestWithURL:url];
    
    _task= [_session downloadTaskWithRequest:_request];
    
    NSLog(@"开始加载");
    
    [_task resume];
}
- (void) pause{
    //暂停
    NSLog(@"暂停下载");
    [_task cancelByProducingResumeData:^(NSData *resumeData) {
        
        _data=resumeData;
    }];
    
    _task=nil;
}
- (void) resume{
    //恢复
    NSLog(@"恢复下载");
    if(!_data){
        
        NSURL *url=[NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
        
        _request=[NSURLRequest requestWithURL:url];
        
        _task=[_session downloadTaskWithRequest:_request];
        
    }else{
        
        _task=[_session downloadTaskWithResumeData:_data];
    }
    
    [_task resume]; 
}

#pragma mark - delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    //NSURL * url=[NSURL fileURLWithPath:@"/Users/lidongdong/Desktop/图片/666"];
    
    NSFileManager * manager=[NSFileManager defaultManager];
    
    [manager moveItemAtPath:location.path toPath:@"/Users/lidongdong/Desktop/图片/666/xiazaide.dmg" error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSData * data=[manager contentsAtPath:@"/Users/lidongdong/Desktop/图片/219916031019081.jpg"];
        
        UIImage * image=[[UIImage alloc ]initWithData:data];
        _imageView.image=image;
        
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:nil message:@"下载完成" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }) ;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    
    CGFloat progress=(totalBytesWritten*1.0)/totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _pro.progress=progress;
        
    }) ;
}


@end
