//
//  CSSQLite.m
//  CocoaSQL
//
//  Created by Igor Sutton on 3/25/10.
//  Copyright 2010 CocoaSQL.org. All rights reserved.
//

#import "CSSQLiteDatabase.h"


@implementation CSSQLiteDatabase

@synthesize path;
@dynamic databaseHandle;

#pragma mark -
#pragma mark Initialization and dealloc related messages

+ (CSQLDatabase *)databaseWithOptions:(NSDictionary *)options error:(NSError **)error
{
    CSSQLiteDatabase *database;
    database = [CSSQLiteDatabase databaseWithPath:[options objectForKey:@"path"] error:error];
    return database;
}

+ (id)databaseWithPath:(NSString *)aPath error:(NSError **)error
{
    CSSQLiteDatabase *database = [[CSSQLiteDatabase alloc] initWithPath:aPath error:error];
    return [database autorelease];
}

- (id)initWithPath:(NSString *)aPath error:(NSError **)error
{
    if (self = [super init]) {
        self.path = [aPath stringByExpandingTildeInPath];
        sqlite3 *sqliteDatabase;
        int errorCode = sqlite3_open_v2([self.path UTF8String], &sqliteDatabase, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, 0);
        if (errorCode != SQLITE_OK) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setObject:[NSString stringWithFormat:@"%s", sqlite3_errmsg(sqliteDatabase)] forKey:@"errorMessage"];
            *error = [[NSError alloc] initWithDomain:@"CSSQLite" code:errorCode userInfo:errorDetail];
            return nil;
        }
        self.databaseHandle = (voidPtr)sqliteDatabase;
    }
    return self;
}

- (void)dealloc
{
    int errorCode = sqlite3_close(self.databaseHandle);
    
    if (errorCode != SQLITE_OK) {
        NSLog(@"Couldn't close database handle.");
    }
    else {
        self.databaseHandle = NULL;
    }

    [path release];
    [super dealloc];
}

#pragma mark -
#pragma mark CSSQLiteDatabase related messages

- (NSUInteger)executeSQL:(NSString *)sql withValues:(NSArray *)values callback:(CSQLiteCallback)callbackFunction context:(void *)context error:(NSError **)error;
{
    int affectedRows = 0;
    int errorCode;
    char *errorMessage;
    
    if (values && [values count] > 0) {
        CSQLPreparedStatement *statement = [self prepareStatement:sql error:error];
        if (!statement) {
            return 0;
        }
        return [statement executeWithValues:values error:error];
    }
    else {
        errorCode = sqlite3_exec(self.databaseHandle, [sql UTF8String], callbackFunction, context, &errorMessage);
        if (errorCode != SQLITE_OK && errorCode != SQLITE_ABORT) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setObject:[NSString stringWithFormat:@"%s", errorMessage] forKey:@"errorMessage"];
            *error = [[NSError alloc] initWithDomain:@"CSSQLite" code:errorCode userInfo:errorDetail];
        }
        else {
            affectedRows = sqlite3_changes(self.databaseHandle);
        }        
    }
    return affectedRows;
}

#pragma mark -
#pragma mark CSQLDatabase related messages

- (NSUInteger)executeSQL:(NSString *)sql withValues:(NSArray *)values error:(NSError **)error 
{
    return [self executeSQL:sql withValues:values callback:nil context:nil error:error];
}

- (NSUInteger)executeSQL:(NSString *)sql error:(NSError **)error
{
    return [self executeSQL:sql withValues:nil error:error];
}

#pragma mark -
#pragma mark Row as Array

- (NSArray *)fetchRowAsArrayWithSQL:(NSString *)sql withValues:(NSArray *)values error:(NSError **)error
{
    NSMutableArray *row = [NSMutableArray array];
    BOOL success = [self executeSQL:sql withValues:values callback:(CSQLiteCallback)rowAsArrayCallback context:row error:error];
    return success ? row : nil;
}

- (NSArray *)fetchRowAsArrayWithSQL:(NSString *)sql error:(NSError **)error
{
    return [self fetchRowAsArrayWithSQL:sql withValues:nil error:error];
}

