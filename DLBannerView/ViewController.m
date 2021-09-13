//
//  ViewController.m
//  DLBannerView
//
//  Created by DL on 2021/9/13.
//

#import "ViewController.h"
#import "DLBannerView.h"
@interface ViewController ()<DLBannerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DLBannerView *banner = [[DLBannerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300) delegate:self];
    banner.autoScroll = YES;
    banner.infiniteLoop = YES;
    banner.pageDotColor = UIColor.whiteColor;
    banner.currentPageDotColor = UIColor.redColor;
        //    banner.pageDotImage = [UIImage imageWithColor:DDWhiteColor size:CGSizeMake(6, 6)];
        //    banner.currentPageDotImage = [UIImage imageWithColor:DDWhiteColor size:CGSizeMake(12, 6)];
    banner.autoScrollTimeInterval = 3;
    banner.pageControlAliment = UIControlContentHorizontalAlignmentCenter;
    [self.view addSubview:banner];
    [banner reloadData];
    
}

#pragma mark DLBannerViewDelegate
- (NSInteger)numberOfItemForBannerView:(DLBannerView *)bannerView
{
    return 5;
}
- (void)bannerView:(DLBannerView *)bannerView willDisplayBannerItemCell:(DLBannerViewItemCell *)cell forItemAtIndex:(NSInteger)index {
//    [cell.imageView sd_setImageWithURL:xxx];
    cell.imageView.image = [UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:[NSString stringWithFormat:@"p%ld",index+1] ofType:@"jpg"]];
    
//    cell.titleLabel.text = [NSString stringWithFormat:@"p%ld",index+1];
//    cell.titleLabel.hidden = NO;
}
- (void)bannerView:(DLBannerView *)bannerView didSelectBannerItemAtIndex:(NSInteger)index
{
    NSLog(@"%ld",index);
    bannerView.pageControlStyle = index;

}

@end
