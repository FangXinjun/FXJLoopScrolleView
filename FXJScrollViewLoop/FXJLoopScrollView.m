//
//  FXJBackgroundView.m
//  FXJScrollViewLoop
//
//  Created by myApplePro01 on 16/6/19.
//  Copyright © 2016年 LSH. All rights reserved.
//

#import "FXJLoopScrollView.h"

#define Spacing 10
#define DEFAULTTIME 2
#define ScrollViewHeight       self.scrollView.frame.size.height
#define ScrollViewWith         self.scrollView.frame.size.width
#define KAnimateViewWidth      10


@interface FXJLoopScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView       *scrollView;//loop

@property (nonatomic, strong) UIImageView        *currImageView;

@property (nonatomic, strong) UIImageView        *otherImageView;

@property (nonatomic, assign) NSInteger          currIndex;  //当前显示图片的索引

@property (nonatomic, strong) NSMutableArray     *images; //所有图片数组

@property (nonatomic, strong) NSOperationQueue   *queue;

@property (nonatomic, assign) NSInteger          nextIndex; //将要显示图片的索引

@property (nonatomic, strong) UILabel           *titleLabel;

@property (nonatomic, strong) UIPageControl     *pageControl;

@property (nonatomic, strong) NSTimer           *myTimer;

@property (nonatomic, copy) DownloadImagesBlock downloadImagesBlock;

@property (nonatomic, assign) CGSize            pagImageSize;

@property (strong, nonatomic) NSMutableArray    *animaateViewsArray;// 动画view数组

@property (nonatomic, strong) FXJAnimateView     *currentAnimationView;

@property (nonatomic, strong) UIColor            *pageColor; // 动画view圆圈的颜色

@property (nonatomic, strong) UIImage            *placeholderImage; // 占位图片 

@end

@implementation FXJLoopScrollView


