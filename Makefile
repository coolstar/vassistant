include theos/makefiles/common.mk

export GO_EASY_ON_ME=1

TWEAK_NAME = VAssistant
VAssistant_FILES = Tweak.xm ShowcaseView.xm VAssistantViewController.m
VAssistant_FRAMEWORKS = UIKit AVFoundation QuartzCore MediaPlayer
VAssistant_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
