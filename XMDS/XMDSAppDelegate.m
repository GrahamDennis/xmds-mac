//
//  XMDSAppDelegate.m
//  XMDS
//
//  Created by Graham Dennis on 10/01/12.
//  Copyright (c) 2012 Australian National University. All rights reserved.
//

#import "XMDSAppDelegate.h"

@interface XMDSAppDelegate ()

- (NSString *)writeTerminalFile;

@end

@implementation XMDSAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

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

    return libraryPath;
}

- (IBAction)launchXMDSTerminal:(id)sender
{
    NSString *terminalPath = [self writeTerminalFile];
    if (!terminalPath) return;
    
    NSURL *terminalURL = [NSURL fileURLWithPath:terminalPath];
    
    LSOpenCFURLRef((CFURLRef)terminalURL, NULL);
}

- (NSString *)writeTerminalFile
{
    NSString *terminalTemplatePath = [[NSBundle mainBundle] pathForResource:@"XMDS"
                                                                     ofType:@"terminal"];
    
    if (!terminalTemplatePath) {
        NSLog(@"Couldn't find XMDS.terminal");
        return nil;
    }
    
    NSError *error = nil;
    
    NSString *terminalContents = [NSString stringWithContentsOfFile:terminalTemplatePath
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
    
    if (error) {
        NSLog(@"Couldn't read XMDS.terminal content. Error: %@", error);
        return nil;
    }
    
    NSString *interpolatedTerminalContent = [terminalContents stringByReplacingOccurrencesOfString:@"${XMDS_USR}"
                                                                                        withString:self.usrPath];
    
    NSString *terminalPath = [self.xmdsLibraryPath stringByAppendingPathComponent:@"XMDS.terminal"];
    
    BOOL result = [interpolatedTerminalContent writeToFile:terminalPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (!result || error) {
        NSLog(@"Unable to write terminal file to path: %@. Error: %@", terminalPath, error);
        return nil;
    }
        
    return terminalPath;
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

- (NSArray *)documentationPaths
{
    return [NSArray arrayWithObjects:[self.xmdsLibraryPath stringByAppendingPathComponent:@"src/xmds2/documentation"],
                                     [self.usrPath stringByAppendingPathComponent:@"share/xmds/documentation"],
                                     nil];
}


@end
