//
//  DLBannerView.m
//  DLBannerView
//
//  Created by DL on 2021/9/13.
//

#import "DLBannerView.h"
#import "DLPageControl.h"

#define kBannerViewInitialPageControlDotSize CGSizeMake(8, 8)

@interface DLBannerView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView; // 显示图片的collectionView
@property (nonatomic, strong) UIControl *pageControl;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, assign) NSInteger totalItemsCount;

@end

@implementation DLBannerView
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialization];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<DLBannerViewDelegate>)delegate
{
    DLBannerView *bannerView = [[self.class alloc] initWithFrame:frame];
    bannerView.delegate = delegate;
    bannerView.autoScrollTimeInterval = 3;
    return bannerView;
}



- (void)initialization
{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];

    _autoScroll = YES;
    _autoScrollTimeInterval = 2.0;
    _infiniteLoop = YES;
    _pageControlStyle = DLBannerPageContolStyleSystemic;
    _pageControlAliment = UIControlContentHorizontalAlignmentCenter;
    _pageControlDotSize = kBannerViewInitialPageControlDotSize;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _hidesForSinglePage = YES;
}


#pragma mark - public actions
- (void)adjustDispayEffectWhenControllerViewWillAppera
{
    long targetIndex = [self currentIndex];
    if (targetIndex < _totalItemsCount) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}
- (void)scrollToBannerItemIndex:(NSInteger)index{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
    if (0 == _totalItemsCount) return;
    
    [self scrollToIndex:(int)index];
    
    if (self.autoScroll) {
        [self setupTimer];
    }
}
- (void)reloadData
{
    [self invalidateTimer];
    self.imageCount = [self.delegate numberOfItemForBannerView:self];
    _totalItemsCount = self.infiniteLoop ? self.imageCount * 10000 : self.imageCount;
    if (_imageCount > 1) { // 由于 !=1 包含count == 0等情况
        self.collectionView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.collectionView.scrollEnabled = NO;
        [self invalidateTimer];
    }
    
    [self resetPageControl];
    [self.collectionView reloadData];
}

- (void)disableScrollGesture {
    self.collectionView.canCancelContentTouches = NO;
    for (UIGestureRecognizer *gesture in self.collectionView.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.collectionView removeGestureRecognizer:gesture];
        }
    }
}

#pragma mark - actions

- (void)setupTimer
{
    [self invalidateTimer]; // 创建定时器前先销毁定时器
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)resetPageControl
{
    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
        
    if ((self.imageCount == 1 && self.hidesForSinglePage) || self.imageCount == 0) return;
    
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
    
    switch (self.pageControlStyle) {
        case DLBannerPageContolStyleAnimated:
        {
            DLPageControl *pageControl = [[DLPageControl alloc] init];
            pageControl.numberOfPages = self.imageCount;
            pageControl.currentDotColor = self.currentPageDotColor;
            pageControl.dotColor = self.pageDotColor;
            pageControl.dotSize = self.pageControlDotSize;
            pageControl.currentDotSize = self.pageControlDotSize;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        case DLBannerPageContolStyleSystemic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imageCount;
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        default:
            _pageControl = nil;
            break;
    }
    
    // 重设pagecontroldot图片
    if (self.currentPageDotImage) {
        self.currentPageDotImage = self.currentPageDotImage;
    }
    if (self.pageDotImage) {
        self.pageDotImage = self.pageDotImage;
    }
}


- (void)automaticScroll
{
    if (0 == _totalItemsCount) return;
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(int)targetIndex
{
    if (targetIndex >= _totalItemsCount) {
        return;
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (int)currentIndex
{
    if (_collectionView.frame.size.width == 0 || _collectionView.frame.size.height == 0) {
        return 0;
    }
    int index = 0;
    if (_flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_collectionView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    } else {
        index = (_collectionView.contentOffset.y + _flowLayout.itemSize.height * 0.5) / _flowLayout.itemSize.height;
    }
    
    return MAX(0, index);
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index
{
    return (int)index % self.imageCount;
}

#pragma mark - ReWrite

- (void)layoutSubviews
{
    self.delegate = self.delegate;
    
    [super layoutSubviews];
    
    _flowLayout.itemSize = self.frame.size;
    
    _collectionView.frame = self.bounds;
    if (_collectionView.contentOffset.x == 0 &&  _totalItemsCount) {
        int targetIndex = 0;
        if (self.infiniteLoop) {
            targetIndex = _totalItemsCount * 0.5;
        }else{
            targetIndex = 0;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    [self.pageControl sizeToFit];
    CGSize size = self.pageControl.frame.size;
    CGFloat x = (self.frame.size.width - size.width) * 0.5;
    if (self.pageControlAliment == UIControlContentHorizontalAlignmentLeft) {
        x = 10;
    } else if (self.pageControlAliment == UIControlContentHorizontalAlignmentRight) {
        x = self.collectionView.frame.size.width - size.width - 10;
    }
    CGFloat y = self.collectionView.frame.size.height - size.height;
    CGRect pageControlFrame = CGRectMake(x, y, size.width, size.height);
    pageControlFrame.origin.x -= self.pageControlOffsetX;
    pageControlFrame.origin.y -= self.pageControlOffsetY;
    self.pageControl.frame = pageControlFrame;
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(willRegisterCustomBannerItemCellClassForBannerView:)]) {
        Class class = [self.delegate willRegisterCustomBannerItemCellClassForBannerView:self];
        if (class) {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(class) forIndexPath:indexPath];
            if ([self.delegate respondsToSelector:@selector(bannerView:willDisplayCustomBannerItemCell:forItemAtIndex:)]) {
                [self.delegate bannerView:self willDisplayCustomBannerItemCell:cell forItemAtIndex:itemIndex];
            }
            return cell;
        }
    }
    
    DLBannerViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(DLBannerViewItemCell.class) forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(bannerView:willDisplayBannerItemCell:forItemAtIndex:)]) {
        [self.delegate bannerView:self willDisplayBannerItemCell:cell forItemAtIndex:itemIndex];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(bannerView:didSelectBannerItemAtIndex:)]) {
        [self.delegate bannerView:self didSelectBannerItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.imageCount) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.pageControl isKindOfClass:[DLPageControl class]]) {
        DLPageControl *pageControl = (DLPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:self.collectionView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!self.imageCount) return; // 解决清除timer时偶尔会出现的问题
    int itemIndex = [self currentIndex];
    int indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.delegate respondsToSelector:@selector(bannerView:bannerItemDidScrollToIndex:)]) {
        [self.delegate bannerView:self bannerItemDidScrollToIndex:indexOnPageControl];
    }
}

