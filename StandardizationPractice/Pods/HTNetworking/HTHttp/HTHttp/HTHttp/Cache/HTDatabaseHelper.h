//
//  HTDatabaseHelper.h
//  HTHttp
//
//  Created by NetEase on 15/8/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface HTDatabaseHelper : NSObject

+ (instancetype)sharedInstance;

/**
 *  默认数据库文件名.
 *
 *  @return 数据库文件名.
 */
+ (NSString *)defaultDBFileName;

/**
 *  默认数据库文件全路径
 *
 *  @return 数据库文件路径.
 */
+ (NSString *)defaultDBFilePath;

/**
 *  初始化DB
 *
 *  @return 是否成功
 */
+ (BOOL)setupDB;

/**
 *  数据库文件是否存在.
 *
 *  @param dbFileName 数据库文件是否存在.
 *
 *  @return 存在，返回YES, 否则返回NO.
 */
+ (BOOL)isDBExist:(NSString *)dbFileName;

/**
 *  修改DB文件名
 *
 *  @param fileName 数据库文件名
 */
- (void)setDBName:(NSString *)fileName;

/**
 *  获取对应的FMDatabase对象.
 *
 *  @return 具体用来操作数据库的FMDatabase对象.
 */
- (FMDatabase *)getDatabase;

/**
 *  结束对于FMDatabase的使用.
 */
- (void)finish;

/**
 *  执行sql语句, 主要用于查询
 *
 *  @param sql    sql语句
 *  @param result 将查询结果回调.
 */
- (void)executeQuery:(NSString*)sql result:(void (^)(FMResultSet* rs, BOOL *end))result;

/**
 *  执行sql语句，主要用于升级、创建、删除等
 *
 *  @param sql sql语句
 *
 *  @return 是否执行成功
 */
- (BOOL)executeUpdate:(NSString *)sql;

/**
 *  执行sql语句，主要用于升级、创建、删除等
 *
 *  @param sql  sql语句
 *  @param args sql语句附带的参数
 *
 *  @return 是否执行成功
 */
- (BOOL)executeUpdate:(NSString *)sql arguments:(NSArray *)args;

/**
 *  执行事务
 *
 *  @param blockTry 在一个事务中需要具体执行的操作.
 */
- (void)beginTransactionBlockTry:(void(^)(void))blockTry;

#pragma mark - Override Methods

/**
 *  初始化DB所需要执行的sql语句
 *
 *  @return sql语句数组.
 */
+ (NSArray *)setupSqls;

/**
 *  DB文件存放的路径
 *
 *  @return DB文件存放的路径, 默认在Documents目录下.
 */
+ (NSString *)cacheFolder;

/**
 *  是否允许备份到iCloud
 *
 *  @return 该数据库文件是否允许备份到iCloud.
 */
+ (BOOL)isAllowBackup;

@end
