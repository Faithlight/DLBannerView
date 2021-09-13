//
//  DLPageControl.h
//  DLBannerView
//
//  Created by DL on 2021/9/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DLPageControl;
@protocol DLPageControlDelegate <NSObject>
@optional
- (void)pageControl:(DLPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index;
@end

@interface DLPageControl : UIControl
@property (nonatomic) CGSize dotSize;
@property (nonatomic) CGSize currentDotSize;

@property (nonatomic) UIImage *dotImage;
@property (nonatomic) UIImage *currentDotImage;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, strong) UIColor *currentDotColor;

@property(nonatomic,assign) id<DLPageControlDelegate> delegate;

@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) NSInteger currentPage; //Default is 0.
@property (nonatomic) NSInteger spacingBetweenDots;
@property (nonatomic) BOOL hidesForSinglePage;  //Default is NO.
@property (nonatomic) BOOL shouldResizeFromCenter;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;
@end

NS_ASSUME_NONNULL_END