+ (void)initialize {
    NSString *cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FXJCarousel"];
    BOOL isDir = NO;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    if (!isExists || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray placeholderImage:(UIImage *)placeholderImage{
    if (self = [super initWithFrame:frame]) {
        self.placeholderImage = placeholderImage;
        self.imageArray = imageArray;
        self.titleArray = titleArray;
        [self addSubview:self.scrollView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.pageControl];
    }
    return self;
}

+ (instancetype)loopScrollViewWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray placeholderImage:(UIImage *)placeholderImage{
    return [[FXJLoopScrollView alloc] initWithFrame:frame imageArray:imageArray titleArray:titleArray placeholderImage:placeholderImage];
}
//- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSArray *)imageArray titleArray:(NSArray *)titleArray placeholderImage:(UIImage *)placeholderImage downloadImagesBlock:(DownloadImagesBlock)downloadImagesBlock{
//
//    if (self = [super initWithFrame:frame]) {
//        self.downloadImagesBlock = downloadImagesBlock;
//        self.placeholderImage = placeholderImage;
//        self.imageArray = imageArray;
//        self.titleArray = titleArray;
//        [self addSubview:self.scrollView];
//        [self addSubview:self.titleLabel];
//        [self addSubview:self.pageControl];
//    }
//    
//    return self;
//
//}

#pragma mark 设置相关
-(void)setClickImageViewBlock:(void (^)(NSInteger))ClickImageViewBlock{
    _ClickImageViewBlock = ClickImageViewBlock;
}

- (void)setPageStyle:(PageContolStyle)pageStyle{
    _pageStyle = pageStyle;
    switch (self.pageStyle) {
        case PageContolStyleAnimated:
            [self.pageControl removeFromSuperview];
            [self addanimateView];
            break;
        case PageContolStyleNormal:
            break;
        default:
            break;
    }
}

- (void)setTitleArray:(NSArray *)titleArray{
    _titleArray = titleArray;
    if (titleArray.count <= 0 ) {
        self.titleLabel.hidden = YES;
        return;
    }
    //如果描述的个数与图片个数不一致，则补空字符串
    if (titleArray && titleArray.count > 0) {
        if (titleArray.count < _images.count) {
            NSMutableArray *describes = [NSMutableArray arrayWithArray:titleArray];
            for (NSInteger i = titleArray.count; i < _images.count; i++) {
                [describes addObject:@""];
            }
            _titleArray = describes;
        }
        self.titleLabel.hidden = NO;
        _titleLabel.text = _titleArray[_currIndex];
    }
}

- (void)setImageArray:(NSArray *)imageArray{
    [self clearDiskCache];
    if (!imageArray.count) return;  // 不存在就返回
    _imageArray = imageArray;
    
    _images = [NSMutableArray array];
    
    for (int i = 0; i < imageArray.count; i++) {
        if ([imageArray[i] isKindOfClass:[UIImage class]]) {
            
            [_images addObject:imageArray[i]];
        }else if ([imageArray[i] isKindOfClass:[NSString class]]){
            
            [_images addObject:_placeholderImage ? _placeholderImage : [[UIImage alloc] init]];
            // 下载图片
            [self downloadImages:i];
        }
    }
    
    if (_currIndex >= _images.count) _currIndex = _images.count - 1;
    self.currImageView.image = _images[_currIndex];
    self.titleLabel.text = _titleArray[_currIndex];
    self.pageControl.numberOfPages = _images.count;
//    [self layoutSubviews];

}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleIsHiden:(BOOL )titleIsHiden{
    _titleIsHiden = titleIsHiden;
    _titleLabel.hidden = titleIsHiden;
}

// 指示器图片
- (void)setPageImage:(UIImage *)pageImage andCurrentImage:(UIImage *)currentImage {
    if (!pageImage || !currentImage) return;
    self.pagImageSize = pageImage.size;
    [self.pageControl setValue:currentImage forKey:@"_currentPageImage"];
    [self.pageControl setValue:pageImage forKey:@"_pageImage"];
}

// 指示器颜色
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor {
    _pageColor = color;
    _pageControl.pageIndicatorTintColor = color;
    _pageControl.currentPageIndicatorTintColor = currentColor;
}

- (void)setRemainTime:(NSTimeInterval)remainTime
{
    _remainTime = remainTime;
    [self startTimer];
}

- (void)setScrollViewContentSize {
    if (_images.count > 1) {
        self.scrollView.contentSize = CGSizeMake(ScrollViewWith * 3, 0);
        self.scrollView.contentOffset = CGPointMake(ScrollViewWith , 0);
        self.currImageView.frame = CGRectMake(ScrollViewWith, 0, ScrollViewWith, ScrollViewHeight);
        
        [self startTimer];
    } else {
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, ScrollViewWith, ScrollViewHeight);
    }
    self.currImageView.image = [self.images firstObject];
}

// pageControl的位置
- (void)setPageControlPosition {
    
    if (_pageControlPosition == PageControlPositionHide) {
        [self.pageControl removeFromSuperview];
        return;
    }    
    CGSize size;
    if (_pagImageSize.width == 0) {//没有设置图片
        size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
        size.height = 20;
    } else {//设置图片了
        size = CGSizeMake(_pagImageSize.width * (_pageControl.numberOfPages * 2 - 1), _pagImageSize.height);
    }
    _pageControl.frame = CGRectMake(0, 0, size.width, size.height);
    
    if (_pageControlPosition == PageControlPositionNone || _pageControlPosition == PageControlPositionBottomCenter){
        _pageControl.center = CGPointMake(ScrollViewWith * 0.5, ScrollViewHeight - (_titleLabel.hidden? 10 : 30));
    }
    else if (_pageControlPosition == PageControlPositionTopCenter){
        _pageControl.center = CGPointMake(ScrollViewWith * 0.5, size.height * 0.5);
    }
    else if (_pageControlPosition == PageControlPositionBottomLeft){
        _pageControl.frame = CGRectMake(Spacing, ScrollViewHeight - (_titleLabel.hidden? size.height : size.height + 20), size.width, size.height);
    }
    else{
        _pageControl.frame = CGRectMake(ScrollViewWith - Spacing - size.width, ScrollViewHeight - (_titleLabel.hidden? size.height : size.height + 20), size.width, size.height);
    }

}
// 设置圆圈的frame
- (void)setPageControlPosition:(PageControlPosition)pageControlPosition{
    _pageControlPosition = pageControlPosition;
    if (self.pageStyle == PageContolStyleAnimated) {
        for (int a = 0; a < self.animaateViewsArray.count; a++) {
            UIView *dot = self.animaateViewsArray[a];
            [self updateDotFrame:dot atIndex:a];
        }
    }else {
    
    
    }

}

#pragma mark 图片下载
- (void)downloadImages:(int)index {
    
    NSString *key = _imageArray[index];
//    if (_downloadImagesBlock) { // 用户自己实现了图片下载的代码方法
//        UIImage *image = _downloadImagesBlock(key);
//        if (image) {
//            self.images[index] = image;
//            if (_currIndex == index) {
//                [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
//            }
//        }
//    }else
    { // 图片下载加本地缓存
    
        NSString *path = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FXJCarousel"] stringByAppendingPathComponent:[key lastPathComponent]];
        NSData *data = [NSData dataWithContentsOfFile:path];
        if (data) {
            _images[index] = [UIImage imageWithData:data];
            return;
        }
        NSBlockOperation *download = [NSBlockOperation blockOperationWithBlock:^{
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:key]];
            if (!data) return;
            UIImage *image = [UIImage imageWithData:data];
            //取到的data有可能不是图片
            if (image) {
                self.images[index] = image;
                //如果下载的图片为当前要显示的图片，直接到主线程给imageView赋值，否则要等到下一轮才会显示
                if (_currIndex == index) {
                    [_currImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                }
                BOOL isSuccess= [data writeToFile:path atomically:YES];
                if (isSuccess) {
                    NSLog(@"写入成功");
                }
            }
        }];
        [self.queue addOperation:download];
    }
}
#pragma mark  定时器相关
- (void)startTimer {

    if (_images.count <= 1) return;

    if (self.myTimer) [self stopTimer];
    self.myTimer = [NSTimer timerWithTimeInterval:_remainTime ? _remainTime : DEFAULTTIME target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.myTimer invalidate];
    self.myTimer = nil;
}

