//
//  DLPageControl.m
//  DLBannerView
//
//  Created by DL on 2021/9/13.
//

#import "DLPageControl.h"

@interface DLPageControl ()
@property (strong, nonatomic) NSMutableArray *dots;
@end

@implementation DLPageControl
- (id)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    
    return self;
}
- (void)initialization
{
    self.spacingBetweenDots     = 8;
    self.numberOfPages          = 0;
    self.currentPage            = 0;
    self.hidesForSinglePage     = NO;
    self.shouldResizeFromCenter = YES;
}

#pragma mark - Touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch.view != self) {
        NSInteger index = [self.dots indexOfObject:touch.view];
        if ([self.delegate respondsToSelector:@selector(pageControl:didSelectPageDotAtIndex:)]) {
            [self.delegate pageControl:self didSelectPageDotAtIndex:index];
        }
    }
}

#pragma mark - Layout
- (void)sizeToFit
{
    CGPoint center = self.center;
    [super sizeToFit];
    if (_shouldResizeFromCenter) {
        self.center = center;
    }
    [self resetDotViews];
}
- (CGSize)sizeThatFits:(CGSize)size
{
    return [self sizeForNumberOfPages:self.numberOfPages];
}

- (void)updateDotsFrame
{
    if (self.numberOfPages == 0) {
        return;
    }
    CGFloat pointX = 0,pointY = 0;
    for (NSInteger i = 0; i < self.numberOfPages; i++) {
        UIView *dot;
        if (i < self.dots.count) {
            dot = [self.dots objectAtIndex:i];
        } else {
            dot = [self generateDotView];
        }
        if (i == self.currentPage) {
            pointY = (self.frame.size.height-self.currentDotSize.height)/2;
            dot.frame = CGRectMake(pointX, pointY, self.currentDotSize.width, self.currentDotSize.height);
        }else {
            pointY = (self.frame.size.height-self.dotSize.height)/2;
            dot.frame = CGRectMake(pointX, pointY, self.dotSize.width, self.dotSize.height);
        }
        pointX = CGRectGetMaxX(dot.frame)+self.spacingBetweenDots;
        [self changeActivity:i == self.currentPage atIndex:i];
        
    }
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
    CGFloat height = MAX(self.dotSize.height, self.currentDotSize.height);
    return CGSizeMake((self.dotSize.width + self.spacingBetweenDots) * (pageCount - 1) + self.currentDotSize.width, height + 20);
}


#pragma mark - Utils
- (UIView *)generateDotView
{
    UIImageView *dotView = [[UIImageView alloc] initWithFrame:CGRectZero];
    dotView.clipsToBounds = YES;
    dotView.userInteractionEnabled = YES;
    [self addSubview:dotView];
    [self.dots addObject:dotView];
    return dotView;
}

- (void)changeActivity:(BOOL)active atIndex:(NSInteger)index
{
    UIImageView *dotView = [self.dots objectAtIndex:index];
    dotView.backgroundColor = active ? self.currentDotColor : self.dotColor;
    dotView.image = active ? self.currentDotImage : self.dotImage;
    dotView.layer.cornerRadius = CGRectGetHeight(dotView.frame)/2;
}

- (void)resetDotViews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.dots removeAllObjects];
    [self updateDotsFrame];
}

- (void)hideForSinglePage
{
    if (self.dots.count == 1 && self.hidesForSinglePage) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
}

#pragma mark - Setters
- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    _numberOfPages = numberOfPages;
    
    // Update dot position to fit new number of pages
    [self resetDotViews];
}

- (void)setSpacingBetweenDots:(NSInteger)spacingBetweenDots
{
    _spacingBetweenDots = spacingBetweenDots;
    
    [self resetDotViews];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    // If no pages, no current page to treat.
    if (self.numberOfPages == 0 || currentPage == _currentPage) {
        _currentPage = currentPage;
        return;
    }
    _currentPage = currentPage;
    [self updateDotsFrame];
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    [self resetDotViews];
}

- (void)setCurrentDotColor:(UIColor *)currentDotColor
{
    _currentDotColor = currentDotColor;
    [self resetDotViews];
}

- (void)setDotImage:(UIImage *)dotImage
{
    _dotImage = dotImage;
    _dotSize = dotImage.size;
    [self resetDotViews];
}

- (void)setCurrentDotImage:(UIImage *)currentDotimage
{
    _currentDotImage = currentDotimage;
    _currentDotSize = currentDotimage.size;
    [self resetDotViews];
}


#pragma mark - Getters
- (NSMutableArray *)dots
{
    if (!_dots) {
        _dots = [[NSMutableArray alloc] init];
    }
    
    return _dots;
}


- (CGSize)dotSize
{
    // Dot size logic depending on the source of the dot view
    if (CGSizeEqualToSize(_dotSize, CGSizeZero)) {
        if (self.dotImage) {
            _dotSize = self.dotImage.size;
        }
    }
    return _dotSize;
}
- (CGSize)currentDotSize
{
    // Dot size logic depending on the source of the dot view
    if (CGSizeEqualToSize(_currentDotSize, CGSizeZero)) {
        if (self.currentDotImage) {
            _currentDotSize = self.currentDotImage.size;
        }
    }
    return _currentDotSize;
}

@end
