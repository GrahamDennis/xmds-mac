//
//  XMDSAppDelegate.m
//  XMDS
//
//  Created by Graham Dennis on 10/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import "XMDSAppDelegate.h"

@interface XMDSAppDelegate ()

- (NSString *)writeXMDSTerminalFile;
- (NSString *)writeXMDSUpdateTerminalFileWithRevision:(NSString *)revision;

- (NSString *)interpolateTerminalTemplateWithParameters:(NSDictionary *)parameters withSuffix:(NSString *)path;

- (IBAction)askUserToInstallDevTools:(id)sender;

@property (readonly) NSString *usrPath;
@property (readonly) NSString *xmdsLibraryPath;
@property (readonly) NSArray *documentationPaths;
@property (nonatomic, retain) NSString *xcodeDeveloperPath;

@end

@implementation XMDSAppDelegate

@synthesize window = _window;
@synthesize updateWindow = _updateWindow;
@synthesize releaseNotesWindow = _releaseNotesWindow;
@synthesize xcodeDeveloperPath = _xcodeDeveloperPath;

- (void)dealloc
{
    self.updateWindow = nil;
    self.releaseNotesWindow = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self checkForDeveloperTools:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)launchXMDSTerminal:(id)sender
{
    NSString *terminalPath = [self writeXMDSTerminalFile];
    if (!terminalPath) return;
    
    NSURL *terminalURL = [NSURL fileURLWithPath:terminalPath];
    
    LSOpenCFURLRef((CFURLRef)terminalURL, NULL);
}

- (void)launchXMDSUpdateTerminalToRevision:(NSString *)revision
{
    NSString *terminalPath = [self writeXMDSUpdateTerminalFileWithRevision:revision];
    if (!terminalPath) return;
    
    NSURL *terminalURL = [NSURL fileURLWithPath:terminalPath];
    
    LSOpenCFURLRef((CFURLRef)terminalURL, NULL);
}

- (IBAction)showHelp:(id)sender
{
    for (NSString *documentationPath in self.documentationPaths) {
        NSString *documentationRoot = [documentationPath stringByAppendingPathComponent:@"index.html"];
        
        if ([[NSFileManager defaultManager] isReadableFileAtPath:documentationRoot]) {
            if ([[NSWorkspace sharedWorkspace] openFile:documentationRoot])
                return;
        }
    }
}

- (IBAction)orderFrontUpdateToDevelopmentVersionWindow:(id)sender
{
    if (!self.updateWindow) {
        NSNib *updateWindowNib;
        
        updateWindowNib = [[NSNib alloc] initWithNibNamed:@"DevelopmentVersionUpdateWindow"
                                                   bundle:nil];
        
        [updateWindowNib instantiateNibWithOwner:self
                                 topLevelObjects:nil];
        
        [updateWindowNib release];
    }
    
    if (!self.updateWindow) {
        NSLog(@"Couldn't create update window");
        return;
    }
    
    [self.updateWindow makeKeyAndOrderFront:sender];
}

