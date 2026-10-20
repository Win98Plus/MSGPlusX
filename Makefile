TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = Messenger

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MSGPlusX

MSGPlusX_FILES = Tweak.xm MSGSettingsViewController.m
MSGPlusX_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
MSGPlusX_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AVFoundation Intents
MSGPlusX_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
