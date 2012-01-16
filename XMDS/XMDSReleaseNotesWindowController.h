//
//  XMDSReleaseNotesWindowController.h
//  XMDS
//
//  Created by Graham Dennis on 16/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface XMDSReleaseNotesWindowController : NSWindowController <NSWindowDelegate>
{
    WebView *_releaseNotesView;
    BOOL webViewFinishedLoading;
}

@property (nonatomic, retain) IBOutlet WebView *releaseNotesView;
@end
