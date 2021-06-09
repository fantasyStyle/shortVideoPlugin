//
//  AliyunRecoderViewController.h
//  gybrn
//
//  Created by 快邦 on 2018/9/19.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AliyunRecoderViewControllerDelegate <NSObject>

- (void)recordResolved:(NSString *)filePath;

@end
@interface AliyunRecoderViewController : UIViewController
 @property (assign, nonatomic) id<AliyunRecoderViewControllerDelegate> delegate;
@property (strong, nonatomic) AliyunVideoRecordParam * videoRecordParam;//录制参数
@property (assign, nonatomic) NSInteger recodertype;//1视频录制 2.相册选择
@end
