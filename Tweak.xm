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