//
//  ViewController.h
//  DatabaseProject
//
//  Created by rahath on 10/13/14.
//  Copyright (c) 2014 Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface ViewController : UIViewController
{
    sqlite3 *db;
}

//Class Object.
+ (id)sharedManager;

//Returns the file path of the database.
-(NSString *) filePath;

//Let's you open the database.
-(void)openDB;

//Lets you create the database.
-(void) createTable;

//Let's u insert data into table.
-(void)insertData;

//Let's u count the no of rows.
-(int)CountOfRowsInTable;

//lets u delete the database.
-(void)deleteData:(NSString *) time_stamp;

//lets u close the database.
-(void)CloseDatabase;

//Let's u get the firstrow.
-(NSDictionary *)getFirstRow;

//Let's u display the entries in DB.
-(void)DisplayData;

//Let's u drop the table.
-(void)dropTable;

@end

