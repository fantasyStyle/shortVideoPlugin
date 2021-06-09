//
//  AliyunRecoderViewController.m
//  gybrn
//
//  Created by 快邦 on 2018/9/19.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "AliyunRecoderViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define DEBUG_TEST 0
#define DebugModule 0b100101

typedef NS_OPTIONS(NSUInteger, DebugModuleOption) {
  DebugModuleOptionVideo = 1 << 5,
  DebugModuleOptionMagicCamera = 1 << 4,
  DebugModuleOptionImportEdit = 1 << 3,
  DebugModuleOptionImportClip = 1 << 2,
  DebugModuleOptionLive = 1 << 1,
  DebugModuleOptionComposition = 1 << 0,
};

@interface AliyunRecoderViewController ()<AliyunVideoBaseDelegate>

@property (assign, nonatomic) DebugModuleOption moduleOption;
@property (assign, nonatomic) BOOL isClipConfig;
@property (assign, nonatomic) BOOL isPhotoToRecord;
@end

@implementation AliyunRecoderViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.moduleOption = DebugModule;

  [self setupSDKBaseVersionUI];
  
  [[UIApplication sharedApplication] setStatusBarHidden:TRUE];

  @try{
    if (self.recodertype == 1) {
      UIViewController *recordViewController = [[AliyunVideoBase shared] createRecordViewControllerWithRecordParam:self.videoRecordParam];
      [AliyunVideoBase shared].delegate = (id)self;
      [self.navigationController pushViewController:recordViewController animated:YES];
    }else if (self.recodertype == 2){
      [self createPhotoViewControllerCropParam];
    }
  }
  @catch(NSException *exception) {
    NSLog(@"exception:%@", exception);
  }
  @finally {
    
  }
 
}

/**
 创建一个相册导入界面
 @param cropParam 裁剪视频参数
 @return 相册导入界面
 */
//createPhotoViewControllerCropParam
-(void)createPhotoViewControllerCropParam{
  AliyunVideoCropParam *mediaInfo = [[AliyunVideoCropParam alloc] init];
  mediaInfo.minDuration = self.videoRecordParam.minDuration;
  mediaInfo.maxDuration = self.videoRecordParam.maxDuration;
  mediaInfo.fps = 25;
  mediaInfo.gop = 5;
  mediaInfo.videoQuality = AliyunVideoQualityMedium;
  mediaInfo.size = AliyunVideoVideoSize540P;
  mediaInfo.ratio = AliyunVideoVideoRatio9To16;
  mediaInfo.cutMode = AliyunVideoCutModeScaleAspectFill;
  mediaInfo.videoOnly = YES;
  mediaInfo.gpuCrop = YES;
  mediaInfo.bitrate = 1000*1024;
  mediaInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cut_save.mp4"];

  UIViewController *photoViewController = [[AliyunVideoBase shared] createPhotoViewControllerCropParam:mediaInfo];
  [AliyunVideoBase shared].delegate = self;
  [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)viewDidDisappear {

}

//基础版参数绘制
- (void)setupSDKBaseVersionUI {
  AliyunVideoUIConfig *config = [[AliyunVideoUIConfig alloc] init];
  
  config.backgroundColor = RGBToColor(35, 42, 66);
  config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
  config.timelineDeleteColor = [UIColor redColor];
  config.timelineTintColor = RGBToColor(239, 75, 129);
  config.durationLabelTextColor = [UIColor redColor];
  config.cutTopLineColor = [UIColor redColor];
  config.cutBottomLineColor = [UIColor redColor];
  config.noneFilterText = @"无滤镜";
  config.hiddenDurationLabel = NO;
  config.hiddenFlashButton = NO;
  config.hiddenBeautyButton = YES;
  config.hiddenCameraButton = NO;
  config.hiddenImportButton = YES;
  config.hiddenDeleteButton = NO;
  config.hiddenFinishButton = NO;
  config.recordOnePart = NO;
  config.imageBundleName = @"QPSDK";
  config.filterBundleName = @"FilterResource";
  config.recordType = AliyunVideoRecordTypeCombination;
  config.showCameraButton = NO;
  
  [[AliyunVideoBase shared] registerWithAliyunIConfig:config];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.navigationController.navigationBar.hidden = YES;
}

- (void)clipLayerBoundsWithButton:(UIButton *)button {
  button.layer.cornerRadius = 25;
  button.layer.masksToBounds = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)backBtnClick:(UIViewController *)vc {
  //    [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
  [self.navigationController popViewControllerAnimated:YES];
}

//相册退出界面
- (void)dismissView {
  [[UIApplication sharedApplication] setStatusBarHidden:FALSE];
  [[self getRootVC] dismissViewControllerAnimated:NO completion:nil];
  //  [self.bridge.eventDispatcher sendAppEventWithName:@"RNShortVideoDismissView" body:@"dismissView"];
}
- (UIViewController*) getRootVC {
  UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  while (root.presentedViewController != nil) {
    root = root.presentedViewController;
  }

  return root;
}

#pragma mark - AliyunVideoBaseDelegate
-(void)videoBaseRecordVideoExit {
  NSLog(@"退出录制");
  //    [self.navigationController popViewControllerAnimated:YES];
  if (self.delegate && [self.delegate respondsToSelector:@selector(recordResolved:)]) {
    [self.delegate recordResolved: @""];
  }
}

- (void)videoBase:(AliyunVideoBase *)base recordCompeleteWithRecordViewController:(UIViewController *)recordVC videoPath:(NSString *)videoPath {
  NSLog(@"录制完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                              completionBlock:^(NSURL *assetURL, NSError *error) {

                                if (self.delegate && [self.delegate respondsToSelector:@selector(recordResolved:)]) {

                                  [self.delegate recordResolved: videoPath];
                                }
                                //                                    dispatch_async(dispatch_get_main_queue(), ^{
                                //                                        [recordVC.navigationController popViewControllerAnimated:YES];
                                //                                    });
                            }];
}


