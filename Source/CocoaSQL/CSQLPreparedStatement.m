//
//  CSQLPreparedStatement.m
//  CocoaSQL
//
//  Created by Igor Sutton on 4/6/10.
//  Copyright 2010 CocoaSQL.org. All rights reserved.
//

#import "CSQLPreparedStatement.h"

@implementation CSQLPreparedStatement

@synthesize database;
@synthesize canFetch;

+ (id)preparedStatementWithDatabase:(id)aDatabase andSQL:(NSString *)sql error:(NSError **)error
{
    id preparedStatement;
    preparedStatement = [[self alloc] initWithDatabase:aDatabase andSQL:sql error:error];
    if (preparedStatement) {
        return [preparedStatement autorelease];
    }
    return nil;
}

- (id)initWithDatabase:(CSQLDatabase *)aDatabase andSQL:(NSString *)sql error:(NSError **)error
{
    NSLog(@"ImplementMe!");
    return self;
}

@end
