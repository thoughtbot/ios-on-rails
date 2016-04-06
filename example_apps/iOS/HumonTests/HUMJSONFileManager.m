#import "HUMJSONFileManager.h"

static NSString *const HUMSingleTestEventFileName = @"HUMEventJson.json";

@implementation HUMJSONFileManager

+ (NSDictionary *)singleEventJSON
{
    NSDictionary *dictionary;
    NSString *filePath = [[NSBundle bundleForClass:[self class]]
    pathForResource:[HUMSingleTestEventFileName stringByDeletingPathExtension]
    ofType:[HUMSingleTestEventFileName pathExtension]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *error;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&error];

    if (!error && [result isKindOfClass:[NSDictionary class]]) {
        dictionary = result;
    } else {
        NSLog(@"ERROR CREATING JSON DICTIONARY: %@", error);
    }

    return dictionary;
}

+ (NSArray *)multipleEventsJSON
{
    NSDictionary *singleEventJSON = [self singleEventJSON];

    if (!singleEventJSON) {
        return @[];
    } else {
        return @[[singleEventJSON copy], [singleEventJSON copy]];
    }
}

@end