- (IBAction)checkForDeveloperTools:(id)sender
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/g++"]) {
        // Just use the root directory tools
        self.xcodeDeveloperPath = @"";
        return;
    }
    
    NSString *xcodeAppPath = nil;
    
    // Check for Xcode 4
    xcodeAppPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.dt.Xcode"];
    
    // Couldn't find it, search for Xcode 3
    if (!xcodeAppPath)
        xcodeAppPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.Xcode"];
    
    if (!xcodeAppPath) {
        return [self askUserToInstallDevTools:sender];
    }
    
    NSString *xcodeVersion = nil;
    
    if (xcodeAppPath) {
        NSBundle *xcodeBundle = [NSBundle bundleWithPath:xcodeAppPath];
        xcodeVersion = [[xcodeBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    
    if (xcodeVersion) {
        NSComparisonResult result = [xcodeVersion compare:@"4.3" options:NSNumericSearch];
        // Xcode 4.3 or later, Developer tools are in Xcode.app/Contents/Developer
        if (result == NSOrderedSame || result == NSOrderedDescending) {
            self.xcodeDeveloperPath = [xcodeAppPath stringByAppendingPathComponent:@"Contents/Developer"];
        } else {
            // Go from /Developer/Applications/Xcode.app to /Developer
            self.xcodeDeveloperPath = [[xcodeAppPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        }
    } else {
        NSLog(@"Couldn't work out Xcode version, despite finding it here: %@", xcodeAppPath);
    }

}

- (IBAction)askUserToInstallDevTools:(id)sender
{
    NSString *xcodeCheckAlertSuppress = @"XcodeAlertSuppress";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:xcodeCheckAlertSuppress])
        return;
    
    NSAlert *alert = [[NSAlert alloc] init];
    BOOL haveMacAppStore = ([[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.appstore"] != nil);
    
    
    [alert setMessageText:@"Developer Tools are needed to use XMDS"];
    
    NSMutableArray *targetURLs = [NSMutableArray array];
    
    if (haveMacAppStore) {
        [alert setInformativeText:@"Mac Developer Tools are required to compile and run simulations generated by XMDS.\nYou can either install Xcode for free from the Mac App Store (~1.3Gb download) or you can download and install the Command Line Tools for Xcode (~170Mb download).  Installing Command Line Tools requires signing up for the free Apple Developer Program."];

        [alert addButtonWithTitle:@"Get Command Line Tools"];
        [targetURLs addObject:[NSURL URLWithString:@"https://developer.apple.com/downloads/index.action?=Command%20Line%20Tools"]];
        
        [alert addButtonWithTitle:@"Get Xcode from the Mac App Store"];
        [targetURLs addObject:[NSURL URLWithString:@"macappstore://itunes.apple.com/us/app/xcode/id497799835?mt=12"]];

    } else {
        [alert setInformativeText:@"The Apple development tool, Xcode is required to compile and run simulations generated by XMDS. Xcode can be downloaded from the Apple Developer website."];
        [alert addButtonWithTitle:@"Go to Xcode website"];
        [targetURLs addObject:[NSURL URLWithString:@"http://developer.apple.com/xcode/"]];
    }
    [alert addButtonWithTitle:@"Dismiss"];
    [alert setShowsSuppressionButton:YES];
    
    NSInteger selectedButtonID = [alert runModal];
    
    if (selectedButtonID == NSAlertFirstButtonReturn && targetURLs) {
        [[NSWorkspace sharedWorkspace] openURL:[targetURLs objectAtIndex:0]];
    }
    
    if (selectedButtonID == NSAlertSecondButtonReturn && targetURLs) {
        [[NSWorkspace sharedWorkspace] openURL:[targetURLs objectAtIndex:1]];
    }
    
    if ([[alert suppressionButton] state] == NSOnState) {
        // Suppress this alert
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:xcodeCheckAlertSuppress];
    }
    
    [alert release];
}


- (IBAction)openXMDSHomepage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.xmds.org"]];
}

- (IBAction)openReleaseNotes:(id)sender
{
    if (!self.releaseNotesWindow) {
        NSNib *releaseNotesWindowNib;
        
        releaseNotesWindowNib = [[NSNib alloc] initWithNibNamed:@"ReleaseNotes"
                                                   bundle:nil];
        
        [releaseNotesWindowNib instantiateNibWithOwner:self
                                 topLevelObjects:nil];
        
        [releaseNotesWindowNib release];
    }
    
    if (!self.releaseNotesWindow) {
        NSLog(@"Couldn't create release notes window");
        return;
    }
    
    [self.releaseNotesWindow makeKeyAndOrderFront:sender];
}

- (IBAction)signupForUserForum:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://lists.sourceforge.net/lists/listinfo/xmds-user"]];
}

- (IBAction)emailUserForum:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:xmds-user@lists.sourceforge.net"]];
}

- (IBAction)viewUserForumArchives:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/mailarchive/forum.php?forum_name=xmds-user"]];
}


#pragma mark Terminal file writing

- (NSString *)writeXMDSTerminalFile
{
    NSString *terminalFilePath = [self interpolateTerminalTemplateWithParameters:nil
                                                                      withSuffix:terminalFilePath];
    
    return terminalFilePath; 
}

- (NSString *)writeXMDSUpdateTerminalFileWithRevision:(NSNumber *)revision
{
    NSString *additionalCommand = @"update-xmds2";
    
    if (revision)
        additionalCommand = [additionalCommand stringByAppendingFormat:@" --revision %@", revision];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:additionalCommand
                                                           forKey:@"${ADDITIONAL_COMMANDS}"];
    
    NSString *terminalUpdateFile = [self interpolateTerminalTemplateWithParameters:parameters
                                                                        withSuffix:@"-update"];
    
    return terminalUpdateFile;
}

