//
//  QURecordParamViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AlivcBase_RecordParamViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "AlivcBase_RecordParamTableViewCell.h"
#import "AliyunVideoRecordParam.h"
#import "AlivcBase_RecordViewController.h"
#import "AliyunVideoBase.h"
#import "AliyunVideoCropParam.h"
#import "AliyunVideoUIConfig.h"

@interface AlivcBase_RecordParamViewController ()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;


@property (nonatomic, strong) AliyunVideoRecordParam *quVideo;

@property (nonatomic, assign) CGFloat videoOutputWidth;
@property (nonatomic, assign) CGFloat videoOutputRatio;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation AlivcBase_RecordParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupParamData];
    [self setupSDKBaseVersionUI];
    [_tableView reloadData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [self.tableView addGestureRecognizer:tapGesture];
    

    _quVideo = [[AliyunVideoRecordParam alloc] init];
    _quVideo.ratio = AliyunVideoVideoRatio3To4;
    _quVideo.size = AliyunVideoVideoSize540P;
    _quVideo.minDuration = 2;
    _quVideo.maxDuration = 30;
    _quVideo.position = AliyunCameraPositionFront;
    _quVideo.beautifyStatus = YES;
    _quVideo.beautifyValue = 100;
    _quVideo.torchMode = AliyunCameraTorchModeOff;
    _quVideo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_save.mp4"];

    
    self.videoOutputRatio = 0.75;
    self.videoOutputWidth = 540;
    
    #if DEBUG
        self.rightButton.hidden = NO;
    #else
        self.rightButton.hidden = YES;
    #endif
}

- (IBAction)rightButtonClick:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"硬编"]) {
        [sender setTitle:@"软编" forState:UIControlStateNormal];
        _quVideo.encodeMode = AliyunEncodeModeSoftH264;
    }else{
        [sender setTitle:@"硬编" forState:UIControlStateNormal];
        _quVideo.encodeMode = AliyunEncodeModeHardH264;
    }
}

- (void)hiddenKeyboard:(id)sender {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AlivcBase_RecordParamModel *model = _dataArray[indexPath.row];
    if (model) {
        NSString *identifier = model.reuseId;
        AlivcBase_RecordParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[AlivcBase_RecordParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell configureCellModel:model];
        return cell;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 50, 0, 100, 44)];
    [button setTitle:@"启动录制" forState:0];
    [button addTarget:self action:@selector(toRecordView) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = RGBToColor(240, 84, 135);
    [view addSubview:button];
    return view;
}

- (void)setupParamData {
    
//        AlivcBase_RecordParamModel *cellModel0 = [[AlivcBase_RecordParamModel alloc] init];
//        cellModel0.title = @"码率";
//        cellModel0.placeHolder = @"";
//        cellModel0.reuseId = @"cellInput";
//        cellModel0.valueBlock = ^(int value){
//            _quVideo.bitrate = value;
//        };

    
    AlivcBase_RecordParamModel *cellModel1 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel1.title = @"最小时长";
    cellModel1.placeHolder = @"最小时长大于0，默认值2s";
    cellModel1.reuseId = @"cellInput";
    cellModel1.valueBlock = ^(int value){
        _quVideo.minDuration = value;
    };
    
    AlivcBase_RecordParamModel *cellModel2 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel2.title = @"最大时长";
    cellModel2.placeHolder = @"建议不超过300S，默认值30s";
    cellModel2.reuseId = @"cellInput";
    cellModel2.valueBlock = ^(int value){
        _quVideo.maxDuration = value;
    };
    
    AlivcBase_RecordParamModel *cellModel3 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel3.title = @"关键帧间隔";
    cellModel3.placeHolder = @"建议1-300，默认5";
    cellModel3.reuseId = @"cellInput";
    cellModel3.valueBlock = ^(int value) {
        _quVideo.gop = value;
    };
    
    AlivcBase_RecordParamModel *cellModel4 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel4.title = @"视频质量";
    cellModel4.placeHolder = @"高";
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 0.25;
    cellModel4.valueBlock = ^(int value){
        _quVideo.videoQuality = value;
    };
    
    AlivcBase_RecordParamModel *cellModel5 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel5.title = @"视频比例";
    cellModel5.placeHolder = @"3:4";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 0.6;
    cellModel5.ratioBack = ^(CGFloat videoRatio){
        self.videoOutputRatio = videoRatio;
    };
    
    AlivcBase_RecordParamModel *cellModel6 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel6.title = @"分辨率";
    cellModel6.placeHolder = @"540P";
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.sizeBlock = ^(CGFloat videoWidth){
        self.videoOutputWidth = videoWidth;
    };
    
    
    _dataArray = @[cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6];
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
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"炽黄",@"粉桃",@"海蓝",@"红润",@"灰白",@"经典",@"麦茶",@"浓烈",@"柔柔",@"闪耀",@"鲜果",@"雪梨",@"阳光",@"优雅",@"朝阳",@"波普",@"光圈",@"海盐",@"黑白",@"胶片",@"焦黄",@"蓝调",@"迷糊",@"思念",@"素描",@"鱼眼",@"马赛克",@"模糊"];
    config.imageBundleName = @"QPSDK";
    config.filterBundleName = @"FilterResource";
    config.recordType = AliyunVideoRecordTypeCombination;
    config.showCameraButton = NO;
    
    [[AliyunVideoBase shared] registerWithAliyunIConfig:config];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view resignFirstResponder];
}

