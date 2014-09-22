#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>

int main(int argc, char**argv)
{
    char *new_path_to_launch = NULL;
    @autoreleasepool {
        uint32_t bufsize = 0;
        char *buffer = NULL;
        _NSGetExecutablePath(buffer, &bufsize);
        buffer = (char*) malloc(bufsize);
        _NSGetExecutablePath(buffer, &bufsize);
        NSString *fullProcessPath = [NSString stringWithUTF8String:buffer];
        free(buffer);
        
        NSString *lastComponent = [fullProcessPath lastPathComponent];
        NSString *basePath = [fullProcessPath stringByDeletingLastPathComponent];
        NSString *componentToAppend = [NSString stringWithUTF8String:PATH_COMPONENT_TO_APPEND];
        NSString *pathToLaunch = [[NSString pathWithComponents:@[basePath, componentToAppend, lastComponent]] stringByStandardizingPath];
        new_path_to_launch = strdup([pathToLaunch UTF8String]);
    }
    
    argv[0] = new_path_to_launch;
    execv(new_path_to_launch, argv);
    
    @autoreleasepool {
        NSLog(@"Failed to launch subprocess \"%s\" with error: %i.", new_path_to_launch, errno);
    }
    
    return 0;
}