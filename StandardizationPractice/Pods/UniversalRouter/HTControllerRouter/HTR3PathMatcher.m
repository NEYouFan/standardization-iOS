//
//  HTR3PathMatcher.m
//  Pods
//
//  Created by zp on 15/10/29.
//
//

#import "HTR3PathMatcher.h"
#import "HTControllerRouterLogger.h"
#import "HTControllerRouteInfo.h"

static NSString * const kDefaultScheme = @"__defaultScheme__";

typedef struct _node node;
typedef struct _route route;
typedef struct match_entry match_entry;

void r3_tree_free(node * tree);
int r3_tree_compile(node *n, char **errstr);
void r3_tree_dump(const node * n, int level);
extern node * r3_tree_matchl(const node * n, const char * path, int path_len, match_entry * entry, NSMutableDictionary *matchedParams);
node * r3_tree_create(int cap);
node * r3_tree_insert_pathl_ex(node *tree, const char *path, int path_len, route * route, void * data, char **errstr);
void *r3_node_data(node *n);

@interface HTR3PathMatcherInfo : NSObject

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, assign) node *rootNode;

@end

@implementation HTR3PathMatcherInfo

- (void)dealloc
{
    r3_tree_free(_rootNode);
    _rootNode = NULL;
}

@end

@interface HTR3PathMatcher()

@property (nonatomic, strong) NSMutableDictionary *matcherInfos;

@end

@implementation HTR3PathMatcher

- (instancetype)initWithControllerRouterConfigs:(NSArray<HTControllerRouterConfig*>*)configs
{
    self = [super init];
    if (self){
        [self doInit];
        for (HTControllerRouterConfig *config in configs) {
            [self addHTControllerRouterConfig:config];
        }
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doInit];
    }
    
    return self;
}

- (void)doInit
{
    _matcherInfos = [NSMutableDictionary new];
}

- (void)addHTControllerRouterConfig:(HTControllerRouterConfig*)config
{
    for (NSString *urlString in [config urls]) {
        NSURL *url = [NSURL URLWithString:urlString];
        if (url.scheme) {
            [self addHTControllerRouterConfig:config scheme:url.scheme url:[urlString substringFromIndex:url.scheme.length + 2]];
        }
        else if ([urlString characterAtIndex:0] == '/'){
            [self addHTControllerRouterConfig:config scheme:kDefaultScheme url:urlString];
        }
        else{
            //parse scheme
            NSRange schemeEndRange = [urlString rangeOfString:@"://"];
            NSRange schemeRange = NSMakeRange(0, 0);
            if (schemeEndRange.length > 0){
                schemeRange.length = schemeEndRange.location;
            }
            else{
                HTControllerRouterLogError(@"HTR3PathMatcher add url failed:%@", url);
                return;
            }
            
            NSString *scheme = [urlString substringWithRange:schemeRange];
            
            NSRange urlWithoutSchemeRange = schemeEndRange;
            urlWithoutSchemeRange.location = schemeEndRange.location + 2;
            urlWithoutSchemeRange.length = urlString.length - urlWithoutSchemeRange.location;
            NSString *urlWithScheme = [urlString substringWithRange:urlWithoutSchemeRange];
            
            [self addHTControllerRouterConfig:config scheme:scheme url:urlWithScheme];
        }
    }
}

- (void)addHTControllerRouterConfig:(HTControllerRouterConfig*)config scheme:(NSString*)scheme url:(NSString*)url
{
    NSAssert([url characterAtIndex:0] == '/', @"url syntax error");
    
    HTR3PathMatcherInfo *matcher = [_matcherInfos objectForKey:scheme];
    if (!matcher){
        matcher = [HTR3PathMatcherInfo new];
        matcher.scheme = scheme;
        matcher.rootNode = r3_tree_create(10);
        [_matcherInfos setObject:matcher forKey:scheme];
    }
    
    node *n = r3_tree_insert_pathl_ex(matcher.rootNode, url.UTF8String, (int)url.length, NULL, (__bridge void*)config, NULL);
    if (!n){
        HTControllerRouterLogError(@"HTR3PathMatcher add url failed:%@", url);
    }
}

- (HTControllerRouterConfig*)matchURL:(NSString*)urlString matchedParams:(NSMutableDictionary*)params
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = url.scheme ? url.scheme : kDefaultScheme;
    
    NSString *matchedUrl = url.scheme ? [urlString substringFromIndex:url.scheme.length + 2] : urlString;
    
    return [self matchURL:matchedUrl withScheme:scheme matchedParams:params];
}

- (HTControllerRouterConfig*)matchURL:(NSString*)urlString withScheme:(NSString*)scheme matchedParams:(NSMutableDictionary*)params
{
    NSAssert([urlString characterAtIndex:0] == '/', @"url syntax error");
    HTR3PathMatcherInfo *matcher = [_matcherInfos objectForKey:scheme];
    if (!matcher)
        return nil;
    
    node *matched_node = r3_tree_matchl(matcher.rootNode, urlString.UTF8String, (int)urlString.length, NULL, params);
    if (!matched_node){
        [params removeAllObjects];
        return nil;
    }
    
    return (__bridge HTControllerRouterConfig*)r3_node_data(matched_node);
}

- (void)compile
{
    for (NSString *scheme in _matcherInfos) {
        HTR3PathMatcherInfo *matcher = [_matcherInfos objectForKey:scheme];
        char *errstr = NULL;
        int err = r3_tree_compile(matcher.rootNode, &errstr);
        if (err != 0) {
            // fail
            printf("error: %s\n", errstr);
            free(errstr); // errstr is created from `asprintf`, so you have to free it manually.
        }
    }
}

- (void)dump
{
    for (NSString *scheme in _matcherInfos) {
        HTR3PathMatcherInfo *matcher = [_matcherInfos objectForKey:scheme];
        r3_tree_dump(matcher.rootNode, 0);
    }
}
@end
