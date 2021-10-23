#import "FlutterMicroEccPlugin.h"
#if __has_include(<flutter_micro_ecc/flutter_micro_ecc-Swift.h>)
#import <flutter_micro_ecc/flutter_micro_ecc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_micro_ecc-Swift.h"
#endif

@implementation FlutterMicroEccPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMicroEccPlugin registerWithRegistrar:registrar];
}
@end
