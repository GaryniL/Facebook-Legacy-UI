#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#define PO2PreferencePath @"/User/Library/Preferences/tw.garynil.FacebookLegacyUI.plist"

static NSDictionary* plistDict; // list of whitelist apps

#define PO2Observer(funcToCall, listener) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)funcToCall, CFSTR(listener), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
#define PO2SyncPrefs()\
	plistDict = [NSDictionary dictionaryWithContentsOfFile:PO2PreferencePath];


#define STRINGIFY_(x) #x
#define STRINGIFY(x) STRINGIFY_(x)

#define PO2BoolLog(arg) PO2Log([NSString stringWithFormat:@"%s = %d", #arg, arg], shouldSyslogSpam)
#define PO2BoolPref(var, key, default) do {\
	NSNumber *key = plistDict[@STRINGIFY(key)];\
	var = key ? [key boolValue] : default;\
	PO2BoolLog(var);\
} while (0)

#define PO2IntLog(arg) PO2Log([NSString stringWithFormat:@"%s = %i", #arg, arg], shouldSyslogSpam)
#define PO2IntPref(var, key, default) do {\
	NSNumber *key = plistDict[@STRINGIFY(key)];\
	var = key ? [key intValue] : default;\
	PO2IntLog(var);\
} while (0)

#define PO2FloatLog(arg) PO2Log([NSString stringWithFormat:@"%s = %f", #arg, arg], shouldSyslogSpam)
#define PO2FloatPref(var, key, default) do {\
	NSNumber *key = plistDict[@STRINGIFY(key)];\
	var = key ? [key floatValue] : default;\
	PO2FloatLog(var);\
} while (0)

#define PO2StringLog(arg) PO2Log([NSString stringWithFormat:@"%s = %@", #arg, arg], shouldSyslogSpam)
#define PO2StringPref(var, key, default) do {\
	NSString *key = plistDict[@STRINGIFY(key)];\
	var = ([key length] > 0) ? key : default;\
	PO2StringLog(var);\
} while (0)