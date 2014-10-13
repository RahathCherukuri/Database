//
//  ViewController.m
//  DatabaseProject
//
//  Created by rahath on 10/13/14.
//  Copyright (c) 2014 Green. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self insertData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Singleton methods.

+ (id) sharedManager
{
    static ViewController * databaseController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{databaseController = [[self alloc] init];
    });
    return databaseController;
}

// File path to DB

-(NSString *)filePath
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"users.sql"];
}

//Opens the database.

-(void)openDB
{
    if(sqlite3_open([[self filePath]UTF8String], &db)!= SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(0, @"Database failed to open");
    }
    else
    {
        NSLog(@"Database opened");
    }
}

//we give tablename, FIELD1- USERNAME, FIELD2- PASSWORD
// You can specify the conditions NOT NULL, UNIQUE where the values have to support the properties.

-(void) createTable
{
    char *err;
    
    NSString * sql= [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS LoginTable (username TEXT UNIQUE NOT NULL,password TEXT NOT NULL)"];
    
    if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err)!= SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(0, @"COULD NOT CREATE TABLE");
    }
    else
    {
        NSLog(@"TABLE CREATED== Login table");
    }
}

-(void)openCreateDB
{
    [self openDB];
    [self createTable];
}

// Take the values from NSUserDefaults and we save them in LoginTable

-(void)insertData
{
    //Open and Create database
    [self openCreateDB];
    
    //Set the values that are to be saved.
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* username =  @"user1";
    NSLog(@"username: %@",username);
    
    //UserName value
    NSString * password= @"password1";
    NSLog(@"password: %@",password);
    
    //To display any error.
    char *err;
    //Insert statement
    NSString * sql= [NSString stringWithFormat:@"INSERT INTO LoginTable ('username','password') VALUES ('%@','%@')",username,password];
    @try {
        if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err)!= SQLITE_OK)
        {
            sqlite3_close(db);
            NSAssert(0,@"COULDNOT UPDATE TABLE");
        }
        else
        {
            NSLog(@"table inserted.");
            [self DisplayData];
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"An exception occured:%@,",[exception reason]);
        NSLog(@"The UserName is repeated.");
    }
    @finally {
        NSLog(@"Finally Block.");
    }

}

//Let's u display the data.
-(void)DisplayData
{
    sqlite3_stmt *statement;
    NSString *sql;
    sql = [NSString stringWithFormat:@"SELECT * FROM LoginTable"];
    NSLog(@"Displaying the data in the tables: ");
    
    if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil)== SQLITE_OK)
    {
        while(sqlite3_step(statement)== SQLITE_ROW)
        {
            char *field1= (char *)sqlite3_column_text(statement,0);
            NSString * field1str= [[NSString alloc]initWithUTF8String:field1];
            
            char *field2= (char *)sqlite3_column_text(statement,1);
            NSString * field2str= [[NSString alloc]initWithUTF8String:field2];
            
            NSString * str= [[NSString alloc]initWithFormat:@"username: %@ Password: %@ ",field1str,field2str];
            NSLog(@"%@",str);
        }
    }
    
}

//To get the firstrow and return in the format of a dictionary.
-(NSDictionary *)getFirstRow
{
    [self openDB];
    sqlite3_stmt *statement;
    NSString *sql;
    sql = [NSString stringWithFormat:@"SELECT * FROM LoginTable LIMIT 1"];
    NSDictionary *dict;
    
    if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil)== SQLITE_OK)
    {
        while(sqlite3_step(statement)== SQLITE_ROW)
        {
            char *field1= (char *)sqlite3_column_text(statement,0);
            NSString * field1str= [[NSString alloc]initWithUTF8String:field1];
            
            char *field2= (char *)sqlite3_column_text(statement,1);
            NSString * field2str= [[NSString alloc]initWithUTF8String:field2];
            
            dict = @{@"username": field1str,
                     @"password":field2str,
                     };
            
        }
    }
    return dict;
}

//Count the rows in table.(to ensure delete has happended.)
-(int)CountOfRowsInTable
{
    [self openDB];
    int count=0;
    NSString * str= @"Select Count(*) from LoginTable";
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(db,[str UTF8String], -1, &statement, NULL)== SQLITE_OK)
    {
        while( sqlite3_step(statement) == SQLITE_ROW )
        {
            count = sqlite3_column_int(statement, 0);
            NSLog(@"%d",count);
        }
    }
    else
    {
        NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(db));
    }
    return count;
}
//To delete row from the DB.
-(void)deleteData:(NSString *) username
{
    [self openDB];
    char *err;
    NSLog(@"deleting data from table:");
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM LoginTable WHERE username= '%@' ",username];
    
    if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err)!= SQLITE_OK)
    {
        NSLog(@"not deleted.");
    }
    else
    {
        NSLog(@"Deleted");
    }
}

//Let's you drop the tables in the DB.
-(void)dropTable
{
    NSString * sql = @"drop table if exists LoginTable";
    char *err;
    if(sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err)!= SQLITE_OK)
    {
        NSLog(@"not Dropped.");
    }
    else
    {
        NSLog(@"Dropped");
    }
    
}

//Lets u close the DB.
-(void)CloseDatabase
{
    sqlite3_close(db);
}


@end