- (NSString *)interpolateTerminalTemplateWithParameters:(NSDictionary *)parameters withSuffix:(NSString *)suffix
{
    if (!suffix)
        suffix = @"";
    
    NSString *terminalTemplatePath = [[NSBundle mainBundle] pathForResource:@"XMDS"
                                                                     ofType:@"terminal"];
    
    if (!terminalTemplatePath) {
        NSLog(@"Couldn't find XMDS.terminal");
        return FALSE;
    }
    
    NSString *bashProfilePath = [[NSBundle mainBundle] pathForResource:@"bash_profile" ofType:nil];
    
    if (!bashProfilePath) {
        NSLog(@"Couldn't find bash_profile");
        return FALSE;
    }
    
    NSError *error = nil;
    
    NSString *terminalContents = [NSString stringWithContentsOfFile:terminalTemplatePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
    
    if (error) {
        NSLog(@"Couldn't read XMDS.terminal content. Error: %@", error);
        return FALSE;
    }
    
    NSString *bashProfileContents = [NSString stringWithContentsOfFile:bashProfilePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Couldn't read bash_profile content. Error: %@", error);
        return FALSE;
    }
    
    NSString *terminalFilename = [NSString stringWithFormat:@"XMDS%@.terminal", suffix];
    NSString *bashProfileFilename = [NSString stringWithFormat:@"bash_profile%@", suffix];
    
    NSString *terminalDestinationPath = [self.xmdsLibraryPath stringByAppendingPathComponent:terminalFilename];
    NSString *bashProfileDestinationPath = [self.xmdsLibraryPath stringByAppendingPathComponent:bashProfileFilename];
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          self.usrPath, @"${XMDS_USR}",
                                          self.xcodeDeveloperPath, @"${DEVELOPER_DIR}",
                                          bashProfileDestinationPath, @"${RC_FILE}",
                                          @"XMDS", @"${NAME}",
                                          @"", @"${ADDITIONAL_COMMANDS}",
                                          nil];
    
    [allParameters addEntriesFromDictionary:parameters];
    
    for (NSString *key in allParameters) {
        terminalContents = [terminalContents stringByReplacingOccurrencesOfString:key
                                                                       withString:[allParameters objectForKey:key]];
        bashProfileContents = [bashProfileContents stringByReplacingOccurrencesOfString:key
                                                                             withString:[allParameters objectForKey:key]];
    }
    
    BOOL result = [bashProfileContents writeToFile:bashProfileDestinationPath
                                        atomically:YES
                                          encoding:NSUTF8StringEncoding
                                             error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to write rc file to path: %@. Error: %@", bashProfileDestinationPath, error);
        return FALSE;
    }
    
    result = [terminalContents writeToFile:terminalDestinationPath
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to write terminal file to path: %@. Error: %@", terminalDestinationPath, error);
        return FALSE;
    }
    
    return terminalDestinationPath;
}

#pragma mark Path methods

- (NSString *)usrPath
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/usr"];
}

- (NSString *)xmdsLibraryPath
{
    NSArray *searchURLs = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    
    if (![searchURLs count]) {
        NSLog(@"Empty search paths when looking for the user library directory");
        return nil;
    }
    
    if ([searchURLs count] > 1) 
        NSLog(@"Warning: More than one user library path found: %@", searchURLs);
    
    NSString *libraryPath = [(NSURL *)[searchURLs lastObject] path];
    
    NSString *xmdsLibraryPath = [libraryPath stringByAppendingPathComponent:@"XMDS"];
    
    NSError *error = nil;
    
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:xmdsLibraryPath
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to create path %@. Error: %@", xmdsLibraryPath, error);
        
        return nil;
    }
    
    return xmdsLibraryPath;
}

- (NSArray *)documentationPaths
{
    NSString *userDocumentationPath = [self.xmdsLibraryPath stringByAppendingPathComponent:@"src/xmds2/documentation"];
    NSString *appDocumentationPath = [self.usrPath stringByAppendingPathComponent:@"share/xmds/documentation"];
    
    return [NSArray arrayWithObjects:userDocumentationPath,
                                     appDocumentationPath,
                                     nil];
}


@end
