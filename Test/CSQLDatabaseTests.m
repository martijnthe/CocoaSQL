//
//  CSQLDatabaseTests.m
//  CocoaSQL
//
//  Created by Igor Sutton on 3/31/10.
//  Copyright 2010 CocoaSQL.org. All rights reserved.
//

#import "CSQLDatabaseTests.h"


id databaseWithOptions();

@implementation CSQLDatabaseTests

#define TEST_DB @"test.db"

- (void)setUp
{
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:[TEST_DB stringByExpandingTildeInPath]]) {
        [fm removeItemAtPath:[TEST_DB stringByExpandingTildeInPath] error:nil];
    }
    
    database = [[CSQLDatabase databaseWithDriver:@"SQLite"
                                         options:[NSMutableDictionary dictionaryWithObjectsAndKeys:TEST_DB, @"path", nil]
                                           error:&error] retain];
    
    STAssertNil(error, @"We shouldn't have an error here: %@", error);
    STAssertNotNil(database, @"Database should not be nil.");    
}

- (void)tearDown
{
    [database release];
}

- (void)testDatabaseWithDriver
{
    id <CSQLDatabase> database_;
    NSError *error;
    
    database_ = [[CSQLDatabase databaseWithDriver:@"SQLite"
                                         options:[NSMutableDictionary dictionaryWithObjectsAndKeys:TEST_DB, @"path", nil]
                                           error:&error] retain];
    
    STAssertNil(error, @"We shouldn't have an error here: %@", error);
    STAssertNotNil(database_, @"Database should not be nil.");    
}

- (void)testDatabaseWithDSN
{
    id <CSQLDatabase> database_;
    NSError *error;
    
    NSString *DSN = [NSString stringWithFormat:@"SQLite:path=%@", TEST_DB];
    database_ = [CSQLDatabase databaseWithDSN:DSN error:&error];

    STAssertNil(error, @"We shouldn't have an error here: %@", error);
    STAssertNotNil(database_, @"Database should not be nil.");    
}

- (void)testExecuteSQL
{
    NSError *error = nil;
    int affectedRows;
    
    affectedRows = [database executeSQL:@"CREATE TABLE t (i INT, v VARCHAR)"
                                  error:&error];
    
    STAssertNil(error, 
                [NSString stringWithFormat:@"We shouldn't have an error here: %@", 
                 [[error userInfo] objectForKey:@"errorMessage"]]);
    STAssertEquals(affectedRows, 0, @"CREATE TABLE.");
    
    error = nil;
    affectedRows = [database executeSQL:@"INSERT INTO t (i, v) VALUES (1, 'test')"
                                  error:&error];
    
    STAssertNil(error, 
                [NSString stringWithFormat:@"We shouldn't have an error here: %@", 
                 [[error userInfo] objectForKey:@"errorMessage"]]);
    STAssertEquals(affectedRows, 1, @"INSERT.");
    
    error = nil;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:1];
    [values bindIntValue:1];
    affectedRows = [database executeSQL:@"DELETE FROM t WHERE i = ?"
                             withValues:values
                                  error:&error];

    STAssertNil(error, 
                [NSString stringWithFormat:@"We shouldn't have an error here: %@", 
                 [[error userInfo] objectForKey:@"errorMessage"]]);
    STAssertEquals(affectedRows, 1, @"DELETE with bind values.");
    
    error = nil;
    affectedRows = [database executeSQL:@"DELETE FROM t" error:&error];
    
    STAssertNil(error, 
                [NSString stringWithFormat:@"We shouldn't have an error here: %@", 
                 [[error userInfo] objectForKey:@"errorMessage"]]);
    STAssertEquals(affectedRows, 1, @"DELETE.");
    
    error = nil;
    affectedRows = [database executeSQL:@"DROP TABLE t" error:&error];
    
    STAssertNil(error, 
                [NSString stringWithFormat:@"We shouldn't have an error here: %@", 
                 [[error userInfo] objectForKey:@"errorMessage"]]);
    STAssertEquals(affectedRows, 1, @"DROP TABLE.");
    
}

@end

id databaseWithOptions() {
    
}