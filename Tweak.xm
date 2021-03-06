#include <substrate.h>
#import <UIKit/UIKit.h>
#import "firmware.h"
#import "PO2Common.h"
#import "PO2Log.h"

static BOOL shouldSyslogSpam; //enableDebugMode

static BOOL FBLUIenableVideoHomeTab = NO;
static BOOL FBLUIenableMessengerHomeTab = NO;

static BOOL FBLUIenableCameraInNavigation = NO;

static UIButton* messengerHomeTabButton;

static void PO2InitPrefs() {
	// Load preference file into NSDictionary
	PO2SyncPrefs();

	PO2BoolPref(FBLUIenableMessengerHomeTab, enableMessengerHomeTab, 1);
	PO2BoolPref(FBLUIenableVideoHomeTab, enableVideoHomeTab, 1);

	PO2BoolPref(FBLUIenableCameraInNavigation, enableCameraInNavigation, 0);
}


@interface FBTabBar : UIView
-(void)openMessenger:(UIButton *)sender;
@end

@interface FBTabBarItemView : UIView
- (NSString *)title;
@end

@interface FBTabBarItemDefaultView : UIView
- (NSString *)title;
@end


static FBTabBarItemView *videoButton;

%hook FBVideoHomeExperimentDefaults
// Video button in Hometabs
- (bool)showVideoHomeTab{
    return FBLUIenableVideoHomeTab;
}

// False shows messenger button in Hometabs
- (bool)showMessengerInNavigationBar{
    return !FBLUIenableMessengerHomeTab;
    // true 左上角
}

%end

%hook FBInspirationStateManager

- (bool)shouldShowCameraInLeftSidebar{
    return FBLUIenableCameraInNavigation;
}

- (bool)shouldShowCameraButtonInNavigationBar{
    return FBLUIenableCameraInNavigation;
}
%end

%hook FBVideoHomeExperimentConfig
- (bool)showMessengerInNavigationBarForVideosTab{
    return !FBLUIenableMessengerHomeTab;
    //true 左上角
}
%end


%hook FBNavigationBarDecorator
- (bool)_hasRightMessengerButton{
	// disable messenger show on right top
	// PO2Log([NSString stringWithFormat:@"FBNavigationBarDecorator = _hasRightMessengerButton %d",%orig], 1);
	return !FBLUIenableMessengerHomeTab;
}
// - (bool)_hasLeftMessengerButton{
// 	// disable messenger show on left top
// 	// PO2Log([NSString stringWithFormat:@"FBNavigationBarDecorator = _hasRightMessengerButton %d",%orig], 1);
// 	return !FBLUIenableMessengerHomeTab;
// }
%end

%hook FBTabBar
// -(void)_layoutTabBarItems{
// -(void)touchesBegan:(id)arg1 withEvent:(id)arg2 {
-(void)layoutSubviews{
    PO2Log([NSString stringWithFormat:@"FBTabBar = layoutSubviews"], 1);
	%orig();
	if (!FBLUIenableMessengerHomeTab) {
		return;
	}
	int viewCount = 0;
	double viewCountMid = 0;
	int newButtonIndex = 0;
	double thisWidth = self.frame.size.width;

	// Caculate views
	for (UIView *subview in [self subviews]) {
		if ([subview isKindOfClass:[%c(FBTabBarItemView) class]]  || [subview isKindOfClass:[%c(FBTabBarItemDefaultView) class]]) {
        	viewCount += 1;
        }
	}

	if (viewCount % 2 == 0) {
		// 偶數
		viewCountMid = viewCount/2 ;
		newButtonIndex = viewCountMid ;
	} else {
		// 奇數
		viewCountMid = (double)viewCount/2 ;
		newButtonIndex = viewCount/2 + 1;
	}

	UIView *sampleView ;
	for (UIView *subview in [self subviews]) {
        // Do what you want to do with the subview
        // PO2Log([NSString stringWithFormat:@"view is %@", subview], 1);
        if ([subview isKindOfClass:[%c(FBTabBarItemView) class]] || [subview isKindOfClass:[%c(FBTabBarItemDefaultView) class]]) {
            //
        	// PO2Log([NSString stringWithFormat:@"view is %@", subview], 1);
        	if (!sampleView){
        		sampleView = subview;
        	}

        	if (subview.tag < viewCountMid) {
        		// subview.backgroundColor = [UIColor redColor];
        		[subview setFrame:CGRectMake(0 + thisWidth/(viewCount+1)*subview.tag, sampleView.frame.origin.y, thisWidth/(viewCount+1), sampleView.frame.size.height)];
        	} else {
        		// subview.backgroundColor = [UIColor blueColor];
        		[subview setFrame:CGRectMake(0 + thisWidth/(viewCount+1)*(subview.tag+1), sampleView.frame.origin.y, thisWidth/(viewCount+1), sampleView.frame.size.height)];
        	}
        }
    }

    if (!messengerHomeTabButton && sampleView) {
    	messengerHomeTabButton = [[UIButton alloc] init];
    }

    if(![messengerHomeTabButton isDescendantOfView:self]) {
    	// messengerHomeTabButton.backgroundColor = [UIColor greenColor];
    	[messengerHomeTabButton addTarget:self action:@selector(openMessenger:) forControlEvents:UIControlEventTouchUpInside];
    	[messengerHomeTabButton setFrame:CGRectMake(0 + sampleView.frame.size.width*newButtonIndex, sampleView.frame.origin.y, sampleView.frame.size.width, sampleView.frame.size.height)];
    	[self addSubview:messengerHomeTabButton];

        UIImageView *messengerImageView = [[UIImageView alloc] init];
        CGRect buttonFrame = messengerHomeTabButton.frame;
        float h = 24;
        float w = 24;
        [messengerImageView setFrame:CGRectMake((buttonFrame.size.width - w)/2,(buttonFrame.size.height - h)/2,w,h)];
        NSBundle *sharedFramework = [NSBundle bundleForClass:[%c(FBTabBar) class]];
        // PO2Log([NSString stringWithFormat:@"Bundle %@",], 1);
        UIImage *icon = [UIImage imageNamed:@"fb_glyphs_messages_24" inBundle:sharedFramework compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
        icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [messengerImageView setImage:icon];
        [messengerImageView setTintColor:[UIColor colorWithRed:0.564 green:0.58 blue:0.613 alpha:1]];
        [messengerHomeTabButton addSubview:messengerImageView];
    }
}

%new
-(void)openMessenger:(UIButton *)sender{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb-messenger://"]];
    }
	else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/messenger/id454638411?mt=8"]];
    }
}

%end

%ctor
{
  	// Init Preference
	PO2InitPrefs();
    // PO2Log([NSString stringWithFormat:@"[Fuck] Siri: "], 1);
	// Add Preference listener
	PO2Observer(PO2InitPrefs, "tw.garynil.FacebookLegacyUI.settingsChanged");
}
