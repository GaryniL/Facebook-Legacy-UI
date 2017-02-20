#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

#define PreferenceBundlePath @"/Library/PreferenceBundles/FacebookLegacyUI.bundle"
#define SettingPath @"/var/mobile/Library/Preferences/tw.garynil.FacebookLegacyUI.plist"

static CGFloat const kHBFPHeaderTopInset = 64.f;
static CGFloat const kHBFPHeaderHeight = 150.f;
//====================================================================================================================

@interface PSSpecifier (iKeywi)
- (void)setIdentifier:(NSString *)identifier;
@end

@interface PSListController (iKeywi)
- (void)loadView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface PSTableCell (iKeywi)
@property(readonly, assign, nonatomic) UILabel* textLabel;
@end

@interface FacebookLegacyUIButtonCell : PSTableCell
@end

//====================================================================================================================

id getUserDefaultForKey(NSString *key) {
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:SettingPath];
    return [defaults objectForKey:key];
}

void setUserDefaultForKey(NSString *key, id value) {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:SettingPath]];
    [defaults setObject:value forKey:key];
    [defaults writeToFile:SettingPath atomically:YES];
}