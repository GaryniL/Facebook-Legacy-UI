#include <substrate.h>
#import <UIKit/UIKit.h>
#import "Firmware.h"
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

%ctor 
{
  	// Init Preference
	PO2InitPrefs();

	// Add Preference listener
	PO2Observer(PO2InitPrefs, "tw.garynil.FacebookLegacyUI.settingsChanged");
}