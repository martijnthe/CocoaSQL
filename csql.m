/*
 *  csql.c
 *  CocoaSQL
 *
 *  Created by Igor Sutton on 3/25/10.
 *  Copyright 2010 StrayDev.com. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "CSSQLiteDatabase.h"
#import "CSSQLitePreparedStatement.h"

int main() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSError *error = nil;
    BOOL success;
    
    CSSQLiteDatabase *database = [CSSQLiteDatabase databaseWithPath:@"/tmp/test.db" error:&error];
    
    if (!database) {
        NSLog(@"Error while opening database: %@", error);
    }

    success = [database executeSQL:@"CREATE TABLE t (i INT, v VARCHAR)" error:&error];
    
    if (!success) {
        NSLog(@"Error while creating table: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    
    success = [database executeSQL:@"INSERT INTO t (i, v) VALUES (1, 'test')" error:&error];
    
    if (!success) {
        NSLog(@"Error while inserting: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    
    success = [database executeSQL:@"DELETE FROM t WHERE i = ?" 
                        withValues:[NSArray arrayWithObjects:[NSNumber numberWithInt:5], nil]
                             error:&error];
    
    if (!success) {
        NSLog(@"Error while deleting: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    
    NSArray *row = [database fetchRowAsArrayWithSQL:@"SELECT * FROM t LIMIT 2" error:&error];
    
    if (!row) {
        NSLog(@"Error while selecting row: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    else {
        NSLog(@"Row: %@", row);
    }

    NSDictionary *dict = [database fetchRowAsDictionaryWithSQL:@"SELECT * FROM t LIMIT 2" error:&error];

    if (!dict) {
        NSLog(@"Error while selecting dict: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    else {
        NSLog(@"Dict: %@", dict);
    }
        
    NSArray *rows = [database fetchRowsAsDictionariesWithSQL:@"SELECT * FROM t" error:&error];
    
    if (!rows) {
        NSLog(@"Error while selecting rows: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    else {
        NSLog(@"Rows: %@", rows);
    }
    
    rows = [database fetchRowsAsArraysWithSQL:@"SELECT * FROM t" error:&error];
    
    if (!rows) {
        NSLog(@"Error while selecting rows: %@", [[error userInfo] objectForKey:@"errorMessage"]);
    }
    else {
        NSLog(@"Rows: %@", rows);
    }
 
    CSSQLitePreparedStatement *stmt = [database prepareStatement:@"SELECT * FROM t" error:&error];
    
    if ([stmt execute:&error]) {
        NSLog(@"Executed successfully.");
    }
    
    
    while (dict = [stmt fetchRowAsDictionary:&error]) {
        NSLog(@"Row: %@", dict);
    }
    
    [pool drain];
}