- (void)nextPage {
    [self.scrollView setContentOffset:CGPointMake(ScrollViewWith * 2, 0) animated:YES];
}
#pragma mark  布局
- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    _titleLabel.frame = CGRectMake(0, ScrollViewHeight - 20, ScrollViewWith, 20);
    [self setPageControlPosition];
    [self setScrollViewContentSize];
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if (self.pageStyle == PageContolStyleAnimated) {
        [self changeAnimationViewCurrentPageWithOffset:offsetX];
    }else if (self.pageStyle == PageContolStyleNormal){
        [self changeCurrentPageWithOffset:offsetX];
    }
        
    if (offsetX < ScrollViewWith) {//right
        self.otherImageView.frame = CGRectMake(0, 0, ScrollViewWith, ScrollViewHeight);
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) {
            self.nextIndex = _images.count - 1; // 最后一个图片
        }
        if (offsetX <= 0) {
            [self changeToNext];
        }
    } else if (offsetX > ScrollViewWith ){//left
        self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, ScrollViewWith, ScrollViewHeight);
        self.nextIndex = (self.currIndex + 1) % _images.count;
        if (offsetX >= ScrollViewWith*2) {
            [self changeToNext];
        }
    }
    self.otherImageView.image = self.images[self.nextIndex];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}

- (void)changeToNext {
    self.currImageView.image = self.otherImageView.image;
    self.scrollView.contentOffset = CGPointMake(ScrollViewWith, 0);
    self.currIndex = self.nextIndex;
    self.titleLabel.text = self.titleArray[self.currIndex];
    if (self.pageStyle == PageContolStyleNormal) {
        self.pageControl.currentPage = self.currIndex;
    }
}

#pragma mark 当图片滚动过半时就修改当前页码
- (void)changeCurrentPageWithOffset:(CGFloat)offsetX {
    if (offsetX < ScrollViewWith * 0.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) index = self.images.count - 1;
        _pageControl.currentPage = index;
    } else if (offsetX > ScrollViewWith * 1.5){
        _pageControl.currentPage = (self.currIndex + 1) % self.images.count;
    } else {
        _pageControl.currentPage = self.currIndex;
    }
}

- (void)changeAnimationViewCurrentPageWithOffset:(CGFloat)offsetX {
    
    if (offsetX < ScrollViewWith * 0.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) index = self.images.count - 1;
        [self AnimationViewChangStatusWithIndex:index];
    } else if (offsetX > ScrollViewWith * 1.5){
        NSInteger index = (self.currIndex + 1) % self.images.count;
        [self AnimationViewChangStatusWithIndex:index];
    } else {
        if (offsetX == ScrollViewWith) return;
        [self AnimationViewChangStatusWithIndex:self.currIndex];
    }
}

