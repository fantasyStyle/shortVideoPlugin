#import "ShortVideoPlugin.h"
#import "AliyunRecoderViewController.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import "AliyunRecoderViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AVAsset+VideoInfo.h"
#if __has_include(<short_video_plugin/short_video_plugin-Swift.h>)
#import <short_video_plugin/short_video_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "short_video_plugin-Swift.h"
#endif
@interface ShortVideoPlugin()<FlutterPlugin,AliyunRecoderViewControllerDelegate,AliyunCropDelegate>{
   
}
@property (nonatomic,strong)FlutterResult  result;
@property (nonatomic, strong) AliyunCrop *cutPanel;
@property (nonatomic,strong)NSString * outputPath;
@property (nonatomic,strong)NSString * pageChangeStr;//页面跳转url
@property (nonatomic,assign)CGFloat width;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,strong)FlutterMethodChannel* channel;
@end
@implementation ShortVideoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftShortVideoPlugin registerWithRegistrar:registrar];
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"gyb.cn/AliShortVideo" binaryMessenger:[registrar messenger]];
    ShortVideoPlugin* instance = [[ShortVideoPlugin alloc] init];
     [registrar addMethodCallDelegate:instance channel:channel];
}
-(void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
    self.result = result;
    if ([@"getVideoRecoder" isEqualToString:call.method]) {
        AliyunVideoRecordParam *videoRecordParam = [[AliyunVideoRecordParam alloc] init];
        NSDictionary * dic = call.arguments;
        NSInteger  minTime = [dic[@"minDuration"] integerValue];
        NSInteger maxTime =  [dic[@"maxDuration"] integerValue];
         NSInteger recodertype =  [dic[@"recoderType"] integerValue];
        NSString * path = [NSString stringWithFormat:@"%@", dic[@"path"]];
        NSLog(@"%@", [NSString stringWithFormat:@"裁剪视频的原始路径%@",path]);//裁剪视频的原始路径
        if (recodertype == 3) {
            if (_cutPanel) {
                [_cutPanel cancel];
            }
            NSURL *sourceURL = [NSURL fileURLWithPath:path];
            AVAsset * _avAsset = [AVAsset assetWithURL:sourceURL];
            CGSize originalMediaSize = [_avAsset avAssetNaturalSize];
            CGFloat time = [_avAsset avAssetVideoTrackDuration];
            if (time > 185) {
                result(@"超时");
                return;
            }
            CGFloat targetWidth = 540; //目标宽度
            CGFloat targetHeight = 960; //目标高度
            CGFloat width = originalMediaSize.width; //实际宽度
            CGFloat height = originalMediaSize.height; //实际高度
            if (width > height) { //如果宽度大于高度横屏
                CGFloat temp = targetHeight;
                targetWidth = targetHeight;
                targetHeight = temp;
            }
            CGFloat scale = targetWidth / width; //缩放比
            CGFloat scaleWidth = targetWidth; //设置缩放宽度等于目标宽度
            CGFloat scaleHeight = height * scale;//计算缩放高度
            if (scaleHeight > targetHeight) { //如果缩放高度大于目标高度, 重新以高度重新计算宽度
                scale = targetHeight / height;
                scaleHeight = targetHeight;
                scaleWidth = width * scale;
            }
            self.width = scaleWidth;
            self.height = scaleHeight;
            _cutPanel = [[AliyunCrop alloc] init];
            _cutPanel.delegate = (id<AliyunCropDelegate>)self;
            _cutPanel.inputPath = path;
            self.outputPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cut_save.mp4"];
            _cutPanel.outputPath = self.outputPath;
            _cutPanel.outputSize = CGSizeMake(scaleWidth, scaleHeight);
            _cutPanel.fps = 25;
            _cutPanel.gop = 5;
            _cutPanel.bitrate = 1000*1024;
            _cutPanel.videoQuality = AliyunVideoQualityMedium;
            [_cutPanel startCrop];
        }else{
            videoRecordParam.ratio = AliyunVideoVideoRatio9To16;
            videoRecordParam.size = AliyunVideoVideoSize540P;
            videoRecordParam.minDuration = minTime;
            videoRecordParam.maxDuration = maxTime;
            videoRecordParam.position = AliyunCameraPositionBack;
            videoRecordParam.beautifyStatus = NO;
            videoRecordParam.beautifyValue = 50;
            videoRecordParam.bitrate = 1000*1024;
            videoRecordParam.videoQuality = AliyunVideoQualitysMedium;
            AliyunRecoderViewController *recordViewController = [[AliyunRecoderViewController alloc] init];
            [recordViewController setValue:self forKey:@"delegate"];
            recordViewController.videoRecordParam  = videoRecordParam;
            recordViewController.recodertype = recodertype;
            recordViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:recordViewController];
            nav.modalPresentationStyle =UIModalPresentationFullScreen;
            [[self getRootVC] presentViewController:nav animated:NO completion:nil];
        }
    }
    
    
}

