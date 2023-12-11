//
//  JSONValueTransformer.m
//  JSONModel
//

#import "JSONValueTransformer.h"

#pragma mark - functions
extern BOOL isNull(id value)
{
    if (!value) return YES;
    if ([value isKindOfClass:[NSNull class]]) return YES;

    return NO;
}

@implementation JSONValueTransformer

-(id)init
{
    self = [super init];
    if (self) {
        _primitivesNames = @{@"f":@"float", @"i":@"int", @"d":@"double", @"l":@"long", @"B":@"BOOL", @"s":@"short",
                             @"I":@"unsigned int", @"L":@"usigned long", @"q":@"long long", @"Q":@"unsigned long long", @"S":@"unsigned short", @"c":@"char", @"C":@"unsigned char",
                             //and some famous aliases of primitive types
                             // BOOL is now "B" on iOS __LP64 builds
                             @"I":@"NSInteger", @"Q":@"NSUInteger", @"B":@"BOOL",

                             @"@?":@"Block"};
    }
    return self;
}

+(Class)classByResolvingClusterClasses:(Class)sourceClass
{
    //check for all variations of strings
    if ([sourceClass isSubclassOfClass:[NSString class]]) {
        return [NSString class];
    }

    //check for all variations of numbers
    if ([sourceClass isSubclassOfClass:[NSNumber class]]) {
        return [NSNumber class];
    }

    //check for all variations of dictionaries
    if ([sourceClass isSubclassOfClass:[NSArray class]]) {
        return [NSArray class];
    }

    //check for all variations of arrays
    if ([sourceClass isSubclassOfClass:[NSDictionary class]]) {
        return [NSDictionary class];
    }

    //check for all variations of dates
    if ([sourceClass isSubclassOfClass:[NSDate class]]) {
        return [NSDate class];
    }

    //no cluster parent class found
    return sourceClass;
}

#pragma mark - NSMutableString <-> NSString
-(NSMutableString*)NSMutableStringFromNSString:(NSString*)string
{
    return [NSMutableString stringWithString:string];
}

#pragma mark - NSMutableArray <-> NSArray
-(NSMutableArray*)NSMutableArrayFromNSArray:(NSArray*)array
{
    return [NSMutableArray arrayWithArray:array];
}

#pragma mark - NSMutableDictionary <-> NSDictionary
-(NSMutableDictionary*)NSMutableDictionaryFromNSDictionary:(NSDictionary*)dict
{
    return [NSMutableDictionary dictionaryWithDictionary:dict];
}

#pragma mark - NSSet <-> NSArray
-(NSSet*)NSSetFromNSArray:(NSArray*)array
{
    return [NSSet setWithArray:array];
}

-(NSMutableSet*)NSMutableSetFromNSArray:(NSArray*)array
{
    return [NSMutableSet setWithArray:array];
}

-(id)JSONObjectFromNSSet:(NSSet*)set
{
    return [set allObjects];
}

-(id)JSONObjectFromNSMutableSet:(NSMutableSet*)set
{
    return [set allObjects];
}

//
// 0 converts to NO, everything else converts to YES
//

#pragma mark - BOOL <-> number/string
-(NSNumber*)BOOLFromNSNumber:(NSNumber*)number
{
    if (isNull(number)) return [NSNumber numberWithBool:NO];
    return [NSNumber numberWithBool: number.intValue==0?NO:YES];
}

-(NSNumber*)BOOLFromNSString:(NSString*)string
{
    if (string != nil &&
        ([string caseInsensitiveCompare:@"true"] == NSOrderedSame ||
        [string caseInsensitiveCompare:@"yes"] == NSOrderedSame)) {
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool: ([string intValue]==0)?NO:YES];
}

-(NSNumber*)JSONObjectFromBOOL:(NSNumber*)number
{
    return [NSNumber numberWithBool: number.intValue==0?NO:YES];
}

#pragma mark - string/number <-> float
-(float)floatFromObject:(id)obj
{
    return [obj floatValue];
}

-(float)floatFromNSString:(NSString*)string
{
    return [self floatFromObject:string];
}

-(float)floatFromNSNumber:(NSNumber*)number
{
    return [self floatFromObject:number];
}

-(NSNumber*)NSNumberFromfloat:(float)f
{
    return [NSNumber numberWithFloat:f];
}

#pragma mark - string <-> number
-(NSNumber*)NSNumberFromNSString:(NSString*)string
{
    return [NSNumber numberWithDouble:[string doubleValue]];
}

-(NSString*)NSStringFromNSNumber:(NSNumber*)number
{
    return [number stringValue];
}

-(NSDecimalNumber*)NSDecimalNumberFromNSString:(NSString*)string
{
    return [NSDecimalNumber decimalNumberWithString:string];
}

-(NSString*)NSStringFromNSDecimalNumber:(NSDecimalNumber*)number
{
    return [number stringValue];
}

#pragma mark - string <-> url
-(NSURL*)NSURLFromNSString:(NSString*)string
{
    // do not change this behavior - there are other ways of overriding it
    // see: https://github.com/jsonmodel/jsonmodel/pull/119
    return [NSURL URLWithString:string];
}

-(NSString*)JSONObjectFromNSURL:(NSURL*)url
{
    return [url absoluteString];
}

#pragma mark - string <-> date
-(NSDateFormatter*)importDateFormatter
{
    static dispatch_once_t onceInput;
    static NSDateFormatter* inputDateFormatter;
    dispatch_once(&onceInput, ^{
        inputDateFormatter = [[NSDateFormatter alloc] init];
        [inputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [inputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HHmmssZZZ"];
    });
    return inputDateFormatter;
}

-(NSDate*)__NSDateFromNSString:(NSString*)string
{
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@""]; // this is such an ugly code, is this the only way?
    return [self.importDateFormatter dateFromString: string];
}

-(NSString*)__JSONObjectFromNSDate:(NSDate*)date
{
    static dispatch_once_t onceOutput;
    static NSDateFormatter *outputDateFormatter;
    dispatch_once(&onceOutput, ^{
        outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [outputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    });
    return [outputDateFormatter stringFromDate:date];
}

#pragma mark - number <-> date
- (NSDate*)NSDateFromNSNumber:(NSNumber*)number
{
    return [NSDate dateWithTimeIntervalSince1970:number.doubleValue];
}

#pragma mark - string <-> NSTimeZone

- (NSTimeZone *)NSTimeZoneFromNSString:(NSString *)string {
    return [NSTimeZone timeZoneWithName:string];
}

- (id)JSONObjectFromNSTimeZone:(NSTimeZone *)timeZone {
    return [timeZone name];
}

#pragma mark - hidden transform for empty dictionaries
//https://github.com/jsonmodel/jsonmodel/issues/163
-(NSDictionary*)__NSDictionaryFromNSArray:(NSArray*)array
{
    if (array.count==0) return @{};
    return (id)array;
}

-(NSMutableDictionary*)__NSMutableDictionaryFromNSArray:(NSArray*)array
{
    if (array.count==0) return [[self __NSDictionaryFromNSArray:array] mutableCopy];
    return (id)array;
}

@end
