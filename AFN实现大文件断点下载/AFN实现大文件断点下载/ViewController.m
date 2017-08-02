//
//  ViewController.m
//  AFN实现大文件断点下载
//
//  Created by 李洞洞 on 2/9/16.
//  Copyright © 2016年 Minte. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

{//下载管理句柄 由其负责所有的网络操作请求
    NSURLSessionDownloadTask * _downLoadTask;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property(nonatomic,strong)AFURLSessionManager * manager;
@end

 #pragma mark --- NSURLSessionTask的三种任务类型
 /*
 1.NSURLSessionDataTask : 普通的GET\POST请求
 2.NSURLSessionDownloadTask : 文件下载
 3.NSURLSessionUploadTask : 文件上传（很少用，一般服务器不支持）
 */

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self downFileFromServer];
    [self updataLabel];
   
}

#pragma mark---利用AFN实现文件下载操作细节　

- (void)downFileFromServer{
    
    //远程地址
    NSString * str = @"http://124.207.22.2/Index/indexXml.dhtml?gradeId=50";
    
    NSURL *URL = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
#warning 换成公司接口就不能下 什么鬼这是.....
   //  NSURL *URL = [NSURL URLWithString:str];
    
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于URLSession封装的句柄
//    AFURLSessionManager * manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    self.manager = manager;
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //// manager 不能释放
   // _downloadManager = manager;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.requestSerializer.timeoutInterval = 60.0;
    

    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //下载Task操作
    _downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // @property int64_t totalUnitCount;     需要下载文件的总大小
        // @property int64_t completedUnitCount; 当前已经下载的大小
        
        // 给Progress添加监听 KVO
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        // 回到主队列刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // 设置进度条的百分比
            
            self.progress.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
           
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:@"afn.png"];
        return [NSURL fileURLWithPath:path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //设置下载完成操作
        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
        NSLog(@"这个filePath是我自定义的吧---->%@",filePath);
        NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
        UIImage *img = [UIImage imageWithContentsOfFile:imgFilePath];
        self.imageView.image = img;
        
    }];
}

- (void)updataLabel

{ 
    __weak typeof(self) weakself = self;
  
    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 设置进度条的百分比
            
        int currentDataSize = 0;
        currentDataSize+= bytesWritten;
            
        });
}];
    
}


- (IBAction)start:(UIButton *)sender {
    
     [_downLoadTask resume];
}

- (IBAction)stop:(UIButton *)sender {
       [_downLoadTask suspend];
    
}


@end
