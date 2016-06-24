# FXJLoopScrolleView
俩个imageView实现ScrolleView无线循环
/**
 *  构造方法
 *
 *  @param imageArray 图片数组(包括图片或URL)
 *  @param titleArray 图片标题数组
 *  @param placeholderImage 下载的占位图
 *
 */
    self.ScrollView = [[FXJLoopScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width - 100) imageArray:imageArray titleArray:titleArray placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    /** 图片点击返回index */
    [self.ScrollView setClickImageViewBlock:^(NSInteger index) {
        NSLog(@"%zd",index);
    }];

/**
 *  设置分页控件指示器的图片
 *  两个图片都不能为空，否则设置无效
 *  不设置则为系统默认
 *
 *  @param pageImage    其他页码的图片
 *  @param currentImage 当前页码的图片
 */
    [self.ScrollView setPageImage:[UIImage imageNamed:@"pagImage"] andCurrentImage:[UIImage imageNamed:@"currentImage"]];

/**
 *  设置分页控件指示器的颜色
 *  不设置则为系统默认
 *
 *  @param color        其他页码的颜色 (PageContolStyleAnimated时 使用当前颜色)
 *  @param currentColor 当前页码的颜色
 */
    [self.ScrollView setPageColor:[UIColor purpleColor] andCurrentPageColor:[UIColor orangeColor]];
    /** 标题颜色 默认为黑色 */
    self.ScrollView.titleLabelTextColor = [UIColor redColor];
    
    self.ScrollView.titleFont = [UIFont systemFontOfSize:12];
    
    /** 每一页停留时间 */
    self.ScrollView.remainTime = 1.5;
    /** pageControl样式 */
     默认
    PageContolStyleNormal = 0,
     圆形背景
    PageContolStyleAnimated,
    self.ScrollView.pageStyle = PageContolStyleAnimated;
    
    self.ScrollView.titleIsHiden = YES;
    
    /** pageControl的显示位置 */
    PageControlPositionNone,           //默认值PositionBottomCenter
    PageControlPositionHide,           //隐藏
    PageControlPositionTopCenter,      //中上
    PageControlPositionBottomLeft,     //左下
    PageControlPositionBottomCenter,   //中下
    PageControlPositionBottomRight     //右下
    self.ScrollView.pageControlPosition = PageControlPositionHide;
    
    [self.view addSubview:_ScrollView];
