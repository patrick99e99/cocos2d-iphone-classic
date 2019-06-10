#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

@interface MultiColorizedResult : NSObject
@property (nonatomic, unsafe_unretained) NSString *modifiedPath;
@property (nonatomic) float hue;
@property (nonatomic) float saturation;
@property (nonatomic, unsafe_unretained) NSArray *matrix;
@end

@interface MultiColorizerMechanism : NSObject

+(MultiColorizedResult *)multiColorizedResultFor:(NSString *)path;
+(CGImageRef *)cgImageForImage:(UIImage *)image result:(MultiColorizedResult *)result context:(CIContext *)context;

@end