- (IBAction)buttonBackClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)toRecordView {
    [self.view endEditing:YES];

    
    if (self.videoOutputWidth == 360) {
        _quVideo.size = AliyunVideoVideoSize360P;
    }else if (self.videoOutputWidth == 480) {
        _quVideo.size = AliyunVideoVideoSize480P;
    }else if (self.videoOutputWidth == 540) {
        _quVideo.size = AliyunVideoVideoSize540P;
    }else if (self.videoOutputWidth == 720) {
        _quVideo.size = AliyunVideoVideoSize720P;
    }
    
    if (self.videoOutputRatio == 0.5625) {
        _quVideo.ratio = AliyunVideoVideoRatio9To16;
    }else if (self.videoOutputRatio == 0.75) {
        _quVideo.ratio = AliyunVideoVideoRatio3To4;
    } else {
        _quVideo.ratio = AliyunVideoVideoRatio1To1;
    }

    if (_quVideo.maxDuration == 0) {
        _quVideo.maxDuration = 15;
    }
    
    if (_quVideo.minDuration == 0) {
        _quVideo.minDuration = 2;
    }
    
    if (_quVideo.maxDuration <= _quVideo.minDuration) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不得小于最小时长" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    UIViewController *recordViewController = [[AliyunVideoBase shared] createRecordViewControllerWithRecordParam:_quVideo];
    [AliyunVideoBase shared].delegate = (id)self;
    [self.navigationController pushViewController:recordViewController animated:YES];
    
}

#pragma mark - AliyunVideoBaseDelegate
-(void)videoBaseRecordVideoExit {
    NSLog(@"退出录制");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoBase:(AliyunVideoBase *)base recordCompeleteWithRecordViewController:(UIViewController *)recordVC videoPath:(NSString *)videoPath {
    NSLog(@"录制完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [recordVC.navigationController popViewControllerAnimated:YES];
                                    });
                                }];
}

- (AliyunVideoCropParam *)videoBaseRecordViewShowLibrary:(UIViewController *)recordVC {
    
    NSLog(@"录制页跳转Library");
    // 可以更新相册页配置
    AliyunVideoCropParam *mediaInfo = [[AliyunVideoCropParam alloc] init];
    mediaInfo.minDuration = 2.0;
    mediaInfo.maxDuration = 10.0*60;
    mediaInfo.fps = 25;
    mediaInfo.gop = 5;
    mediaInfo.videoQuality = 1;
    mediaInfo.videoOnly = YES;//视频裁剪功能只显示视频
    mediaInfo.size = AliyunVideoVideoSize540P;
    mediaInfo.ratio = AliyunVideoVideoRatio3To4;
    mediaInfo.cutMode = AliyunVideoCutModeScaleAspectFill;
    mediaInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cut_save.mp4"];
    return mediaInfo;
    
}

// 裁剪
- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC videoPath:(NSString *)videoPath {
    
    NSLog(@"裁剪完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [cropVC.navigationController popViewControllerAnimated:YES];
                                    });
                                }];
    
}

- (AliyunVideoRecordParam *)videoBasePhotoViewShowRecord:(UIViewController *)photoVC {
    
    NSLog(@"跳转录制页");
    return nil;
}

- (void)videoBasePhotoExitWithPhotoViewController:(UIViewController *)photoVC {
    
    NSLog(@"退出相册页");
    [photoVC.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 默认竖屏
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