- (UIViewController*) getRootVC {
  UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  while (root.presentedViewController != nil) {
    root = root.presentedViewController;
  }
  return root;
}

#pragma mark --- AliyunCropDelegate

- (void)cropTaskOnProgress:(float)progress {
    NSLog(@"~~~~~progress:%@", @(progress));
    //  NSString *err = [NSString stringWithFormat:@"进度: %f",progress];
    //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪失败" message:err delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    //  [alert show];
}

- (void)cropOnError:(int)error {
     self.result(@{@"path":@"",@"width":@"0",@"height":@"0",@"imagePath":@""});
    NSString *err = [NSString stringWithFormat:@"错误码: %d",error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪失败" message:err delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)cropTaskOnComplete {
       NSString * thumbImagePath = [self getScreenShotImageFromVideoPath:self.outputPath];
    NSLog(@"%@", [NSString stringWithFormat:@"获取的视频封面路径%@",thumbImagePath]);
//    [self.channel invokeMethod:@"videoCropComplete" arguments:@{@"path":self.outputPath,@"width":[NSString stringWithFormat:@"%d",(int)self.width] ,@"height":[NSString stringWithFormat:@"%d",(int)self.height],@"imagePath":thumbImagePath}];
    self.result(@{@"path":self.outputPath,@"width":[NSString stringWithFormat:@"%d",(int)self.width] ,@"height":[NSString stringWithFormat:@"%d",(int)self.height],@"imagePath":thumbImagePath});
}

- (void)cropTaskOnCancel {
    NSLog(@"cancel");
}


#pragma support function
/**
 *  获取视频的缩略图方法
 *
 *  @param filePath 视频的本地路径
 *
 *  @return 视频截图
 */
- (NSString *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    // 本地沙盒目录

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    // 得到本地沙盒中名为"MyImage"的路径，"MyImage"是保存的图片名
    NSString * timeStr = [self currentTimeStr];

    NSString *imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"adGuideImage%@.jpg",timeStr]];
    // 将取得的图片写入本地的沙盒中，其中0.5表示压缩比例，1表示不压缩，数值越小压缩比例越大

    BOOL success = [UIImageJPEGRepresentation(shotImage, 0.8) writeToFile:imageFilePath  atomically:YES];

    if (success){

        NSLog(@"图片保存成功");

    }else{
        imageFilePath = @"";
        NSLog(@"图片保存失败");

    }
    return imageFilePath;
}

//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}
#pragma mark -AliyunVideoBaseDelegate
- (void)videoBase:(AliyunVideoBase *)base recordCompeleteWithRecordViewController:(UIViewController *)recordVC videoPath:(NSString *)videoPath{
    NSString * thumbImagePath = [self getScreenShotImageFromVideoPath:videoPath];
    NSLog(@"%@", [NSString stringWithFormat:@"获取的视频封面路径%@",thumbImagePath]);
    self.result(@{@"path":videoPath,@"imagePath":thumbImagePath});
    [self dismissView];
}
- (void)dismissView {
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
    [[self getRootVC] dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - AliyunRecoderViewController delegate
- (void)recordResolved:(NSString *)filePath{
    NSString * thumbImagePath = [self getScreenShotImageFromVideoPath:filePath];
    NSLog(@"%@", [NSString stringWithFormat:@"获取的视频封面路径%@",thumbImagePath]);
    self.result(@{@"path":filePath,@"imagePath":thumbImagePath});
    [self dismissView];
}
@end