#pragma mark - Setter & Getter

- (void)setDelegate:(id<DLBannerViewDelegate>)delegate
{
    _delegate = delegate;
    if ([self.delegate respondsToSelector:@selector(willRegisterCustomBannerItemCellClassForBannerView:)]) {
        Class class = [self.delegate willRegisterCustomBannerItemCellClassForBannerView:self];
        [self.collectionView registerClass:class forCellWithReuseIdentifier:NSStringFromClass(class)];
    }
}

- (void)setPageControlStyle:(DLBannerPageContolStyle)pageControlStyle
{
    _pageControlStyle = pageControlStyle;
    [self resetPageControl];
}





- (void)setPageControlDotSize:(CGSize)pageControlDotSize
{
    _pageControlDotSize = pageControlDotSize;
    [self resetPageControl];
    if ([self.pageControl isKindOfClass:[DLPageControl class]]) {
        DLPageControl *pageContol = (DLPageControl *)_pageControl;
        pageContol.dotSize = pageControlDotSize;
    }
}

- (void)setPageDotColor:(UIColor *)pageDotColor
{
    _pageDotColor = pageDotColor;
    
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor
{
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[DLPageControl class]]) {
        DLPageControl *pageControl = (DLPageControl *)_pageControl;
        pageControl.dotColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
    
}



- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage
{
    _currentPageDotImage = currentPageDotImage;
    
    if (self.pageControlStyle != DLBannerPageContolStyleAnimated) {
        self.pageControlStyle = DLBannerPageContolStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage
{
    _pageDotImage = pageDotImage;
    
    if (self.pageControlStyle != DLBannerPageContolStyleAnimated) {
        self.pageControlStyle = DLBannerPageContolStyleAnimated;
    }
    
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot
{
    if (!image || !self.pageControl) return;
    
    if ([self.pageControl isKindOfClass:[DLPageControl class]]) {
        DLPageControl *pageControl = (DLPageControl *)_pageControl;
        if (isCurrentPageDot) {
            pageControl.currentDotImage = image;
        } else {
            pageControl.dotImage = image;
        }
    }
}

- (void)setInfiniteLoop:(BOOL)infiniteLoop
{
    _infiniteLoop = infiniteLoop;
}

-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [self invalidateTimer];
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    _flowLayout.scrollDirection = scrollDirection;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    [self setAutoScroll:self.autoScroll];
}


- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[DLBannerViewItemCell class] forCellWithReuseIdentifier:NSStringFromClass(DLBannerViewItemCell.class)];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.scrollsToTop = NO;
    }
    return _collectionView;
}

@end
