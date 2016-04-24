GO_EASY_ON_ME = 1

DEBUG = 0

ARCHS = armv7 armv7s arm64

THEOS_DEVICE_IP = localhost

TARGET = iphone:clang:latest:9.0

export ADDITIONAL_LDFLAGS = -Wl,-segalign,4000

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = SAFUploadAny
SAFUploadAny_CFLAGS = -fobjc-arc
SAFUploadAny_FILES = SAFUploadAny.xm SAFUploadAnyHelper.m $(wildcard vendors/*.m) $(wildcard vendors/*.c) $(wildcard vendors/*.mm)
SAFUploadAny_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CoreImage Accelerate AVFoundation AudioToolbox MobileCoreServices Social Accounts AssetsLibrary AdSupport MediaPlayer SystemConfiguration
SAFUploadAny_LIBRARIES = MobileGestalt z sqlite3 imodevtools2 imounbox

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
