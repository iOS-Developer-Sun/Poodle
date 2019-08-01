//
//  PDLDatabase.h
//  Poodle
//
//  Created by Poodle on 14-6-27.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDLDatabase : NSObject

@property NSInteger version;
@property (readonly) NSArray *allTables;
@property (readonly) NSArray *customTables;

+ (instancetype)databaseWithPath:(NSString *)path;

/**
 *  判断表是否存在
 *
 *  @param tableName 表名
 *
 *  @return 表是否存在
 */
- (BOOL)isTableExistent:(NSString *)tableName;

/**
 *  返回数据库表的所有字段
 *
 *  @param table 数据库表名
 *
 *  @return 字段数组
 */
- (NSArray *)fieldsFromTable:(NSString *)table;

/**
 *  查询数据库表的行数
 *
 *  @param table 数据库表名
 *
 *  @return 行数
 */
- (NSInteger)countFromTable:(NSString *)table;

/**
 *  按条件查询数据库表的行数
 *
 *  @param table     数据库表名
 *  @param condition 条件 @"where ..."
 *
 *  @return 行数
 */
- (NSInteger)countFromTable:(NSString *)table withCondition:(NSString *)condition;

/**
 *  在数据库表中插入数据
 *
 *  @param row   数据
 *  @param table 表名
 *
 *  @return 操作是否成功
 */
- (BOOL)insert:(NSDictionary *)row intoTable:(NSString *)table;

/**
 *  在数据库表中替换数据，如果不存在符合条件的行，则插入数据
 *
 *  @param row   数据
 *  @param table 表名
 *
 *  @return 操作是否成功
 */
- (BOOL)replace:(NSDictionary *)row intoTable:(NSString *)table;

/**
 *  从数据库表中删除所有数据
 *
 *  @param table 表名
 *
 *  @return 操作是否成功
 */
- (BOOL)deleteFromTable:(NSString *)table;

/**
 *  按条件从数据库表中删除所有数据
 *
 *  @param table     表名
 *  @param condition 条件 @"where ..."
 *
 *  @return 操作是否成功
 */
- (BOOL)deleteFromTable:(NSString *)table withCondition:(NSString *)condition;

/**
 *  按条件在数据库表中更新数据
 *
 *  @param data      数据
 *  @param table     表名
 *  @param condition 条件 @"where ..."
 *
 *  @return 操作是否成功
 */
- (BOOL)update:(NSDictionary *)data inTable:(NSString *)table withCondition:(NSString *)condition;

/**
 *  查找一行数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *
 *  @return 查找到的数据
 */
- (NSDictionary *)findOne:(NSString *)fields fromTable:(NSString *)table;

/**
 *  查找一行数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param order     顺序 @"asc" / @"desc"
 *
 *  @return 查找到的数据
 */
- (NSDictionary *)findOne:(NSString *)fields fromTable:(NSString *)table withOrder:(NSString *)order;

/**
 *  查找一行数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSDictionary *)findOne:(NSString *)fields fromTable:(NSString *)table withCondition:(NSString *)condition;

/**
 *  查找一行数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param order     顺序 @"asc" / @"desc"
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSDictionary *)findOne:(NSString *)fields fromTable:(NSString *)table withOrder:(NSString *)order withCondition:(NSString *)condition;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param limit     限制个数 为1相当于findOne方法
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withLimit:(NSInteger)limit;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param offset    起始索引
 *  @param count     个数
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOffset:(NSInteger)offset withCount:(NSInteger)count;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param order     顺序 @"asc" / @"desc"
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOrder:(NSString *)order;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withCondition:(NSString *)condition;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param limit     限制个数 为1相当于findOne方法
 *  @param order     顺序 @"asc" / @"desc"
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withLimit:(NSInteger)limit withOrder:(NSString *)order;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param offset    起始索引
 *  @param count     个数
 *  @param order     顺序 @"asc" / @"desc"
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOffset:(NSInteger)offset withCount:(NSInteger)count withOrder:(NSString *)order;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param limit     限制个数 为1相当于findOne方法
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withLimit:(NSInteger)limit withCondition:(NSString *)condition;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param offset    起始索引
 *  @param count     个数
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOffset:(NSInteger)offset withCount:(NSInteger)count withCondition:(NSString *)condition;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param order     顺序 @"asc" / @"desc"
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOrder:(NSString *)order withCondition:(NSString *)condition;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param limit     限制个数 为1相当于findOne方法
 *  @param order     顺序 @"asc" / @"desc"
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */

- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withLimit:(NSInteger)limit withOrder:(NSString *)order withCondition:(NSString *)condition;

/**
 *  查找数据库表中的字段
 *
 *  @param fields    字段名 @"*"为全部
 *  @param table     表名
 *  @param offset     起始索引
 *  @param count    个数
 *  @param order     顺序 @"asc" / @"desc"
 *  @param condition 条件 @"where ..."
 *
 *  @return 查找到的数据
 */
- (NSArray *)findAll:(NSString *)fields fromTable:(NSString *)table withOffset:(NSInteger)offset withCount:(NSInteger)count withOrder:(NSString *)order withCondition:(NSString *)condition;

/**
 *  通过sql语句执行
 *
 *  @param sql sql语句
 */
- (BOOL)executeUpdate:(NSString *)sql;

/**
 *  通过sql语句查询
 *
 *  @param sql sql语句
 *
 *  @return 查询结果
 */
- (NSArray *)executeQuery:(NSString *)sql;

/**
 *  通过sql语句查询
 *
 *  @param sql sql语句
 *  @param error 错误地址
 *
 *  @return 查询结果
 */
- (NSArray *)executeQuery:(NSString *)sql error:(NSError * __autoreleasing *)error;

/**
 *  执行事务
 *
 *  @param transaction 事务block, 返回YES则commit，返回NO则cancel
 *
 *  @return 查询结果
 */
- (BOOL)executeTransaction:(BOOL (^)(void))transaction;

@end
