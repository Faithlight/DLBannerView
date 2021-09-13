//
//  DLBannerViewItemCell.m
//  DLBannerView
//
//  Created by DL on 2021/9/13.
//

#import "DLBannerViewItemCell.h"

@implementation DLBannerViewItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.titleLabel.hidden = YES;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}




- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    CGFloat titleLabelW = self.frame.size.width;
    CGFloat titleLabelH = 30;
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = self.frame.size.height - titleLabelH;
    _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
}
@end
