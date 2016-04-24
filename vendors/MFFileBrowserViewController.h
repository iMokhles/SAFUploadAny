//
// MFFileBrowserViewController.h
//
// Mokhlas Hussein on 26/11/2014 
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <unistd.h>
#import <stdlib.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <imounbox/imounbox.h> // get from iMoDevTools cydia package
#include <objc/runtime.h>
#include <dlfcn.h>

@class MFFileBrowserViewController;

@protocol MFFileBrowserViewControllerDelegate <NSObject>
- (void)fileBrowser:(MFFileBrowserViewController *)browser didSelectFile:(NSString *)path;
- (BOOL)fileBrowser:(MFFileBrowserViewController *)browser shouldDeleteFileAtPath:(NSString *)path;
@optional
- (void)fileBrowser:(MFFileBrowserViewController *)browser didLoadDirectory:(NSString *)path;
- (void)fileBrowserDidCancelled:(MFFileBrowserViewController *)browser;
@end

@interface MFFileBrowserViewController: UITableViewController {
	NSFileManager *fileManager;
	NSString *path;
	NSMutableArray *contents;
	id <MFFileBrowserViewControllerDelegate> _delegate;
}

@property (nonatomic, readonly) NSString *path;
@property (nonatomic, assign) id <MFFileBrowserViewControllerDelegate> delegate;

@end