//
//  XMDSReleaseNotesWindowController.m
//  XMDS
//
//  Created by Graham Dennis on 16/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import "XMDSReleaseNotesWindowController.h"

#import <WebKit/WebKit.h>

@implementation XMDSReleaseNotesWindowController

@synthesize releaseNotesView = _releaseNotesView;

- (void)dealloc
{
    self.releaseNotesView = nil;
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [self.releaseNotesView setFrameLoadDelegate:self];
	[self.releaseNotesView setPolicyDelegate:self];

    NSURL *releaseNotesURL = [[NSBundle mainBundle] URLForResource:@"release-notes" withExtension:@"html"];
//    releaseNotesURL = [releaseNotesURL URLByAppendingPathExtension:@"#version-2.0"];
    NSLog(@"releaseNotesURL: %@", releaseNotesURL);
    [[self.releaseNotesView mainFrame] loadRequest:[NSURLRequest requestWithURL:releaseNotesURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.window setDelegate:nil];
    [self.releaseNotesView setFrameLoadDelegate:nil];
    [self.releaseNotesView setPolicyDelegate:nil];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:frame
{
    if ([frame parentFrame] == nil) {
        webViewFinishedLoading = YES;
    }
}

- (void)webView:sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:frame decisionListener:listener
{
    if (webViewFinishedLoading) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
		
        [listener ignore];
    }    
    else {
        [listener use];
    }
}

// Clean up the contextual menu.
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMutableArray *webViewMenuItems = [[defaultMenuItems mutableCopy] autorelease];
	
	if (webViewMenuItems)
	{
		NSEnumerator *itemEnumerator = [defaultMenuItems objectEnumerator];
		NSMenuItem *menuItem = nil;
		while ((menuItem = [itemEnumerator nextObject]))
		{
			NSInteger tag = [menuItem tag];
			
			switch (tag)
			{
				case WebMenuItemTagOpenLinkInNewWindow:
				case WebMenuItemTagDownloadLinkToDisk:
				case WebMenuItemTagOpenImageInNewWindow:
				case WebMenuItemTagDownloadImageToDisk:
				case WebMenuItemTagOpenFrameInNewWindow:
				case WebMenuItemTagGoBack:
				case WebMenuItemTagGoForward:
				case WebMenuItemTagStop:
				case WebMenuItemTagReload:		
					[webViewMenuItems removeObjectIdenticalTo: menuItem];
			}
		}
	}
	
	return webViewMenuItems;
}


@end
