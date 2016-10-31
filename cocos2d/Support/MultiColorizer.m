#import "MultiColorizer.h"

@implementation MultiColorizedResult
@end

@implementation MultiColorizer

+(MultiColorizedResult *)multiColorizedResultFor:(NSString *)path {
    NSArray *components = [[path lowercaseString] componentsSeparatedByString:@"."];
    if (![[components lastObject] isEqualToString:@"png"]) return nil;
    NSString *modifiedPath = [self modifiedPathFor:components];
    if (!modifiedPath) return nil;

    NSString *colorString = [components lastObject];
    MultiColorizedResult *result = [[MultiColorizedResult alloc] init];
    result.modifiedPath = modifiedPath;

    result.hue        = [self hueForColor:colorString];
    result.saturation = [self saturationForColor:colorString];

    return result;
}

+(CGImageRef *)cgImageForImage:(UIImage *)image result:(MultiColorizedResult *)result {
    if (result) {
        return [[self imageWithImage:image rotatedByHue:result.hue saturation:result.saturation] CGImage];
    } else {
        return [image CGImage];
    }
}

+(float)hueForColor:(NSString *)colorString {
    NSArray *hueAndSaturation = [self hueAndSaturationFor:colorString];
    return [[hueAndSaturation firstObject] floatValue];
}

+(float)saturationForColor:(NSString *)colorString {
    NSArray *hueAndSaturation = [self hueAndSaturationFor:colorString];
    return [[hueAndSaturation lastObject] floatValue];
}

+(NSArray *)hueAndSaturationFor:(NSString *)colorString {
    NSDictionary *hueAndSaturationTable = [[self configuration] firstObject];
    return [hueAndSaturationTable objectForKey:colorString];
}

+(NSArray *)configuration {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userPrefsMultiColorizerConfiguration"];
}

+(NSString *)modifiedPathFor:(NSArray *)components {
    if ([components count] <= 1) return nil;
    NSDictionary *fileMappings = [[self configuration] lastObject];
    NSMutableArray *mutableComponents = [components mutableCopy];
    [mutableComponents removeLastObject];
    NSString *key = [mutableComponents componentsJoinedByString:@"_"];
    return [fileMappings objectForKey:key];
}

+(UIImage *)imageWithImage:(UIImage *)image rotatedByHue:(CGFloat)hue saturation:(CGFloat)saturation {
    if (!hue && saturation == 1.0f) return image;
    CIImage *sourceCore = [CIImage imageWithCGImage:[image CGImage]];
    
    CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
    [hueAdjust setDefaults];
    [hueAdjust setValue:sourceCore forKey: @"inputImage"];
    [hueAdjust setValue:[NSNumber numberWithFloat:hue] forKey:@"inputAngle"];
    CIImage *resultCore = [hueAdjust outputImage];
    
    CIFilter *saturationAdjust = [CIFilter filterWithName:@"CIColorControls"];
    [saturationAdjust setValue:resultCore forKey:kCIInputImageKey];
    [saturationAdjust setValue:[NSNumber numberWithFloat:saturation] forKey:kCIInputSaturationKey];
    resultCore = [saturationAdjust outputImage];

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef resultRef = [context createCGImage:resultCore fromRect:[resultCore extent]];
    UIImage *result = [UIImage imageWithCGImage:resultRef];
    CGImageRelease(resultRef);
    
    return result;
}

@end

