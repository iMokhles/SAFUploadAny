//
//  SAFUploadAnyListController.h
//  SAFUploadAny
//
//  Created by iMokhles on 23.10.2015.
//  Copyright (c) 2015 iMokhles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <substrate.h>
#import "SAFUploadAnyWKHelper.h" // testing
#import "vendors/MFFileBrowserViewController.h"
#import <UIKit/UIImage2.h>
// #import <iMoMacros.h>
#import <MobileCoreServices/MobileCoreServices.h>

// #define WEB_UI_STRING_KEY(string, key, description) WebCore::localizedString(key)
#define UICurrentUserInterfaceIdiomIsPad() ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@interface UIDocumentMenuViewController ()
- (void)_setIgnoreApplicationEntitlementForImport:(BOOL)arg1;
@end

@interface WKFileUploadPanel : UIViewController <UIDocumentMenuDelegate, MFFileBrowserViewControllerDelegate>
- (id)_documentPickerMenuMediaTypes;
- (id)_photoLibraryButtonLabel;
- (id)_cameraButtonLabel;
- (NSArray *)_mediaTypesForPickerSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void)_showPhotoPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void)_presentForCurrentInterfaceIdiom:(id)arg1;
- (void)_presentFullscreenViewController:(id)arg1 animated:(BOOL)arg2;
- (void)_presentPopoverWithContentViewController:(id)arg1 animated:(BOOL)arg2;
- (void)_dismissDisplayAnimated:(BOOL)arg1;
- (void)_cancel;
- (void)_chooseFiles:(NSArray *)fileURLs displayString:(NSString *)displayString iconImage:(UIImage *)iconImage;
// new
- (void)showSAFFileBrowser;
@end

@interface SAFUploadAnyHelper : NSObject

// Preferences
+ (NSString *)preferencesPath;
+ (CFStringRef)preferencesChanged;

// UIWindow to present your elements
// u can show/hide it using ( setHidden: NO/YES )
+ (UIWindow *)mainSAFUploadAnyWindow;
+ (UIViewController *)mainSAFUploadAnyViewController;

// Checking App Version
+ (BOOL)isAppVersionGreaterThanOrEqualTo:(NSString *)appversion;
+ (BOOL)isAppVersionLessThanOrEqualTo:(NSString *)appversion;

// Checking OS Version
+ (BOOL)isIOS83_OrGreater;
+ (BOOL)isIOS80_OrGreater;
+ (BOOL)isIOS70_OrGreater;
+ (BOOL)isIOS60_OrGreater;
+ (BOOL)isIOS50_OrGreater;
+ (BOOL)isIOS40_OrGreater;

// Checking Device Type
+ (BOOL)isIPhone6_Plus;
+ (BOOL)isIPhone6;
+ (BOOL)isIPhone5;
+ (BOOL)isIPhone4_OrLess;

// Checking Device Interface
+ (BOOL)isIPad;
+ (BOOL)isIPhone;

// Checking Device Retina
+ (BOOL)isRetina;

// Checking UIScreen sizes
+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;

@end
