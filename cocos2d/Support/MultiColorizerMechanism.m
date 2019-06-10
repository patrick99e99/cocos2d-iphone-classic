#import "MultiColorizerMechanism.h"

@implementation MultiColorizedResult
@end

@implementation MultiColorizerMechanism

+(MultiColorizedResult *)multiColorizedResultFor:(NSString *)path {
    NSArray *components = [[path lowercaseString] componentsSeparatedByString:@"."];
    if (![[components lastObject] isEqualToString:@"png"]) {
        return nil;
    }
    
    NSArray *subComponents = [[components firstObject] componentsSeparatedByString:@"_"];
    NSString *modifiedPath = [self modifiedPathFor:subComponents];
    if (!modifiedPath) {
        return nil;
    }

    NSString *colorString = [subComponents lastObject];

    MultiColorizedResult *result = [[MultiColorizedResult alloc] init];
    result.modifiedPath = modifiedPath;

    result.hue        = [self hueForColor:colorString];
    result.saturation = [self saturationForColor:colorString];
    result.matrix     = [self matrixForColor:colorString];

    return result;
}

+(CGImageRef *)cgImageForImage:(UIImage *)image result:(MultiColorizedResult *)result context:(CIContext *)context {
    if (result) {
        return [[self imageWithImage:image rotatedByHue:result.hue saturation:result.saturation matrix:result.matrix context:context] CGImage];
    } else {
        return [image CGImage];
    }
}

+(float)hueForColor:(NSString *)colorString {
    NSNumber *hue = [self colorDataObjectForKey:@"hue" colorString:colorString];
    return [hue floatValue];
}

+(float)saturationForColor:(NSString *)colorString {
    NSNumber *saturation = [self colorDataObjectForKey:@"saturation" colorString:colorString];
    return [saturation floatValue];
}

+(NSArray *)matrixForColor:(NSString *)colorString {
    return [self colorDataObjectForKey:@"matrix" colorString:colorString];
}

+(NSArray *)configuration {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userPrefsMultiColorizerConfiguration"];
}

+(id)colorDataObjectForKey:(NSString *)key colorString:(NSString *)colorString {
    NSDictionary *colorData = [[[self configuration] firstObject] objectForKey:colorString];
    return [colorData objectForKey:key];
}

+(NSString *)modifiedPathFor:(NSArray *)components {
    if ([components count] <= 1) return nil;
    NSDictionary *fileMappings = [[self configuration] lastObject];
    NSMutableArray *mutableComponents = [components mutableCopy];
    [mutableComponents removeLastObject];
    NSString *key = [mutableComponents componentsJoinedByString:@"_"];
    [mutableComponents release];
    return [fileMappings objectForKey:key];
}

+(UIImage *)imageWithImage:(UIImage *)image rotatedByHue:(CGFloat)hue saturation:(CGFloat)saturation matrix:(NSArray *)matrix context:(CIContext *)context {
    CIImage *sourceCore = [CIImage imageWithCGImage:[image CGImage]];
    CIImage *resultCore = nil;

    if (hue != 0.0f) {
        CIFilter *hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
        [hueAdjust setDefaults];
        [hueAdjust setValue:sourceCore forKey:kCIInputImageKey];
        [hueAdjust setValue:[NSNumber numberWithFloat:hue] forKey:kCIInputAngleKey];
        resultCore = [hueAdjust outputImage];
    }
    
    if (saturation != 1.0f) {
        CIFilter *saturationAdjust = [CIFilter filterWithName:@"CIColorControls"];
        [saturationAdjust setValue:(resultCore ? resultCore : sourceCore) forKey:kCIInputImageKey];
        [saturationAdjust setValue:[NSNumber numberWithFloat:saturation] forKey:kCIInputSaturationKey];
        resultCore = [saturationAdjust outputImage];
    }

    if (matrix) {
        CIFilter *colorMatrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
        [colorMatrixFilter setDefaults];
        [colorMatrixFilter setValue:(resultCore ? resultCore : sourceCore) forKey:kCIInputImageKey];
        [colorMatrixFilter setValue:[self vectorForMatrixRow:matrix[0]] forKey:@"inputRVector"];
        [colorMatrixFilter setValue:[self vectorForMatrixRow:matrix[1]] forKey:@"inputGVector"];
        [colorMatrixFilter setValue:[self vectorForMatrixRow:matrix[2]] forKey:@"inputBVector"];
        [colorMatrixFilter setValue:[self vectorForMatrixRow:matrix[3]] forKey:@"inputAVector"];
        [colorMatrixFilter setValue:[self vectorForMatrixRow:matrix[4]] forKey:@"inputBiasVector"];
        resultCore = [colorMatrixFilter outputImage];
    }

    CGImageRef *resultRef = [context createCGImage:resultCore fromRect:[resultCore extent]];
    UIImage *result = [UIImage imageWithCGImage:resultRef];
    CGImageRelease(resultRef);

    return result;
}

+(CIVector *)vectorForMatrixRow:(NSArray *)row {
    return [CIVector vectorWithX:[row[0] floatValue] Y:[row[1] floatValue] Z:[row[2] floatValue] W:[row[3] floatValue]];
}

@end

