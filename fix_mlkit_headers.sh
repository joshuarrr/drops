#!/bin/bash

# Create directory for the plugin if it doesn't exist
PLUGIN_DIR="$HOME/.pub-cache/hosted/pub.dev/google_mlkit_face_detection-0.10.1/ios/Classes"
mkdir -p "$PLUGIN_DIR"

# Create a fixed version of the plugin implementation with proper header imports
cat > "$PLUGIN_DIR/GoogleMlKitFaceDetectionPlugin.m" <<EOF
#import "GoogleMlKitFaceDetectionPlugin.h"
#import <google_mlkit_commons/GoogleMlKitCommonsPlugin.h>

#if defined(__has_include) && __has_include(<MLKitFaceDetection/MLKitFaceDetection.h>)
#import <MLKitFaceDetection/MLKitFaceDetection.h>
#else
@import MLKitFaceDetection;
#endif

#define channelName @"google_mlkit_face_detector"

@implementation GoogleMlKitFaceDetectionPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [GoogleMlKitCommonsPlugin registerWithRegistrar:registrar];
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:channelName
                                   binaryMessenger:[registrar messenger]];
  GoogleMlKitFaceDetectionPlugin* instance = [[GoogleMlKitFaceDetectionPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"vision#startFaceDetector" isEqualToString:call.method]) {
    [self handleDetection:call result:result];
  } else if([@"vision#closeFaceDetector" isEqualToString:call.method]) {
    NSString *uid = call.arguments[@"id"];
    [FaceDetectorManager.shared closeDetector:uid];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
  MLKFaceDetectorOptions *options = [[MLKFaceDetectorOptions alloc] init];
  
  NSNumber *enableClassification = call.arguments[@"enableClassification"];
  if (enableClassification.boolValue) {
    options.classificationMode = MLKFaceDetectorClassificationModeAll;
  }
  
  NSNumber *enableLandmarks = call.arguments[@"enableLandmarks"];
  if (enableLandmarks.boolValue) {
    options.landmarkMode = MLKFaceDetectorLandmarkModeAll;
  }
  
  NSNumber *enableContours = call.arguments[@"enableContours"];
  if (enableContours.boolValue) {
    options.contourMode = MLKFaceDetectorContourModeAll;
  }
  
  NSNumber *enableTracking = call.arguments[@"enableTracking"];
  options.trackingEnabled = enableTracking.boolValue;
  
  NSNumber *minFaceSize = call.arguments[@"minFaceSize"];
  options.minFaceSize = minFaceSize.doubleValue;
  
  NSString *mode = call.arguments[@"mode"];
  if ([mode isEqualToString:@"accurate"]) {
    options.performanceMode = MLKFaceDetectorPerformanceModeAccurate;
  } else if ([mode isEqualToString:@"fast"]) {
    options.performanceMode = MLKFaceDetectorPerformanceModeFast;
  }
  
  NSString *uid = call.arguments[@"id"];
  MLKFaceDetector *detector = [FaceDetectorManager.shared detectorForOptions:options andID:uid];
  
  NSDictionary *imageData = call.arguments[@"imageData"];
  UIImage *image = [MLKVisionImage visionImageFromData:imageData];
  NSArray<MLKFace *> *faces = [detector resultsInImage:image error:nil];
  
  NSMutableArray *faceData = [NSMutableArray array];
  for (MLKFace *face in faces) {
    NSMutableDictionary *faceMap = [NSMutableDictionary dictionary];
    
    CGRect frame = face.frame;
    NSDictionary *rect = @{@"left": @(frame.origin.x),
                          @"top": @(frame.origin.y),
                          @"right": @(frame.origin.x + frame.size.width),
                          @"bottom": @(frame.origin.y + frame.size.height),
                          };
    [faceMap addEntriesFromDictionary:@{@"rect": rect}];
    
    if (face.trackingID != nil) {
      [faceMap addEntriesFromDictionary:@{@"trackingId": face.trackingID}];
    }
    
    if (face.hasHeadEulerAngleY) {
      [faceMap addEntriesFromDictionary:@{@"headEulerAngleY": @(face.headEulerAngleY)}];
    }
    
    if (face.hasHeadEulerAngleZ) {
      [faceMap addEntriesFromDictionary:@{@"headEulerAngleZ": @(face.headEulerAngleZ)}];
    }
    
    if (face.smilingProbability != nil) {
      [faceMap addEntriesFromDictionary:@{@"smilingProbability": face.smilingProbability}];
    }
    
    if (face.leftEyeOpenProbability != nil) {
      [faceMap addEntriesFromDictionary:@{@"leftEyeOpenProbability": face.leftEyeOpenProbability}];
    }
    
    if (face.rightEyeOpenProbability != nil) {
      [faceMap addEntriesFromDictionary:@{@"rightEyeOpenProbability": face.rightEyeOpenProbability}];
    }
    
    NSMutableDictionary *landmarks = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < 15; i++) {
      MLKFaceLandmark *landmark;
      NSString *landmarkName;
      switch (i) {
        case 0:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeMouthBottom];
          landmarkName = @"bottomMouth";
          break;
        case 1:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeLeftCheek];
          landmarkName = @"leftCheek";
          break;
        case 2:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeLeftEar];
          landmarkName = @"leftEar";
          break;
        case 3:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeLeftEye];
          landmarkName = @"leftEye";
          break;
        case 4:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeLeftMouth];
          landmarkName = @"leftMouth";
          break;
        case 5:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeNoseBase];
          landmarkName = @"noseBase";
          break;
        case 6:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeRightCheek];
          landmarkName = @"rightCheek";
          break;
        case 7:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeRightEar];
          landmarkName = @"rightEar";
          break;
        case 8:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeRightEye];
          landmarkName = @"rightEye";
          break;
        case 9:
          landmark = [face landmarkOfType:MLKFaceLandmarkTypeRightMouth];
          landmarkName = @"rightMouth";
          break;
      }
      if (landmark) {
        NSDictionary *point = @{@"x": @(landmark.position.x), @"y": @(landmark.position.y)};
        [landmarks setObject:point forKey:landmarkName];
      }
    }
    [faceMap addEntriesFromDictionary:@{@"landmarks": landmarks}];
    
    NSMutableDictionary *contours = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < 14; i++) {
      MLKFaceContour *contour;
      NSString *contourName;
      switch (i) {
        case 0:
          contour = [face contourOfType:MLKFaceContourTypeFace];
          contourName = @"face";
          break;
        case 1:
          contour = [face contourOfType:MLKFaceContourTypeLeftEyebrowTop];
          contourName = @"leftEyebrowTop";
          break;
        case 2:
          contour = [face contourOfType:MLKFaceContourTypeLeftEyebrowBottom];
          contourName = @"leftEyebrowBottom";
          break;
        case 3:
          contour = [face contourOfType:MLKFaceContourTypeRightEyebrowTop];
          contourName = @"rightEyebrowTop";
          break;
        case 4:
          contour = [face contourOfType:MLKFaceContourTypeRightEyebrowBottom];
          contourName = @"rightEyebrowBottom";
          break;
        case 5:
          contour = [face contourOfType:MLKFaceContourTypeLeftEye];
          contourName = @"leftEye";
          break;
        case 6:
          contour = [face contourOfType:MLKFaceContourTypeRightEye];
          contourName = @"rightEye";
          break;
        case 7:
          contour = [face contourOfType:MLKFaceContourTypeUpperLipTop];
          contourName = @"upperLipTop";
          break;
        case 8:
          contour = [face contourOfType:MLKFaceContourTypeUpperLipBottom];
          contourName = @"upperLipBottom";
          break;
        case 9:
          contour = [face contourOfType:MLKFaceContourTypeLowerLipTop];
          contourName = @"lowerLipTop";
          break;
        case 10:
          contour = [face contourOfType:MLKFaceContourTypeLowerLipBottom];
          contourName = @"lowerLipBottom";
          break;
        case 11:
          contour = [face contourOfType:MLKFaceContourTypeNoseBridge];
          contourName = @"noseBridge";
          break;
        case 12:
          contour = [face contourOfType:MLKFaceContourTypeNoseBottom];
          contourName = @"noseBottom";
          break;
      }
      if (contour) {
        NSMutableArray *points = [NSMutableArray array];
        for (MLKVisionPoint *point in contour.points) {
          [points addObject:@{@"x": @(point.x), @"y": @(point.y)}];
        }
        [contours setObject:points forKey:contourName];
      }
    }
    [faceMap addEntriesFromDictionary:@{@"contours": contours}];
    
    [faceData addObject:faceMap];
  }
  
  result(faceData);
}

