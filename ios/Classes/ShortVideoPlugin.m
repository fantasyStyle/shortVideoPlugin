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
        NSLog(@"%@", [NSString stringWithFormat:@"???????????????????????????%@",path]);//???????????????????????????
        if (recodertype == 3) {
            if (_cutPanel) {
                [_cutPanel cancel];
            }
            NSURL *sourceURL = [NSURL fileURLWithPath:path];
            AVAsset * _avAsset = [AVAsset assetWithURL:sourceURL];
            CGSize originalMediaSize = [_avAsset avAssetNaturalSize];
            CGFloat time = [_avAsset avAssetVideoTrackDuration];
            if (time > 185) {
                result(@"??????");
                return;
            }
            CGFloat targetWidth = 540; //????????????
            CGFloat targetHeight = 960; //????????????
            CGFloat width = originalMediaSize.width; //????????????
            CGFloat height = originalMediaSize.height; //????????????
            if (width > height) { //??????????????????????????????
                CGFloat temp = targetHeight;
                targetWidth = targetHeight;
                targetHeight = temp;
            }
            CGFloat scale = targetWidth / width; //?????????
            CGFloat scaleWidth = targetWidth; //????????????????????????????????????
            CGFloat scaleHeight = height * scale;//??????????????????
            if (scaleHeight > targetHeight) { //????????????????????????????????????, ?????????????????????????????????
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
    //  NSString *err = [NSString stringWithFormat:@"??????: %f",progress];
}

- (void)cropOnError:(int)error {
     self.result(@{@"path":@"",@"width":@"0",@"height":@"0",@"imagePath":@""});
    NSString *err = [NSString stringWithFormat:@"?????????: %d",error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"????????????" message:err delegate:nil cancelButtonTitle:@"?????????" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)cropTaskOnComplete {
       NSString * thumbImagePath = [self getScreenShotImageFromVideoPath:self.outputPath];
    NSLog(@"%@", [NSString stringWithFormat:@"???????????????????????????%@",thumbImagePath]);
//    [self.channel invokeMethod:@"videoCropComplete" arguments:@{@"path":self.outputPath,@"width":[NSString stringWithFormat:@"%d",(int)self.width] ,@"height":[NSString stringWithFormat:@"%d",(int)self.height],@"imagePath":thumbImagePath}];
    self.result(@{@"path":self.outputPath,@"width":[NSString stringWithFormat:@"%d",(int)self.width] ,@"height":[NSString stringWithFormat:@"%d",(int)self.height],@"imagePath":thumbImagePath});
}

- (void)cropTaskOnCancel {
    NSLog(@"cancel");
}


#pragma support function
/**
 *  ??????????????????????????????
 *
 *  @param filePath ?????????????????????
 *
 *  @return ????????????
 */
- (NSString *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    UIImage *shotImage;
    //????????????URL
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
    // ??????????????????

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    // ???????????????????????????"MyImage"????????????"MyImage"?????????????????????
    NSString * timeStr = [self currentTimeStr];

    NSString *imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"adGuideImage%@.jpg",timeStr]];
    // ???????????????????????????????????????????????????0.5?????????????????????1????????????????????????????????????????????????

    BOOL success = [UIImageJPEGRepresentation(shotImage, 0.8) writeToFile:imageFilePath  atomically:YES];

    if (success){

        NSLog(@"??????????????????");

    }else{
        imageFilePath = @"";
        NSLog(@"??????????????????");

    }
    return imageFilePath;
}

//?????????????????????
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//??????????????????0???????????????
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 ?????????????????????????????????????????????
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}
#pragma mark -AliyunVideoBaseDelegate
- (void)videoBase:(AliyunVideoBase *)base recordCompeleteWithRecordViewController:(UIViewController *)recordVC videoPath:(NSString *)videoPath{
    NSString * thumbImagePath = [self getScreenShotImageFromVideoPath:videoPath];
    NSLog(@"%@", [NSString stringWithFormat:@"???????????????????????????%@",thumbImagePath]);
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
    NSLog(@"%@", [NSString stringWithFormat:@"???????????????????????????%@",thumbImagePath]);
    self.result(@{@"path":filePath,@"imagePath":thumbImagePath});
    [self dismissView];
}
@end

