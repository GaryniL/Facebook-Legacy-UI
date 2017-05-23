#include <substrate.h>
#import <UIKit/UIKit.h>
#import "firmware.h"
#import "PO2Common.h"
#import "PO2Log.h"

static BOOL shouldSyslogSpam; //enableDebugMode

static BOOL FBLUIenableVideoHomeTab = NO;
static BOOL FBLUIenableMessengerHomeTab = NO;

static BOOL FBLUIenableCameraInNavigation = NO;


static void PO2InitPrefs() {
	// Load preference file into NSDictionary
	PO2SyncPrefs();

	PO2BoolPref(FBLUIenableMessengerHomeTab, enableMessengerHomeTab, 1);
	PO2BoolPref(FBLUIenableVideoHomeTab, enableVideoHomeTab, 1);

	PO2BoolPref(FBLUIenableCameraInNavigation, enableCameraInNavigation, 0);
}


@interface FBTabBar : UIView

@end

@interface FBTabBarItemView : UIView
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
	PO2Log([NSString stringWithFormat:@"FBNavigationBarDecorator = _hasRightMessengerButton %d",%orig], 1);
	return false;
}
%end

// %hook FBTabBarItemView
%hook FBTabBar

// -(void)_rebuildTabBarViews{
// -(void)_layoutTabBarItems{
-(void)layoutSubviews{
	%orig();

	int viewCount = 0;
	double viewCountMid = 0;

	// Caculate views
	for (UIView *subview in [self subviews]) {
		if ([subview isKindOfClass:[%c(FBTabBarItemView) class]]) {
        	viewCount += 1;
        }
	}

	// Testing
	viewCount = 5;

	if (viewCount % 2 == 0) {
		// 偶數
		viewCountMid = viewCount/2 ;
	} else {
		// 奇數
		viewCountMid = (double)viewCount/2 ;
	}

	PO2Log([NSString stringWithFormat:@"view count %d %f", viewCount,viewCountMid], 1);

	for (UIView *subview in [self subviews]) {
        // Do what you want to do with the subview
        if ([subview isKindOfClass:[%c(FBTabBarItemView) class]]) {

        	PO2Log([NSString stringWithFormat:@"view is %@", subview], 1);

        	if (subview.tag < viewCountMid) {
        		// subview.backgroundColor = [UIColor redColor];
        		[subview setFrame:CGRectMake(0 + subview.frame.size.width*(viewCount)/(viewCount+1)*subview.tag, subview.frame.origin.y, subview.frame.size.width*(viewCount)/(viewCount+1), subview.frame.size.height)];
        	} else {
        		// subview.backgroundColor = [UIColor blueColor];
        		[subview setFrame:CGRectMake(0 + subview.frame.size.width*(viewCount)/(viewCount+1)*(subview.tag+1), subview.frame.origin.y, subview.frame.size.width*(viewCount)/(viewCount+1), subview.frame.size.height)];
        	}
        }
    }
    PO2Log([NSString stringWithFormat:@"==============================="], 1);
}

%end

%hook FBTabBarItemView
- (id)init {
    PO2StringLog(@"Hi");
    return %orig;
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    PO2Log([NSString stringWithFormat:@"Evets is %@", [event touchesForView:videoButton]], 1);
    if ([event touchesForView:videoButton]) {
         /* code */
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb-messenger://"]];
    }
    else {
        %orig;
    }
    // PO2Log([NSString stringWithFormat:@"Title is %@", @"hi"], 1);
    // [arViewController.arView touchesEnded:touches withEvent:event];
}

-(void)setBackgroundImage:(UIImage *)image {
	%orig;
    // UIImage *image = %orig;
    PO2StringLog([self title]);
    PO2Log([NSString stringWithFormat:@"BGImage is %@", [image accessibilityIdentifier]], 1);
}

- (void)setImage:(UIImage *)image {
    %orig;
    // UIImage *image = %orig;
    PO2StringLog([self title]);
    PO2Log([NSString stringWithFormat:@"Image is %@", [image accessibilityIdentifier]], 1);
}

- (void)setTitle:(NSString *)title {
    %orig;

    if ([title isEqualToString:@"影片"]) {
        videoButton = self;
        PO2Log([NSString stringWithFormat:@"Title is %@", title], 1);
        for (UIView *subview in self.subviews) {

            for (UIGestureRecognizer *recognizer in subview.gestureRecognizers)
        {
            //Do something with recognizer
            PO2Log([NSString stringWithFormat:@"recognizer is %@", recognizer], 1);
        }
        }
    }
}

- (NSString *)title {
    PO2StringLog(%orig);
    return %orig;
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
