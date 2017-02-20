#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import "FacebookLegacyUI.h"
#import "Firmware.h"

@interface UIPreferencesTable
- (void)setContentInset:(UIEdgeInsets)contentInset;
- (void)setContentOffset:(CGPoint)contentOffset;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(id)completion;
@end

@interface FacebookLegacyUIListController: PSListController 
{
	CGRect topFrame;
	UIImageView* logoImage;
	UILabel* bannerTitle;
	UILabel* footerLabel;
	UILabel* titleLabel;
}
@property(retain) UIImageView* bannerImage;
@property(retain) UIView* bannerView;
@property(retain) NSMutableArray *translationCredits;
@end

@implementation FacebookLegacyUIButtonCell
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.textColor = [UIColor colorWithRed:0.09 green:0.78 blue:0.34 alpha:1.0];
}
@end

@implementation FacebookLegacyUIListController

- (instancetype)init {
	self = [super init];
	return self;
}

- (NSArray *)specifiers {
	if (_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];

        PSSpecifier *group_tab = [PSSpecifier groupSpecifierWithName:@"Tab Buttons"];
        [group_tab setProperty:@"" forKey:@"footerText"];
        [specifiers addObject:group_tab];

        PSSpecifier* toggle_messenger = [[self loadSpecifiersFromPlistName:@"FacebookLegacyUI" target:self] objectAtIndex:0];
        [specifiers addObject:toggle_messenger];

        PSSpecifier* toggle_video = [[self loadSpecifiersFromPlistName:@"FacebookLegacyUI" target:self] objectAtIndex:1];
        [specifiers addObject:toggle_video];



        PSSpecifier *group_navi = [PSSpecifier groupSpecifierWithName:@"Navigation Buttons"];
        [group_navi setProperty:@"" forKey:@"footerText"];
        [specifiers addObject:group_navi];

        PSSpecifier* navi_camera = [[self loadSpecifiersFromPlistName:@"FacebookLegacyUI" target:self] objectAtIndex:2];
        [specifiers addObject:navi_camera];


        // For Apply button !
        PSSpecifier *applyBtnG = [PSSpecifier groupSpecifierWithName:@""];
        [applyBtnG setProperty:@"Quit Facebook to apply your setting" forKey:@"footerText"];
        [specifiers addObject:applyBtnG];

        PSSpecifier* applyBtn = [[self loadSpecifiersFromPlistName:@"FacebookLegacyUI" target:self] objectAtIndex:3];
        [applyBtn setProperty:@2 forKey:@"alignment"];
        [specifiers addObject:applyBtn];


        

        PSSpecifier *donateG = [PSSpecifier groupSpecifierWithName:@""];
        [donateG setProperty:@"I'm a coffee addict. You can donate me a cup of coffee if you like this tweak ~" forKey:@"footerText"];
        [specifiers addObject:donateG];
        PSSpecifier *donate = [PSSpecifier preferenceSpecifierNamed:@"Donate via Paypal" target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
        [donate setProperty:[FacebookLegacyUIButtonCell class] forKey:@"cellClass"];
        [donate setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/FacebookLegacyUI.bundle/paypal.png"] forKey:@"iconImage"];
        donate->action = @selector(openDonate);
        [specifiers addObject:donate];



        PSSpecifier *aboutG = [PSSpecifier groupSpecifierWithName:@"About"];
        [specifiers addObject:aboutG];
        PSSpecifier *followTwitter = [PSSpecifier preferenceSpecifierNamed:@"Follow @garynil" target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
        followTwitter->action = @selector(openTwitter);
        [followTwitter setProperty:@2 forKey:@"alignment"];
        [specifiers addObject:followTwitter];

        PSSpecifier *followTwitterH = [PSSpecifier preferenceSpecifierNamed:@"Follow @hirakujira" target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
        followTwitterH->action = @selector(openTwitterH);
        [followTwitterH setProperty:@2 forKey:@"alignment"];
        [specifiers addObject:followTwitterH];

        


        PSSpecifier *gAuthor = [PSSpecifier emptyGroupSpecifier];
        [gAuthor setProperty:@(YES) forKey:@"isStaticText"];
        [gAuthor setProperty:@1 forKey:@"footerAlignment"];
        [gAuthor setProperty:@"© 2015-2017 Garynil & Hiraku" forKey:@"footerText"];
        [specifiers addObject:gAuthor];

       	[_specifiers release];
        _specifiers = nil;
        _specifiers = [[NSArray alloc] initWithArray:specifiers];
    }
    
	return _specifiers;
}

- (void)loadView
{
  	[super loadView];

  	UINavigationItem* navigationItem = self.navigationItem;
	// navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTweak)];

	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,40)];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17]];
    [titleLabel setText:@""];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    navigationItem.titleView = titleLabel;
    [titleLabel setAlpha:0];

    CGFloat headerHeight = kHBFPHeaderTopInset + kHBFPHeaderHeight;

    CGRect selfFrame = [self.view frame];
    _bannerView = [[UIView alloc] init];
    _bannerView.frame = CGRectMake(0, -headerHeight, selfFrame.size.width, headerHeight);
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.table addSubview:_bannerView];
    [self.table sendSubviewToBack:_bannerView];
    
    // logoImage = [[UIImageView alloc] initWithImage:[self imageForSize:CGSizeMake(50,50) withSelector:@selector(drawLogo)]];
    // [self.bannerImage addSubview:logoImage];
  
    bannerTitle = [[UILabel alloc] init];
    bannerTitle.text = @"Facebook Legacy UI"; 
    [bannerTitle setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40]];
	bannerTitle.textColor = [UIColor blackColor];
    [_bannerView addSubview:bannerTitle];
    [bannerTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    // [_bannerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bannerTitle]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(bannerTitle)]];
	[_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
	[_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:bannerTitle attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:120.0]];
    bannerTitle.textAlignment = NSTextAlignmentCenter;

    footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,topFrame.size.height/2+65,320,50)];
    footerLabel.text = @"Make your Facebook app layout great again !"; 
    [footerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
	footerLabel.textColor = [UIColor blackColor];
	// footerLabel.alpha = 0.7;
	
    [_bannerView addSubview:footerLabel];
    [footerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f]];
	[_bannerView addConstraint:[NSLayoutConstraint constraintWithItem:footerLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:185.0]];
	footerLabel.textAlignment = NSTextAlignmentCenter;

    [self.table setContentInset:UIEdgeInsetsMake(150,0,0,0)];
    [self.table setContentOffset:CGPointMake(0, -150)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat scrollOffset = scrollView.contentOffset.y;
    topFrame = CGRectMake(0, scrollOffset, 0, -scrollOffset);
    
    if (scrollOffset > -167 && scrollOffset < -116 && scrollOffset != -150)
    {
    	[titleLabel setText:@"FacebookLegacyUI"];
    	float alphaDegree = -116 - scrollOffset;
    	[titleLabel setAlpha:1/alphaDegree];
    }
    else if ( scrollOffset >= -116)
    	[titleLabel setAlpha:1];
   	else if (scrollOffset < -167)
	   	[titleLabel setAlpha:0];
}

-(void) killPreferences {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("tw.garynil.FacebookLegacyUI.settingsChanged"), nil, nil, YES);

    UIAlertView *suicidalPreferences = [[UIAlertView alloc] initWithTitle:@"Note"
        message:@"Kill Preferences & Facebook app to store setting. This is not a crash."
        delegate:self
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil];
    [suicidalPreferences show];
    [suicidalPreferences release];
}
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        system("/usr/bin/killall -9 Facebook");
        sleep(0.3);
        system("/usr/bin/killall -9 Preferences");
    }
}
-(void) openDonate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=garynil1635%40gmail%2ecom&lc=US&item_name=Gary%20niL%27s%20tweak&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest"]];
}

-(void) openTwitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=garynil"]];
}
-(void) openTwitterH {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=hirakujira"]];
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier {
    return getUserDefaultForKey(specifier.identifier);
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier {
    setUserDefaultForKey(specifier.identifier, value);
}
@end



// vim:ft=objc
