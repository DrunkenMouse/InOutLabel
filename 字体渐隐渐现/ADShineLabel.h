//
//  ADShineLabel.h
//  字体渐隐渐现
//
//  Created by 王奥东 on 16/9/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADShineLabel : UILabel
/**
 *  字体渐近动画时间.默认是2.5s
 */
@property (assign, nonatomic, readwrite) CFTimeInterval shineDuration;

/**
 *  字体渐出动画.默认是2.5s
 */
@property (assign, nonatomic, readwrite) CFTimeInterval fadeoutDuration;


/**
 *  自动开启动画，默认是NO.
 */
@property (assign, nonatomic, readwrite, getter = isAutoStart) BOOL autoStart;

/**
 *  检查如果动画结束
 */
@property (assign, nonatomic, readonly, getter = isShining) BOOL shining;

/**
 *  是否可见
 */
@property (assign, nonatomic, readonly, getter = isVisible) BOOL visible;

/**
 *  开启这个动画
 */
- (void)shine;
- (void)shineWithCompletion:(void (^)())completion;
- (void)fadeOut;
- (void)fadeOutWithCompletion:(void (^)())completion;

@end