@end

@implementation FaceDetectorManager

+ (instancetype)shared {
  static FaceDetectorManager *shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shared = [[FaceDetectorManager alloc] init];
  });
  return shared;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _detectors = [NSMutableDictionary dictionary];
  }
  return self;
}

- (MLKFaceDetector *)detectorForOptions:(MLKFaceDetectorOptions *)options andID:(NSString *)uid {
  MLKFaceDetector *detector = [_detectors objectForKey:uid];
  if (detector == nil) {
    detector = [MLKFaceDetector faceDetectorWithOptions:options];
    [_detectors setObject:detector forKey:uid];
  }
  return detector;
}

- (void)closeDetector:(NSString *)uid {
  [_detectors removeObjectForKey:uid];
}

@end
EOF

# Create the header file as well
cat > "$PLUGIN_DIR/GoogleMlKitFaceDetectionPlugin.h" <<EOF
#import <Flutter/Flutter.h>

@interface GoogleMlKitFaceDetectionPlugin : NSObject<FlutterPlugin>
@end

@interface FaceDetectorManager : NSObject

@property(atomic, copy) NSMutableDictionary *detectors;

+ (instancetype)shared;
- (MLKFaceDetector *)detectorForOptions:(MLKFaceDetectorOptions *)options andID:(NSString *)uid;
- (void)closeDetector:(NSString *)uid;

@end
EOF

echo "Fixed ML Kit header files in plugin directory."