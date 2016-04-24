//
//  SAFUploadAny.x
//  SAFUploadAny
//
//  Created by iMokhles on 23.10.2015.
//  Copyright (c) 2015 iMokhles. All rights reserved.
//

#import "SAFUploadAnyHelper.h"

extern "C" UIImage* _UIImageGetWebKitPhotoLibraryIcon(void);
extern "C" UIImage* _UIImageGetWebKitTakePhotoOrVideoIcon(void);
extern "C" UIImage *_UIImageWithName(NSString *);

static inline UIImage *photoLibraryIcon()
{
 return _UIImageGetWebKitPhotoLibraryIcon();
}

static inline UIImage *cameraIcon()
{
	return _UIImageGetWebKitTakePhotoOrVideoIcon();
}

static inline UIImage *anyFileIcon() {
	return _UIImageWithName(@"UIButtonBarAction");
}

%group main9

%hook WKFileUploadPanel
- (void)_showDocumentPickerMenu {

	__block BOOL _usingCamera = MSHookIvar<BOOL>(self, "_usingCamera");

	UIDocumentMenuViewController *_documentMenuController = MSHookIvar<UIDocumentMenuViewController *>(self, "_documentMenuController");

	_documentMenuController = [UIDocumentMenuViewController alloc];
    [_documentMenuController _setIgnoreApplicationEntitlementForImport:YES];
    [_documentMenuController initWithDocumentTypes:[self _documentPickerMenuMediaTypes] inMode:UIDocumentPickerModeImport];
    [_documentMenuController setDelegate:self];

    [_documentMenuController addOptionWithTitle:[self _photoLibraryButtonLabel] image:photoLibraryIcon() order:UIDocumentMenuOrderFirst handler:^{
        [self _showPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];

    if (NSString *cameraString = [self _cameraButtonLabel]) {
        [_documentMenuController addOptionWithTitle:cameraString image:cameraIcon() order:UIDocumentMenuOrderFirst handler:^{
            _usingCamera = YES;
            [self _showPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
    }

    [_documentMenuController addOptionWithTitle:@"Upload File" image:anyFileIcon() order:UIDocumentMenuOrderFirst handler:^{
        [self showSAFFileBrowser];
    }];
    [self _presentForCurrentInterfaceIdiom:_documentMenuController];

}

%new
- (void)showSAFFileBrowser {

	MFFileBrowserViewController *fileBrwoser = [[MFFileBrowserViewController alloc] init];
    fileBrwoser.delegate = self;
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fileBrwoser];

	[self _presentForCurrentInterfaceIdiom:navigationController];
}

%new
- (void)fileBrowserDidCancelled:(MFFileBrowserViewController *)browser {
    [self _dismissDisplayAnimated:YES];
	[self _cancel];
}

%new
- (void)fileBrowser:(MFFileBrowserViewController *)browser didSelectFile:(NSString *)path {

	[self _dismissDisplayAnimated:YES];
	NSURL *fileURLPathSF = [NSURL fileURLWithPath:path];
	[self _chooseFiles:[NSArray arrayWithObject:fileURLPathSF] displayString:[path lastPathComponent] iconImage:nil];
}

%new
- (BOOL)fileBrowser:(MFFileBrowserViewController *)browser shouldDeleteFileAtPath:(NSString *)path {
    return NO;
}
%new
- (void)fileBrowser:(MFFileBrowserViewController *)browser didLoadDirectory:(NSString *)path {

}
%end
%end

// %group main8
// %hook WKFileUploadPanel
// - (void)_showMediaSourceSelectionSheet
// {

// 	__block BOOL _usingCamera = MSHookIvar<BOOL>(self, "_usingCamera");
// 	UIPopoverController *_presentationPopover = MSHookIvar<UIPopoverController *>(self, "_presentationPopover");
// 	UIAlertController *_actionSheetController = MSHookIvar<UIAlertController *>(self, "_actionSheetController");

//     NSString *existingString = WEB_UI_STRING_KEY("Photo Library", "Photo Library (file upload action sheet)", "File Upload alert sheet button string for choosing an existing media item from the Photo Library");
//     NSString *cancelString = WEB_UI_STRING_KEY("Cancel", "Cancel (file upload action sheet)", "File Upload alert sheet button string to cancel");

//     // Choose the appropriate string for the camera button.
//     NSString *cameraString;
//     NSArray *filteredMediaTypes = [self _mediaTypesForPickerSourceType:UIImagePickerControllerSourceTypeCamera];
//     BOOL containsImageMediaType = [filteredMediaTypes containsObject:(NSString *)kUTTypeImage];
//     BOOL containsVideoMediaType = [filteredMediaTypes containsObject:(NSString *)kUTTypeMovie];
//     ASSERT(containsImageMediaType || containsVideoMediaType);
//     if (containsImageMediaType && containsVideoMediaType)
//         cameraString = WEB_UI_STRING_KEY("Take Photo or Video", "Take Photo or Video (file upload action sheet)", "File Upload alert sheet camera button string for taking photos or videos");
//     else if (containsVideoMediaType)
//         cameraString = WEB_UI_STRING_KEY("Take Video", "Take Video (file upload action sheet)", "File Upload alert sheet camera button string for taking only videos");
//     else
//         cameraString = WEB_UI_STRING_KEY("Take Photo", "Take Photo (file upload action sheet)", "File Upload alert sheet camera button string for taking only photos");

//     _actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

//     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleCancel handler:^(UIAlertAction *){
//         [self _cancel];
//         // We handled cancel ourselves. Prevent the popover controller delegate from cancelling when the popover dismissed.
//         [_presentationPopover setDelegate:nil];
//     }];

//     UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraString style:UIAlertActionStyleDefault handler:^(UIAlertAction *){
//         _usingCamera = YES;
//         [self _showPhotoPickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
//     }];

//     UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:existingString style:UIAlertActionStyleDefault handler:^(UIAlertAction *){
//         [self _showPhotoPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//     }];

//     UIAlertAction *anyFileAction = [UIAlertAction actionWithTitle:@"Upload File" style:UIAlertActionStyleDefault handler:^(UIAlertAction *){
//         [self showSAFFileBrowser];
//     }];

//     [_actionSheetController addAction:cancelAction];
//     [_actionSheetController addAction:cameraAction];
//     [_actionSheetController addAction:photoLibraryAction];
//     [_actionSheetController addAction:anyFileAction];

//     if (UICurrentUserInterfaceIdiomIsPad())
//         [self _presentPopoverWithContentViewController:_actionSheetController animated:YES];
//     else
//         [self _presentFullscreenViewController:_actionSheetController animated:YES];
// }
// %new
// - (void)showSAFFileBrowser {

// 	MFFileBrowserViewController *fileBrwoser = [[MFFileBrowserViewController alloc] init];
//     fileBrwoser.delegate = self;
// 	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:fileBrwoser];

// 	[self _presentForCurrentInterfaceIdiom:navigationController];
// 	// [self _presentPopoverWithContentViewController:navigationController animated:YES];
// }

// %new
// - (void)fileBrowserDidCancelled:(MFFileBrowserViewController *)browser {
//     [self _dismissDisplayAnimated:YES];
// 	[self _cancel];
// }

// %new
// - (void)fileBrowser:(MFFileBrowserViewController *)browser didSelectFile:(NSString *)path {

// 	[self _dismissDisplayAnimated:YES];
// 	NSURL *fileURLPathSF = [NSURL fileURLWithPath:path];
// 	[self _chooseFiles:[NSArray arrayWithObject:fileURLPathSF] displayString:[path lastPathComponent] iconImage:nil];
// }

// %new
// - (BOOL)fileBrowser:(MFFileBrowserViewController *)browser shouldDeleteFileAtPath:(NSString *)path {
//     return NO;
// }
// %new
// - (void)fileBrowser:(MFFileBrowserViewController *)browser didLoadDirectory:(NSString *)path {

// }
// %end
// %end

%ctor {
	@autoreleasepool {
		if (IS_OS_9_OR_LATER) {
			%init(main9);
		}
		// else {
		// 	%init(main8);
		// } 
	}
}
