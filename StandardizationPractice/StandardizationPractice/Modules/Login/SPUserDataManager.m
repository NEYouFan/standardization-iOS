//
//  SPUserDataManager.m
//  StandardizationPractice
//
//  Created by Baitianyu on 20/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPUserDataManager.h"

static NSString *const kSPAlreadyLoginKey = @"alreadyLogin";
static NSString *const kSPSaveOriginalPicture = @"saveOrigianlPicture";
static NSString *const kSPUserName = @"userName";
static NSString *const kSPHeaderIcon = @"headerIcon";

@implementation SPUserDataManager

#pragma mark - Life cycle.

+ (instancetype)sharedInstance {
    static SPUserDataManager *userDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDataManager = [[SPUserDataManager alloc] init];
    });
    return userDataManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _cacheSize = 200000;
    }
    return self;
}


#pragma mark - Getter & Setter.

- (BOOL)alreadyLogin {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSPAlreadyLoginKey];
}

- (void)setAlreadyLogin:(BOOL)alreadyLogin {
    [[NSUserDefaults standardUserDefaults] setBool:alreadyLogin forKey:kSPAlreadyLoginKey];
    if (alreadyLogin) {
        self.headerIcon = @"default_header";
    }
}

- (NSString *)headerIcon {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSPHeaderIcon];
}

- (void)setHeaderIcon:(NSString *)headerIcon {
    [[NSUserDefaults standardUserDefaults] setObject:headerIcon forKey:kSPHeaderIcon];
}

- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSPUserName];
}

- (void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kSPUserName];
}

- (BOOL)saveOriginalPicture {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSPSaveOriginalPicture];
}

- (void)setSaveOriginalPicture:(BOOL)saveOriginalPicture {
    [[NSUserDefaults standardUserDefaults] setBool:saveOriginalPicture forKey:kSPSaveOriginalPicture];
}

- (CGFloat)cacheSize {
    //TODO: 根据实际缓存读取
    return _cacheSize;
}

- (void)clearCache {
    _cacheSize = 0;
}

@end
