#import "MTDTitleView.h"


@interface MTDTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

@end


@implementation MTDTitleView

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat height = CGRectGetHeight(frame)/2.f + 3.f;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(frame), height)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumFontSize = 11.f;
        _titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.shadowColor = [UIColor grayColor];
        _titleLabel.shadowOffset = CGSizeMake(0.f, -1.f);
        [self addSubview:_titleLabel];

        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, height+2.f, CGRectGetWidth(frame), CGRectGetHeight(frame) - height - 2.f)];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:11.f];
        _detailLabel.textAlignment = UITextAlignmentCenter;
        _detailLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _detailLabel.shadowColor = [UIColor grayColor];
        _detailLabel.shadowOffset = CGSizeMake(0.f, -1.f);
        [self addSubview:_detailLabel];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDTitleView
////////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title detailText:(NSString *)detailText {
    self.titleLabel.text = title;
    self.detailLabel.text = detailText;
}

@end
