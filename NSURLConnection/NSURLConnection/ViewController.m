//
//  ViewController.m
//  NSURLConnection
//
//  Created by 李洞洞 on 2/9/16.
//  Copyright © 2016年 Minte. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDelegate,NSURLSessionDownloadDelegate>

@property(nonatomic,assign) long currentLength;

@property(nonatomic,strong)NSURLConnection * connection;

@property (weak, nonatomic) IBOutlet UIProgressView *pro;

@property (weak, nonatomic) IBOutlet UILabel *label;

@property(nonatomic,strong)NSURLSessionDownloadTask * downloadTask;

@property(nonatomic,strong)NSData * resumeData;
@end

@implementation ViewController

#pragma mark---一般下载功能的实现

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSURL * url =[NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
//    
//    
//    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
//    
//   
//    
//    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
//    
//    
//    
//    //以下为断点代码
//    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
//    btn.backgroundColor = [UIColor redColor];
//    [btn addTarget:self action:@selector(downLoad:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    
    [self sessionDownLoad2];
}

// 请求失败时调用（请求超时、网络异常）
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}

// 1.接收到服务器的响应就会调用
-(void)connection:(NSURLConnection**)connection didReceiveResponse:(NSURLResponse *)response{
    
}

// 2.当接收到服务器返回的实体数据时调用（具体内容，这个方法可能会被调用多次）
-(void)connection:(NSURLConnection**)connection didReceiveData:(NSData *)data{
    /*
     
     通过didReceiveData这个代理方法每次传回来一部分文件，最终我们把每次传回来的数据拼接合并成一个我们需要的文件写入沙盒，最终就获取到了我们需要的数据，需要注意的在我们获取一部分data的时候就写入沙盒中，然后释放内存中的data，而不是直接用来一个接受文件的NSMutableData，它一直都在内存中，会随着文件的下载一直变大。
     写入的时候这里要用到NSFilehandle这个类，这个类可以实现对文件的读取、写入、更新。在接受到响应的时候就在沙盒中创建一个空的文件，然后每次接收到数据的时候就拼接到这个文件的最后面，通过- (unsigned long long)seekToEndOfFile 这个方法，这样在下载过程中内存的问题就解决了。
    
     
     */
}

// 3.加载完毕后调用（服务器的数据已经完全返回后）
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}
#pragma mark---断点下载
/*
 为什么要用断点下载?
 答:暂停/继续下载是我们下载中过程中必不可少的的功能了，如果没有暂停功能，用户体验相比会很差，而且实际场景下如果突然网络不好中断了，没有实现断点下载的话我们只能重新下载了，用户体验非常不好。
*/

//NSURLConnection 只提供了一个cancel方法，这并不是暂停，而是取消下载任务。
#pragma mark---断点下载的理论基础
//如果要实现断点下载必须要了解HTTP协议中请求头的Range，通过设置请求头的Range我们可以指定下载的位置、大小。
//如果我们这样设置bytes=500-，表示从500字节以后的所有字节,只需要在didReceiveData中记录已经写入沙盒中文件的大小，把这个大小设置到请求头中，因为第一次下载肯定是没有执行过didReceive方法，self.currentLength也就为0，也就是从头开始下。

- (void)downLoad:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        
        NSURL * url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        //设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%ld-",self.currentLength];
        
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        //3.下载
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
    }else {
        
        [self.connection cancel];
        self.connection = nil;
    }
    
    
}


//为了提高下载的效率，我们一般采用多线程下载。
#pragma mark ----关于NSURLSession
/*
 NSURLSession是iOS7之后新的网络接口
 NSURLSession也是一组相互依赖的类,而NSURLSession的不同之处在于
 它将NSURLConnection替换为 NSURLSession和 NSURLSessionConfiguration
 以及3个 NSURLSessionTask的子类: NSURLSessionDataTask , NSURLSessionUploadTask, 和NSURLSessionDownloadTask。
另外，上面的NSURLConnection要自己去控制内存写入相应的位置，而NSURLSession则不需要手动写入沙盒，更加方便了我们的使用。
 */

