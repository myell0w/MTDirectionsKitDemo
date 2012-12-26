#import "MTDSearchView.h"
#import <QuartzCore/QuartzCore.h>


@interface MTDSearchView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *fromControl;
@property (nonatomic, strong) UITextField *toControl;

@end


@implementation MTDSearchView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.7f;
        self.layer.shadowOffset = CGSizeMake(0.f, 4.f);
        self.layer.masksToBounds = NO;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 20.f)];

        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentRight;
        label.text = @"Start:";

        _fromControl = [[UITextField alloc] initWithFrame:CGRectMake(5.f, 5.f, CGRectGetWidth(frame) - 10.f, 30.f)];
        _fromControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _fromControl.borderStyle = UITextBorderStyleRoundedRect;
        _fromControl.leftViewMode = UITextFieldViewModeAlways;
        _fromControl.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        label.font = _fromControl.font;
        _fromControl.leftView = label;
        _fromControl.returnKeyType = UIReturnKeyNext;
        _fromControl.clearButtonMode = UITextFieldViewModeWhileEditing;
        _fromControl.delegate = self;
        _fromControl.text = @"Güssing, Österreich";
        _fromControl.placeholder = @"Address or Lat/Lng";
        [self addSubview:_fromControl];

        label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 50.f, 20.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        label.textAlignment = UITextAlignmentRight;
        label.font = _fromControl.font;
        label.text = @"End:";

        _toControl = [[UITextField alloc] initWithFrame:CGRectMake(5.f, CGRectGetMaxY(_fromControl.frame) + 5.f,
                                                                   CGRectGetWidth(_fromControl.frame), 30.f)];
        _toControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _toControl.borderStyle = UITextBorderStyleRoundedRect;
        _toControl.leftViewMode = UITextFieldViewModeAlways;
        _toControl.leftView = label;
        _toControl.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _toControl.returnKeyType = UIReturnKeyRoute;
        _toControl.clearButtonMode = UITextFieldViewModeWhileEditing;
        _toControl.delegate = self;
        _toControl.text = @"Wien";
        _toControl.placeholder = @"Address or Lat/Lng";
        [self addSubview:_toControl];
    }

    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - MTDSearchView
////////////////////////////////////////////////////////////////////////

- (void)setFromDescription:(NSString *)fromDescription {
    self.fromControl.text = fromDescription;
}

- (NSString *)fromDescription {
    return self.fromControl.text;
}

- (void)setToDescription:(NSString *)toDescription {
    self.toControl.text = toDescription;
}

- (NSString *)toDescription {
    return self.toControl.text;
}

@end
