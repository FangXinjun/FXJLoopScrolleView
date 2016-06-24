//
//  FXJLoopScrollView.h
//
//  Created by myApplePro01 on 16/6/19.
//  Copyright © 2016年 LSH. All rights reserved.
//

#import <UIKit/UIKit.h>

/** pageControl样式 */
typedef NS_ENUM(NSUInteger, PageContolStyle)
{
    PageContolStyleNormal = 0, // 默认
    PageContolStyleAnimated,   // 圆形背景
};

/** pageControl的显示位置 */
typedef NS_ENUM(NSUInteger, PageControlPosition)
{
    PageControlPositionNone,           //默认值PositionBottomCenter
    PageControlPositionHide,           //隐藏
    PageControlPositionTopCenter,      //中上
    PageControlPositionBottomLeft,     //左下
    PageControlPositionBottomCenter,   //中下
    PageControlPositionBottomRight     //右下
};

typedef UIImage*(^DownloadImagesBlock)(NSString *urlStr);

@interface FXJLoopScrollView : UIView
/** 所有图片或者图片地址 */
@property (nonatomic, strong) NSArray             *imageArray;
/** 所有title地址 */
@property (nonatomic, strong) NSArray             *titleArray;
/** 默认为13号字体 */
@property (nonatomic, strong) UIFont              *titleFont;
/** 默认为黑色 */
@property (nonatomic, strong) UIColor             *titleLabelTextColor;
/** 是否隐藏标题 */
@property (nonatomic, assign) BOOL                titleIsHiden;
/** 每一页停留时间 */
@property (nonatomic, assign) NSTimeInterval      remainTime;
/** pageControl样式 */
@property (nonatomic, assign) PageContolStyle     pageStyle;
/** pageControl的位置 */
@property (nonatomic, assign) PageControlPosition pageControlPosition;
/** 图片点击返回index */
@property (nonatomic, copy) void                  (^ClickImageViewBlock)(NSInteger index);

/**
 *  构造方法
 *
 *  @param imageArray 图片数组(包括图片或URL)
 *  @param titleArray 图片标题数组
 *  @param placeholderImage 下载的占位图
 *
 */
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray placeholderImage:(UIImage *)placeholderImage;
+ (instancetype)loopScrollViewWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray placeholderImage:(UIImage *)placeholderImage;

/**
 *  设置分页控件指示器的图片
 *  两个图片都不能为空，否则设置无效
 *  不设置则为系统默认
 *
 *  @param pageImage    其他页码的图片
 *  @param currentImage 当前页码的图片
 */
- (void)setPageImage:(UIImage *)pageImage andCurrentImage:(UIImage *)currentImage;
/**
 *  设置分页控件指示器的颜色
 *  不设置则为系统默认
 *
 *  @param color        其他页码的颜色 (PageContolStyleAnimated时 使用当前颜色)
 *  @param currentColor 当前页码的颜色
 */
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor;
/**
 *  清除沙盒中的图片缓存
 */
- (void)clearDiskCache;

@end

@interface FXJAnimateView : UIView

@property (nonatomic, strong) UIColor *pageColor;

- (void)changeActivityState:(BOOL)active;

@end

