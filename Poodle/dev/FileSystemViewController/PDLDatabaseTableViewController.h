//
//  PDLDatabaseTableViewController.h
//  Poodle
//
//  Created by Poodle on 09/06/2017.
//  Copyright © 2019 Poodle. All rights reserved.
//

#import "PDLViewController.h"
#import "PDLDatabase.h"

@interface PDLDatabaseTableViewController : PDLViewController

@property (nonatomic, weak) PDLDatabase *database;
@property (nonatomic, copy) NSString *tableName;

@end
