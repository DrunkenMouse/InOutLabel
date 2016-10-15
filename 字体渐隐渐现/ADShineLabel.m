//
//  ADShineLabel.m
//  字体渐隐渐现
//
//  Created by 王奥东 on 16/9/27.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ADShineLabel.h"

@interface ADShineLabel()


@property (nonatomic, strong) NSMutableAttributedString *attributedString;
//基于随机生成数处理后的数值,暂未用到
//@property (nonatomic, strong) NSMutableArray *characterAnimationDurations;
//保存基于动画时间生成的随机数
@property (nonatomic, strong) NSMutableArray *characterAnimationDelays;
@property (nonatomic, strong) CADisplayLink *displaylink;
@property (nonatomic, assign) CFTimeInterval beginTime;
@property (nonatomic, assign) CFTimeInterval endTime;
//是否在渐出
@property (nonatomic, assign, getter= isFadedOut) BOOL fadedOut;
@property (nonatomic, copy) void (^completion)();

@end


@implementation ADShineLabel

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self commonInit];
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self commonInit];
    return self;
}



-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    [self commonInit];
    //设置文本内容
    [self setText:self.text];
    return self;
}

#pragma mark - 设置初始化内容
-(void)commonInit {
    // Defaults
    _shineDuration   = 2.5;
    _fadeoutDuration = 2.5;
    _autoStart       = NO;
    _fadedOut        = YES;
    self.textColor  = [UIColor whiteColor];
    
//    _characterAnimationDurations = [NSMutableArray array];
    _characterAnimationDelays    = [NSMutableArray array];
    
    //初始化时就设置帧动画
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAttributedString)];
    _displaylink.paused = YES;
    [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}


#pragma mark - 动画自动显示，并且window存在
-(void)didMoveToWindow {
    if (self.window != nil && self.autoStart) {
        [self shine];
    }
}

#pragma mark - 设置文本内容
-(void)setText:(NSString *)text {
    //设置文本内容时,调用可变字符串的set方法
    self.attributedText = [[NSAttributedString alloc] initWithString:text];
}

#pragma mark - 可变字符串文本的set方法重写
-(void)setAttributedText:(NSAttributedString *)attributedText {
    //将可变字符串的颜色变为0
    self.attributedString = [self initialAttributedStringFromAttributedString:attributedText];
    //再赋值给可变字符串文本
    [super setAttributedText:self.attributedString];
    //遍历字符串
    for (NSUInteger i = 0; i < attributedText.length; i++) {
        //根据动画时间随机生成一个数
        self.characterAnimationDelays[i] = @(arc4random_uniform(self.shineDuration / 2 * 100) / 100.0);
        
//        CGFloat remain = self.shineDuration - [self.characterAnimationDelays[i] floatValue];
        //随机生成数处理后的数值
//        self.characterAnimationDurations[i] = @(arc4random_uniform(remain * 100) / 100.0);
    }
}

#pragma mark - 动画开启并没有指定完成后的操作
- (void)shine
{
    
    [self shineWithCompletion:NULL];
}

#pragma mark - 动画开启并指定完成后的操作
- (void)shineWithCompletion:(void (^)())completion
{
    //帧动画没有开启 并且 正在开启淡出效果
    if (!self.isShining && self.isFadedOut) {
        //保存操作,并设置淡出效果为NO
        self.completion = completion;
        self.fadedOut = NO;
        //开启动画
        [self startAnimationWithDuration:self.shineDuration];
    }
}

#pragma mark - 开启淡出效果但没有结束后的操作
- (void)fadeOut
{
    [self fadeOutWithCompletion:NULL];
}

#pragma mark - 开启淡出效果并有结束后的操作
- (void)fadeOutWithCompletion:(void (^)())completion
{
    //帧动画没有开启 并且 没有开启淡出效果
    if (!self.isShining && !self.isFadedOut) {
        //保存操作,并设置淡出效果为YES
        self.completion = completion;
        self.fadedOut = YES;
        //开启动画
        [self startAnimationWithDuration:self.fadeoutDuration];
    }
}

#pragma mark - 帧动画是否开启
- (BOOL)isShining
{
    //如果帧动画暂停就是未开启
    //反之则开启
    return !self.displaylink.isPaused;
}

#pragma mark - 是否未淡出
- (BOOL)isVisible
{
    return  self.isFadedOut == NO;
}


#pragma mark - Private methods

#pragma mark - 开启动画
- (void)startAnimationWithDuration:(CFTimeInterval)duration
{
    self.beginTime = CACurrentMediaTime();
    self.endTime = self.beginTime + self.shineDuration;
    self.displaylink.paused = NO;
}

#pragma mark - 帧动画 - 通过透明度更新可变字符串
- (void)updateAttributedString
{
    //获取当前时间
    CFTimeInterval now = CACurrentMediaTime();

    //遍历可变字符串
    for (NSUInteger i = 0;  i < self.attributedString.length; i++) {
        //whitespaceAndNewlineCharacterSet 去除回车和空格
        //这里的用意是 跳过可变字符串的空格、回车和tab
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.attributedString.string characterAtIndex:i]]) {
            continue;
        }
        //  不需要长久的有效
        //  NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
        [self.attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:NSMakeRange(i, 1) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id  value, NSRange range, BOOL *stop) {
            //获取颜色的透明度
            CGFloat currentAlpha = CGColorGetAlpha([(UIColor *)value CGColor]);
            //是否应该更新透明度
            //如果 当前是淡出效果并且透明度大于0
            //或 当前不是淡出效果并且透明度小于1
            //或 当前时间 - 动画开始时间 >= 基于淡出效果而生成的一个随机时间
            BOOL shouldUpdateAlpha = (self.isFadedOut && currentAlpha > 0) || (!self.isFadedOut && currentAlpha < 1) || (now - self.beginTime) >= [self.characterAnimationDelays[i] floatValue];
            
            //不应该更新就直接返回
            if (!shouldUpdateAlpha) {
                return;
            }
           
            //应该更新则获取所需透明度值 : 当前时间 - 开始时间 - 基于淡出效果而生成的一个随机时间
            CGFloat percentage = (now - self.beginTime - [self.characterAnimationDelays[i] floatValue]);
            //如果是淡出状态就获取 1 - percentage
            if (self.isFadedOut) {
                percentage = 1 - percentage;
            }
            //改变淡出效果
           UIColor *color = [self.textColor colorWithAlphaComponent:percentage];
            //给字符添加效果颜色
           [self.attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
            
        }];
    }
    //设置可变字符串的内容
    [super setAttributedText:self.attributedString];
    //如果当前时间超过动画结束时间
    //暂停帧动画，执行结束操作
    if (now > self.endTime) {
        self.displaylink.paused = YES;
        if (self.completion) {
            self.completion();
        }
    }
    
}

#pragma mark - 将可变字符串的颜色变为0
-(NSMutableAttributedString *)initialAttributedStringFromAttributedString:(NSAttributedString *)attributedString {
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    UIColor *color = [self.textColor colorWithAlphaComponent:0];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, mutableAttributedString.length)];
    //返回copy后的可变字符串
    return mutableAttributedString;
}



@end
