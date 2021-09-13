//
//  DLBannerView.h
//  DLBannerView
//
//  Created by DL on 2021/9/13.
//

#import <UIKit/UIKit.h>
#import "DLBannerViewItemCell.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, DLBannerPageContolStyle) {
    DLBannerPageContolStyleSystemic,        // 系统样式
    DLBannerPageContolStyleAnimated,       // 自定义DLPageControl
    DLBannerPageContolStyleNone            // 不显示pagecontrol
};

@class DLBannerView;
@protocol DLBannerViewDelegate <NSObject>
- (NSInteger)numberOfItemForBannerView:(DLBannerView *)bannerView;
@optional
///常规banner
- (void)bannerView:(DLBannerView *)bannerView willDisplayBannerItemCell:(DLBannerViewItemCell *)cell forItemAtIndex:(NSInteger)index;

///自定义样式
- (Class)willRegisterCustomBannerItemCellClassForBannerView:(DLBannerView *)bannerView;
- (void)bannerView:(DLBannerView *)bannerView willDisplayCustomBannerItemCell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index;

///action
- (void)bannerView:(DLBannerView *)bannerView didSelectBannerItemAtIndex:(NSInteger)index;
- (void)bannerView:(DLBannerView *)bannerView bannerItemDidScrollToIndex:(NSInteger)index;
@end


@interface DLBannerView : UIView

@property (nonatomic,weak) id<DLBannerViewDelegate> delegate;
@property (nonatomic,assign) BOOL autoScroll;
@property (nonatomic,assign) BOOL infiniteLoop; /// 是否无限循环,默认Yes
@property (nonatomic,assign) CGFloat autoScrollTimeInterval; /// 滚动间隔时间,默认2s
@property (nonatomic,assign) UICollectionViewScrollDirection scrollDirection;

@property (nonatomic, assign) DLBannerPageContolStyle pageControlStyle;
///分页控件位置
@property (nonatomic, assign) UIControlContentHorizontalAlignment pageControlAliment;
///分页控件的偏移量
@property (nonatomic, assign) CGFloat pageControlOffsetX;
@property (nonatomic, assign) CGFloat pageControlOffsetY;
///分页控件圆标大小
@property (nonatomic, assign) CGSize pageControlDotSize;

@property (nonatomic, strong) UIColor *pageDotColor;
@property (nonatomic, strong) UIColor *currentPageDotColor;

@property (nonatomic, strong) UIImage *pageDotImage;
@property (nonatomic, strong) UIImage *currentPageDotImage;

@property(nonatomic) BOOL hidesForSinglePage;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<DLBannerViewDelegate>)delegate;
- (void)reloadData;

- (void)scrollToBannerItemIndex:(NSInteger)index;
- (void)adjustDispayEffectWhenControllerViewWillAppera;
- (void)disableScrollGesture;///滚动手势禁用
@end

NS_ASSUME_NONNULL_END
