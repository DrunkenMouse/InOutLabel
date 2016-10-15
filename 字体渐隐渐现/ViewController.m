//
//  ViewController.m
//  字体渐隐渐现
//
//  Created by 王奥东 on 16/9/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//
//仿RQShineLabel:https://github.com/zipme/RQShineLabel
//附带全解析
/**
 
 设置ADLabel的text内容时，就会通过text的set方法将字符串转换成可变字符串
 通过可变字符串的set方法，将字符串中的字符颜色透明度都设置为0并赋值给ADLabel
 并为每个字符设置一个随机并基于动画时间而生成的淡出时间保存在数组中
 
 shine方法:动画开启并没有指定完成后的操作
 shineWithCompletion: 动画开启并指定完成后的操作
 调用shine方法后会调用shineWithCompletion，传过去的操作为nil
 在shineWithCompletion方法中会完成保存操作,并设置淡出效果为NO,而后开启动画
 
 开启动画:startAnimationWithDuration
 其中会获取当前时间为开始时间，开始时间加字体渐近时间shineDuration为结束时间
 通过取消帧动画的暂停开启帧动画updateAttributedString
 
 帧动画里会获取当前时间用于判断是否超出动画时间
 遍历可变字符串的每个字符，并修改除空格、回车(包含'\n')、tab之外的字符的透明度
 透明度是否修改通过以下方式判断：
 1.淡出效果并且透明度大于0
 2.不是淡出效果并且透明度小于1
 3.当前时间 - 动画开始时间 >= 基于淡出效果而生成的一个随机时间
 应该更新则获取所需透明度值 : 当前时间 - 开始时间 - 基于淡出效果而生成的一个随机时间
 如果是淡出状态就获取 1 - 透明度值
 修改完后设置可变字符串内容
 并判断如果当前时间超过动画结束时间，暂停帧动画，执行结束操作
 
 至此，动画效果完成
 
 fadeOut: 手动开启淡出效果但没有结束后的操作
 fadeOutWithCompletion: 手动开启淡出效果并有结束后的操作
 */

#import "ViewController.h"
#import "ADShineLabel.h"

@interface ViewController ()
@property (strong, nonatomic) ADShineLabel *shineLabel;
@property (strong, nonatomic) NSArray *textArray;
@property (assign, nonatomic) NSUInteger textIndex;
@property (strong, nonatomic) UIImageView *wallpaper1;
@property (strong, nonatomic) UIImageView *wallpaper2;
@end

@implementation ViewController

-(id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super initWithCoder:decoder]) {
        _textArray = @[
                       @"1.总而言之，这里会出现很长的一段数据来显示渐隐渐出的效果。总而言之，这里会出现很长的一段数据来显示渐隐渐出的效果。总而言之，这里会出现很长的一段数据来显示渐隐渐出的效果。",
                       @"2。总而言之，这里会出现很长的一段数据来显示渐隐渐出的效果。",
                       @"3：总而言之，这里会出现很长的一段数据来显示渐隐渐出的效果。总而言之，这里会出现很长的一段数据来显示渐隐渐出的效果。"
                       ];
        _textIndex = 0;

    }
    
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.wallpaper1 = ({
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"willStart"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = self.view.bounds;
        imageView;
    });
    [self.view addSubview:self.wallpaper1];
    
  
    self.wallpaper2 = ({
        UIImageView *imageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wallpaper2"]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = self.view.bounds;
        imageView.alpha = 0;
        imageView;
    });
    [self.view addSubview:self.wallpaper2];
    
    self.shineLabel = ({
        ADShineLabel *label = [[ADShineLabel alloc] initWithFrame:CGRectMake(16, 16, 320 - 32, CGRectGetHeight(self.view.bounds) - 16)];
        label.numberOfLines = 0;
        label.text = [self.textArray objectAtIndex:self.textIndex];
        //字体与大小设置
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0];
        
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        label.center = self.view.center;
        label;
    });
    [self.view addSubview:self.shineLabel];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.shineLabel shine];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.shineLabel.isVisible) {
        [self.shineLabel fadeOutWithCompletion:^{
            [self changeText];
            [UIView animateWithDuration:2.5 animations:^{
                if (self.wallpaper1.alpha > 0.1) {
                    self.wallpaper1.alpha = 0;
                    self.wallpaper2.alpha = 1;
                }
                else {
                    self.wallpaper1.alpha = 1;
                    self.wallpaper2.alpha = 0;
                }
            }];
            [self.shineLabel shine];
        }];
    }
    else {
        [self.shineLabel shine];
    }
}

- (void)changeText
{
    self.shineLabel.text = self.textArray[(++self.textIndex) % self.textArray.count];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