#pragma mark --- NSURLSessionTask的三种任务类型
/*
 1.NSURLSessionDataTask : 普通的GET\POST请求
 2.NSURLSessionDownloadTask : 文件下载
 3.NSURLSessionUploadTask : 文件上传（很少用，一般服务器不支持）
 */


- (void)session
{
    //创建session对象
    NSURLSession * session = [NSURLSession sharedSession];
    
    NSURL * url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    //创建一个任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //data返回数据
      
    }];
    
    //开启任务
    [dataTask resume];
}

#pragma mark---NSURLSession的简易下载
/*
 使用NSURLSession下载相对于NSURLConnection就非常简单了，不需要去手动控制边下载边写入沙盒的问题
 */
- (void)sessionDownLoad
{
    NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    // 得到session对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //创建任务
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // location : 临时文件的路径（下载好的文件），也就是下载好的文件写入沙盒的地址，打印一下发现下载好的文件被自动写入的temp文件夹下面了。
       //目前来讲 缓存目录是最安全的 Document容易被拒
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        
        // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
        NSString *file = [caches stringByAppendingPathComponent:@"ldd.dmg"];
        //suggestedFilename是NSURLResponse类的一个属性//可以拼接其他值 只是一个路径而已
        
          NSLog(@"下载完的文件缓存地址----->%@",file);
        // 将临时文件剪切或者复制Caches文件夹
        NSFileManager *mgr = [NSFileManager defaultManager];
        
        // AtPath : 剪切前的文件路径
        // ToPath : 剪切后的文件路径
        [mgr moveItemAtPath:location.path toPath:file error:nil];
        
    }];
    
    [downloadTask resume];
}
//亲测 以上方法是可以下载的 丝毫没问题
//但是 有个缺点就是无法监听下载进度，要监听下载进度，我们通常的作法是通过delegate，而且NSURLSession的创建方式也有所不同。首先遵守协议<NSURLSessionDownloadDelegate>协议里面有三个方法。
#pragma mark ---NSURLSession监听下载进度
- (void)sessionDownLoad2
{/*NSURLSession的不同之处在于
    它将NSURLConnection替换为 NSURLSession和 NSURLSessionConfiguration
    以及3个 NSURLSessionTask的子类*/
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
   
    NSURL* url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
    
    NSURLSessionDownloadTask * downLoadTask = [session downloadTaskWithURL:url];
    self.downloadTask = downLoadTask;
    [downLoadTask resume];
}
#pragma mark ---NSURLSessionDownLoadDelegate协议方法
//下载完 会调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    // response.suggestedFilename:建议使用的文件名，一般跟服务器端的文件名一致
    NSString *filePath = [cache stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    
    //将临时文件剪切或复制到Caches文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // AtPath : 剪切前的文件路径 ,ToPath : 剪切后的文件路径
    [fileManager moveItemAtPath:location.path toPath:filePath error:nil];
    
    NSLog(@"下载完成");

}

//执行下载任务时有数据写入,在这里面监听下载进度(totalBytesWritten/totalBytesExpectedToWrite
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
 /*
  @param bytesWritten              这次写入的大小
  @param totalBytesWritten         已经写入的大小
  @param totalBytesExpectedToWrite 文件总大小
  
  */
    
    
    self.pro.progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    
    self.label.text = [NSString stringWithFormat:@"下载进度%.2f",(double)totalBytesWritten/totalBytesExpectedToWrite];
}

//3.恢复下载后调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
- (IBAction)NextDownLoad:(id)sender {
    
    if (self.downloadTask.state == NSURLSessionTaskStateSuspended) {
        NSLog(@"继续");
        [self.downloadTask resume];
    }
}

//-(NSURLSessionDownloadTask**)downloadTaskWithResumeData:(NSData*)resumeData
//{
//    
//}

- (IBAction)buttonClick:(UIButton *)sender {
    
    
    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        NSLog(@"暂停");
        [self.downloadTask suspend];
    }
    
    
//    __weak typeof(self) weakSelf = self;
//    
//    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//        //  resumeData : 包含了继续下载的开始位置\下载的url
//        weakSelf.resumeData = resumeData;
//        weakSelf.downloadTask = nil;
//    }];
    
}




@end
