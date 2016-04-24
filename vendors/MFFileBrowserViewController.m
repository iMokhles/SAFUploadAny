//
// MFFileBrowserViewController.m
//
// Mokhlas Hussein on 26/11/2014 
// Licensed under a CreativeCommons Attribution 3.0 Unported License
//

#import <unistd.h>
#import <sys/types.h>
#import <sys/stat.h>
#import "MFFileBrowserViewController.h"
#import "ZipArchive.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

@interface MFFileBrowserViewController ()
- (id)initWithPath:(NSString *)p;
@end

@implementation MFFileBrowserViewController

@synthesize path, delegate;

// Super

- (id)initWithStyle:(UITableViewStyle)st
{
	return [self initWithPath:@"/"];
}

// Self

- (id)initWithPath:(NSString *)p
{
	if ((self = [super initWithStyle:self.tableView.style])) {
		path = [p copy];
		fileManager = [[NSFileManager alloc] init];
		contents = [[[IMClient sharedInstance] contentsOfDirectory:path] mutableCopy]; // contents of @"/" it uses my iMoDevTools library ( available through bigboss repo )
		[contents sortUsingSelector:@selector(caseInsensitiveCompare:)];
		self.title = [path lastPathComponent];
		[self.tableView reloadData];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *myButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeFileBrowser)];
	self.navigationItem.rightBarButtonItem = myButton;
}

- (void)closeFileBrowser {
	if ([self.delegate respondsToSelector:@selector(fileBrowserDidCancelled:)]) {
		[self.delegate fileBrowserDidCancelled:self];
	}
}

// UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
       return contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"FileBrowserCell";
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellID];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
			reuseIdentifier:cellID];
	}

	NSString *name = [contents objectAtIndex:indexPath.row];
	NSString *childPath = [path stringByAppendingPathComponent:name];
	
	[[IMClient sharedInstance] fileExists:childPath];
	BOOL isDir = [[IMClient sharedInstance] fileIsDirectory:childPath];

	cell.imageView.image = isDir ? [UIImage imageWithContentsOfFile:@"/Library/Application Support/SAFUploadAny/DefaultsImages/Images/folderIcon.png"] : [UIImage imageWithContentsOfFile:@"/Library/Application Support/SAFUploadAny/DefaultsImages/Images/fileIcon.png"];
	cell.textLabel.text = [contents objectAtIndex:indexPath.row];
	cell.accessoryType = isDir ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	
	if (!isDir) {
		struct stat st;
		stat([childPath UTF8String], &st);
		NSMutableString *szStr = [NSMutableString string];
		
		if (st.st_size >= 1024 * 1024 * 1024) {
			[szStr appendFormat:@"%.2f GB", st.st_size / (1024.0f * 1024.0f * 1024.0f)];
		} else if (st.st_size >= 1024 * 1024) {
			[szStr appendFormat:@"%.2f MB", st.st_size / (1024.0f * 1024.0f)];
		} else if (st.st_size >= 1024) {
			[szStr appendFormat:@"%.2f kB", st.st_size / 1024.0f];
		} else {
			[szStr appendFormat:@"%u B", (unsigned)st.st_size];
		}

		cell.detailTextLabel.text = szStr;
	} else {
		cell.detailTextLabel.text = nil;
	}
	
	if (readlink([childPath UTF8String], NULL, 0) != -1) {
		cell.textLabel.textColor = [UIColor colorWithRed:0.1f green:0.3f blue:1.0f alpha:1.0f];
	} 

	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tv deselectRowAtIndexPath:indexPath animated:YES];
	NSString *name = [contents objectAtIndex:indexPath.row];
	NSString *childPath = [path stringByAppendingPathComponent:name];
	NSString *appDataPath;
	NSString *newFilePath;
	NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPath objectAtIndex:0];

	[[IMClient sharedInstance] fileExists:childPath];
	BOOL isDir = [[IMClient sharedInstance] fileIsDirectory:childPath];

	ZipArchive *fileArchiveZip = [[ZipArchive alloc] init];
	NSString *zipFileName = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", [childPath lastPathComponent]]];
	if (isDir) {
		MFFileBrowserViewController *child = [[MFFileBrowserViewController alloc] initWithPath:childPath];
		child.delegate = self.delegate;
		[self.navigationController pushViewController:child animated:YES];
		if ([self.delegate respondsToSelector:@selector(fileBrowser:didLoadDirectory:)]) {
			[self.delegate fileBrowser:self didLoadDirectory:childPath];
		}
	} else {
		NSString *fileExt = [[childPath lastPathComponent] pathExtension];
	    if ([fileExt isEqualToString:@""]) {
	    	if (![fileArchiveZip openZipFile2:zipFileName withZipModel:APPEND_STATUS_ADDINZIP]) {
	    		newFilePath = [NSString stringWithFormat:@"%@/%@.dat", documentPath, name];
		    	[[IMClient sharedInstance] copyFile:childPath toFile:newFilePath];
	    	} else {
	    		[fileArchiveZip addFileToZip:childPath newname:name];
	    	}
	    	if ([self.delegate respondsToSelector:@selector(fileBrowser:didSelectFile:)]) {
	       		[self.delegate fileBrowser:self didSelectFile:zipFileName];
	    	}
	    } else {
	       	newFilePath = [NSString stringWithFormat:@"%@/%@", documentPath, name];
		    [[IMClient sharedInstance] copyFile:childPath toFile:newFilePath];
		    if ([self.delegate respondsToSelector:@selector(fileBrowser:didSelectFile:)]) {
		       	[self.delegate fileBrowser:self didSelectFile:newFilePath];
	    	}
	    }
	}
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)es forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (es == UITableViewCellEditingStyleDelete) {
		NSString *name = [contents objectAtIndex:indexPath.row];
		NSString *childPath = [path stringByAppendingPathComponent:name];
		if ([self.delegate fileBrowser:self shouldDeleteFileAtPath:childPath]) {
			[[IMClient sharedInstance] deleteFile:childPath];
			[contents removeObjectAtIndex:indexPath.row];
			[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		}
	}
}

@end
#pragma clang diagnostic pop

