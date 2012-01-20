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

- (BOOL)interpolateTerminalTemplateWithParameters:(NSDictionary *)parameters toFile:(NSString *)path;

@end

@implementation XMDSAppDelegate

@synthesize window = _window;
@synthesize updateWindow = _updateWindow;
@synthesize releaseNotesWindow = _releaseNotesWindow;

- (void)dealloc
{
    self.updateWindow = nil;
    self.releaseNotesWindow = nil;
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [self checkForXcodeApp:nil];
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

- (IBAction)checkForXcodeApp:(id)sender
{
    NSString *xcodeCheckAlertSuppress = @"XcodeAlertSuppress";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:xcodeCheckAlertSuppress])
        return;
    
    
    if (![[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.dt.Xcode"] && // Xcode 4
        ![[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.Xcode"])      // Xcode 3
    {
        NSAlert *alert = [[NSAlert alloc] init];
        BOOL haveMacAppStore = ([[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.appstore"] != nil);
        
        
        [alert setMessageText:@"Xcode is needed to use XMDS"];
        
        NSURL *targetURL = nil;
        
        if (haveMacAppStore) {
            [alert setInformativeText:@"The Apple development tool, Xcode is required to compile and run simulations generated by XMDS. Xcode can be installed for free from the Mac App Store."];
            [alert addButtonWithTitle:@"Go to Mac App Store"];
            targetURL = [NSURL URLWithString:@"macappstore://itunes.apple.com/us/app/xcode/id448457090?mt=12"];
        } else {
            [alert setInformativeText:@"The Apple development tool, Xcode is required to compile and run simulations generated by XMDS. Xcode can be downloaded from the Apple Developer website."];
            [alert addButtonWithTitle:@"Go to Xcode website"];
            targetURL = [NSURL URLWithString:@"http://developer.apple.com/xcode/"];
        }
        [alert addButtonWithTitle:@"Dismiss"];
        [alert setShowsSuppressionButton:YES];
        
        NSInteger selectedButtonID = [alert runModal];
        
        if (selectedButtonID == NSAlertFirstButtonReturn && targetURL) {
            [[NSWorkspace sharedWorkspace] openURL:targetURL];
        }
        
        if ([[alert suppressionButton] state] == NSOnState) {
            // Suppress this alert
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:xcodeCheckAlertSuppress];
        }
        
        [alert release];
    }
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
    NSString *terminalFilePath = [self.xmdsLibraryPath stringByAppendingPathComponent:@"XMDS.terminal"];
    
    BOOL result = [self interpolateTerminalTemplateWithParameters:nil
                                                           toFile:terminalFilePath];
    
    return result ? terminalFilePath : nil; 
}

- (NSString *)writeXMDSUpdateTerminalFileWithRevision:(NSNumber *)revision
{
    NSString *additionalCommand = @"update-xmds2";
    
    if (revision)
        additionalCommand = [additionalCommand stringByAppendingFormat:@" --revision %@", revision];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:additionalCommand
                                                           forKey:@"${ADDITIONAL_COMMANDS}"];
    
    NSString *terminalUpdateFile = [self.xmdsLibraryPath stringByAppendingPathComponent:@"XMDS-update.terminal"];
    
    BOOL result = [self interpolateTerminalTemplateWithParameters:parameters
                                                           toFile:terminalUpdateFile];
    
    return result ? terminalUpdateFile : nil;
}

- (BOOL)interpolateTerminalTemplateWithParameters:(NSDictionary *)parameters toFile:(NSString *)path
{
    NSString *terminalTemplatePath = [[NSBundle mainBundle] pathForResource:@"XMDS"
                                                                     ofType:@"terminal"];
    
    if (!terminalTemplatePath) {
        NSLog(@"Couldn't find XMDS.terminal");
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
    
    NSMutableDictionary *allParameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          self.usrPath, @"${XMDS_USR}",
                                          @"XMDS", @"${NAME}",
                                          @"", @"${ADDITIONAL_COMMANDS}",
                                          nil];
    
    [allParameters addEntriesFromDictionary:parameters];
    
    for (NSString *key in allParameters) {
        terminalContents = [terminalContents stringByReplacingOccurrencesOfString:key
                                                                       withString:[allParameters objectForKey:key]];
    }
    
    BOOL result = [terminalContents writeToFile:path
                                     atomically:YES
                                       encoding:NSUTF8StringEncoding
                                          error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to write terminal file to path: %@. Error: %@", path, error);
        return FALSE;
    }
    
    return YES;    
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