//- (AliyunVideoCropParam *)videoBaseRecordViewShowLibrary:(UIViewController *)recordVC {
//
//  NSLog(@"录制页跳转Library");
//  // 可以更新相册页配置
//  AliyunVideoCropParam *mediaInfo = [[AliyunVideoCropParam alloc] init];
//  mediaInfo.minDuration = 2.0;
//  mediaInfo.maxDuration = 15;
////  mediaInfo.fps = 25;
////  mediaInfo.gop = 5;
//  mediaInfo.videoQuality = AliyunVideoQualityMedium;
////  mediaInfo.size = AliyunVideoVideoSize360P;
////  mediaInfo.ratio = AliyunVideoVideoRatio1To1;
//  //mediaInfo.cutMode = AliyunVideoCutModeScaleAspectFill;
//  mediaInfo.videoOnly = YES;
//  mediaInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cut_save.mp4"];
//  return mediaInfo;
//
//}

// 裁剪
- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC videoPath:(NSString *)videoPath {

  NSLog(@"裁剪完成  %@", videoPath);
//  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//  [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
//                              completionBlock:^(NSURL *assetURL, NSError *error) {
//                                dispatch_async(dispatch_get_main_queue(), ^{
                                  if (self.recodertype == 1) {
                                    [cropVC.navigationController popViewControllerAnimated:YES];
                                  }else if (self.recodertype == 2){
                                    [self dismissView];
                                  }
                                  if (self.delegate && [self.delegate respondsToSelector:@selector(recordResolved:)]) {

                                    [self.delegate recordResolved: videoPath];
                                  }
//                                });
//                              }];

}

- (AliyunVideoRecordParam *)videoBasePhotoViewShowRecord:(UIViewController *)photoVC {

  NSLog(@"跳转录制页");
  return nil;
}

- (void)videoBasePhotoExitWithPhotoViewController:(UIViewController *)photoVC {

  NSLog(@"退出相册页");
   [self dismissView];
//  [photoVC.navigationController popViewControllerAnimated:YES];
}

@end
