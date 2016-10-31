#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface MultiColorizedResult : NSObject;
@property (nonatomic, copy) NSString *modifiedPath;
@property (nonatomic) float hue;
@property (nonatomic) float saturation;
@end

@interface MultiColorizer : NSObject

+(MultiColorizedResult *)multiColorizedResultFor:(NSString *)path;
+(CGImageRef *)cgImageForImage:(UIImage *)image result:(MultiColorizedResult *)result;

@end