#pragma mark -
#pragma mark Row as Dictionary

- (NSDictionary *)fetchRowAsDictionaryWithSQL:(NSString *)sql withValues:(NSArray *)values error:(NSError **)error
{
    NSMutableDictionary *row = [NSMutableDictionary dictionary];
    BOOL success = [self executeSQL:sql withValues:values callback:(CSQLiteCallback)rowAsDictionaryCallback context:row error:error];
    return success ? row : nil;
}

- (NSDictionary *)fetchRowAsDictionaryWithSQL:(NSString *)sql error:(NSError **)error
{
    return [self fetchRowAsDictionaryWithSQL:sql withValues:nil error:error];
}

#pragma mark -
#pragma mark Rows as Dictionaries

- (NSArray *)fetchRowsAsDictionariesWithSQL:(NSString *)sql withValues:(NSArray *)values error:(NSError **)error
{
    NSMutableArray *rows = [NSMutableArray array];
    BOOL success = [self executeSQL:sql withValues:values callback:(CSQLiteCallback)rowsAsDictionariesCallback context:rows error:error];
    return success ? rows : nil;
}

- (NSArray *)fetchRowsAsDictionariesWithSQL:(NSString *)sql error:(NSError **)error
{
    return [self fetchRowsAsDictionariesWithSQL:sql withValues:nil error:error];
}

- (NSArray *)fetchRowsAsArraysWithSQL:(NSString *)sql withValues:(NSArray *)values error:(NSError **)error
{
    NSMutableArray *rows = [NSMutableArray array];
    BOOL success = [self executeSQL:sql withValues:values callback:(CSQLiteCallback)rowsAsArraysCallback context:rows error:error];
    return success ? rows : nil;
}

- (NSArray *)fetchRowsAsArraysWithSQL:(NSString *)sql error:(NSError **)error
{
    return [self fetchRowsAsArraysWithSQL:sql withValues:nil error:error];
}

#pragma mark -
#pragma mark Prepared Statement messages

- (CSQLPreparedStatement *)prepareStatement:(NSString *)sql error:(NSError **)error
{
    return [CSSQLitePreparedStatement preparedStatementWithDatabase:self andSQL:sql error:error];
}

@end

#pragma mark -
#pragma mark SQLite callbacks

int rowAsArrayCallback(void *callbackContext, int columnCount, char **columnValues, char **columnNames)
{
    NSMutableArray *row = callbackContext;
    for (int i = 0; i < columnCount; i++) {
        [row addObject:[NSString stringWithFormat:@"%s", columnValues[i]]];
    }
    return SQLITE_DONE;
}

int rowAsDictionaryCallback(void *callbackContext, int columnCount, char **columnValues, char **columnNames)
{
    NSMutableDictionary *row = callbackContext;
    for (int i = 0; i < columnCount; i++) {
        [row setObject:[NSString stringWithFormat:@"%s", columnValues[i]]
                forKey:[NSString stringWithFormat:@"%s", columnNames[i]]];
    }
    return SQLITE_DONE;
}

int rowsAsDictionariesCallback(void *callbackContext, int columnCount, char **columnValues, char **columnNames)
{
    NSMutableArray *rows = callbackContext;
    NSMutableDictionary *row = [NSMutableDictionary dictionaryWithCapacity:columnCount];
    for (int i = 0; i < columnCount; i++) {
        [row setObject:[NSString stringWithFormat:@"%s", columnValues[i]]
                forKey:[NSString stringWithFormat:@"%s", columnNames[i]]];
    }
    [rows addObject:row];
    return SQLITE_OK;
}

int rowsAsArraysCallback(void *callbackContext, int columnCount, char **columnValues, char **columnNames)
{
    NSMutableArray *rows = callbackContext;
    NSMutableArray *row = [NSMutableArray arrayWithCapacity:columnCount];
    for (int i = 0; i < columnCount; i++) {
        [row addObject:[NSString stringWithFormat:@"%s", columnValues[i]]];
    }
    [rows addObject:row];
    return SQLITE_OK;
}
