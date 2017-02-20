BUNDLE_NAME = FacebookLegacyUI
FacebookLegacyUI_FILES = FacebookLegacyUI.mm
FacebookLegacyUI_INSTALL_PATH = /Library/PreferenceBundles
FacebookLegacyUI_FRAMEWORKS = UIKit 
FacebookLegacyUI_PRIVATE_FRAMEWORKS = Preferences
FacebookLegacyUI_LIBRARIES = applist
IP_ADDRESS=127.0.0.1
RSYNC_SETTINGS = -e "ssh -p 2222" -z
SSH_PORT = -p 2222
FacebookLegacyUI_CFLAGS = -I$(SYSROOT)/usr/include/libxml2
FacebookLegacyUI_LDFLAGS = -lxml2
GO_EASY_ON_ME = 1
FacebookLegacyUI_LDFLAG += -Wl,-segalign,0x4000
export ARCHS = armv7 armv7s arm64
export TARGET = iphone:clang::5.0

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk


internal-stage ::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FacebookLegacyUI.plist$(ECHO_END)
sync: stage
	rsync -e "ssh -p 2222" -z .theos/_/Library/PreferenceBundles/FacebookLegacyUI.bundle/* root@127.0.0.1:/Library/PreferenceBundles/FacebookLegacyUI.bundle/
	ssh root@127.0.0.1 -p 2222 killall Preferences
	ssh root@127.0.0.1 -p 2222 open com.apple.Preferences