- (void)AnimationViewChangStatusWithIndex:(NSInteger)index{
    FXJAnimateView *animationView = self.animaateViewsArray[index];
    if (self.currentAnimationView.tag == animationView.tag) {
        return;
    }else{
        [animationView changeActivityState:YES];
        [self.currentAnimationView changeActivityState:NO];
        self.currentAnimationView = animationView;
    }
}

// 点击图片
- (void)imageClick {
    if (_ClickImageViewBlock) {
        self.ClickImageViewBlock(self.currIndex);
    }
}

#pragma mark 添加动画view
- (void) addanimateView
{
    if (self.imageArray.count == 1) return;
    for (int a = 0; a < self.imageArray.count; a++) {
        UIView *dot = [self generateDotView];
        dot.tag = a+1;
        [self.animaateViewsArray addObject:dot];
        [self updateDotFrame:dot atIndex:a];
    }
    FXJAnimateView *firestView = [self.animaateViewsArray firstObject];
    [firestView changeActivityState:YES];

}

- (UIView *)generateDotView
{
    FXJAnimateView *dotView = [[FXJAnimateView alloc] initWithFrame:CGRectMake(0, 0, KAnimateViewWidth, KAnimateViewWidth)];
    if (self.pageColor) {
        dotView.pageColor = self.pageColor;
    }
    if (dotView) {
        [self addSubview:dotView];
    }
    dotView.userInteractionEnabled = YES;
    return dotView;
}

- (void)updateDotFrame:(UIView *)dot atIndex:(NSInteger)index
{
    if (_pageControlPosition == PageControlPositionHide) {
        for (UIView *view in self.animaateViewsArray) {
            [view removeFromSuperview];
        }
        return;
    }
    
    CGFloat beginX = 0;
    CGFloat beginY = 0;
    if (_pageControlPosition == PageControlPositionNone || _pageControlPosition == PageControlPositionBottomCenter){
        beginX = (self.frame.size.width - ((KAnimateViewWidth + Spacing) * self.imageArray.count))/2;
        beginY = self.frame.size.height - (_titleLabel.hidden ? 30 : _titleLabel.frame.size.height + 30);
    }
    else if (_pageControlPosition == PageControlPositionTopCenter){
        beginX = (self.frame.size.width - ((KAnimateViewWidth + Spacing) * self.imageArray.count))/2;
        
    }
    else if (_pageControlPosition == PageControlPositionBottomLeft){
        beginX = Spacing;
        beginY = self.frame.size.height - (_titleLabel.hidden ? 30 : _titleLabel.frame.size.height + 30);
    }
    else if (_pageControlPosition == PageControlPositionBottomRight){
        beginX = (self.frame.size.width - ((KAnimateViewWidth + Spacing) * self.imageArray.count));
        beginY = self.frame.size.height - (_titleLabel.hidden ? 30 : _titleLabel.frame.size.height + 30);
    }
    
    CGFloat x = (KAnimateViewWidth + Spacing) * index + beginX;
    dot.frame = CGRectMake(x, beginY, KAnimateViewWidth, KAnimateViewWidth);

}

#pragma mark  懒加载
- (NSMutableArray *)animaateViewsArray{
    if (!_animaateViewsArray) {
        _animaateViewsArray = [NSMutableArray array];
    }
    return _animaateViewsArray;
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)]];
        _currImageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_currImageView];
        _otherImageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_otherImageView];
    }
    return _scrollView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        //        _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    }
    return _pageControl;
}

#pragma mark 清除沙盒中的图片缓存
- (void)clearDiskCache {
    NSString *cache = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FXJCarousel"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cache error:NULL];
    for (NSString *fileName in contents) {
        [[NSFileManager defaultManager] removeItemAtPath:[cache stringByAppendingPathComponent:fileName] error:nil];
    }
}
@end

#pragma mark FXJAnimateView
@implementation FXJAnimateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)setPageColor:(UIColor *)pageColor{
    _pageColor = pageColor;
    self.layer.borderColor  = pageColor.CGColor;
}

- (void)initialization
{
    _pageColor = [UIColor whiteColor];
    self.backgroundColor    = [UIColor clearColor];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2;
    self.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.layer.borderWidth  = 2;
}


- (void)changeActivityState:(BOOL)active
{
    if (active) {
        self.backgroundColor = _pageColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
