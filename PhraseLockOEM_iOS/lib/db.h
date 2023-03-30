//
//  db.h
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>

#define ALERT_ASYNC(_title_, _msg_)  \
			dispatch_async(dispatch_get_main_queue(), ^{ \
				UIAlertController* __alert__ = [UIAlertController alertControllerWithTitle: _title_ \
				message: _msg_ \
				preferredStyle:UIAlertControllerStyleAlert];


#define ALERT_BUTTON(_title_, _fnx_) \
				[__alert__ addAction:[UIAlertAction actionWithTitle:_title_ style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ \
					_fnx_\
				}]];


#define ALERT_ASYNC_SHOW \
				__alert__.view.tintColor = [UIColor colorWithRed:0x0/255.0 green:0x40/255.0 blue:0x80/255.0 alpha:1.0]; \
				/*[self presentViewController:__alert__ animated:NO completion:nil];*/ \
				[__alert__ show]; \
			});

/* ******** VALUES MUST ADOPTED TO YOUR SPECIFIC PHRASE-LOCK USB-KEY BEGIN ******** */

/*
 This are the private and public EC-keys for uninitialised USB-Keys.
 This keys are ONLY used by manufacturer for development purposes.
 If you want to connect your application with an USB-Key you need to
 replace this values with the corresponding one.
 */
#define UPUBLX_DEV 		{0xA5,0x44,0x2A,0xFF,0x41,0xF5,0x85,0x0C,0x39,0xCE,0x6C,0x79,0xBF,0x7D,0xD4,0x26,0x23,0x51,0xBD,0x3C,0x63,0x68,0x07,0x5B,0x97,0x9C,0xF6,0x6B,0xB6,0x9C,0x3B,0x81}
#define UPUBLY_DEV		{0x6D,0x0A,0x6E,0x35,0x1E,0xA0,0x45,0x0C,0xE1,0xB9,0x02,0x85,0x91,0xC6,0x05,0x82,0xF7,0xA2,0x6B,0x5A,0x7C,0xBD,0xE9,0x7D,0xE8,0x1F,0x98,0xFD,0x72,0xD5,0xFF,0x32}
//#define UPRIV_DEV		{0x97,0x45,0x44,0x11,0x2E,0x96,0x41,0xCC,0xED,0xBF,0x69,0xF9,0xDB,0x77,0x5D,0x12,0x19,0x04,0xD0,0x9A,0xDC,0x85,0x11,0x21,0xE3,0xF3,0x63,0xB9,0x9C,0x09,0xA7,0xC8}

//#define DPUBLX_DEV 		{0x1D,0xD8,0x53,0xF6,0xE4,0x77,0xD8,0xA3,0xD7,0x07,0xF9,0xFC,0xD5,0xB4,0xF1,0x36,0x67,0xB9,0xC9,0xE5,0xDD,0x5F,0xBA,0xB8,0x4B,0xE1,0xE3,0x6C,0x9A,0xE2,0x02,0x9B}
//#define DPUBLY_DEV		{0xE4,0x30,0xAD,0x60,0xD1,0xE0,0xAD,0x2D,0xB6,0x23,0xA3,0xD4,0xC7,0x9C,0x0A,0x7F,0xD2,0x3E,0x7C,0x31,0x50,0xD6,0x3F,0x51,0xB6,0xA3,0xDE,0x40,0x33,0xF4,0x71,0xC9}
#define DPRIV_DEV		{0x44,0xE9,0x87,0x4C,0x61,0x29,0x12,0xAA,0xFC,0x53,0x1E,0xE5,0xB0,0x29,0x90,0x52,0xF0,0xA8,0x05,0x7C,0xBC,0xA6,0x8B,0xA6,0x37,0x3C,0x96,0x22,0xF7,0xD6,0x31,0x5E}

#define PL_SERVICE_UUID_DEV_STRING		"7388AB96-564A-4499-B6F5-6DB9B997B072"
#define PL_SERVICE_UUID_DEV_ARRAY 		{0x73,0x88,0xAB,0x96,0x56,0x4A,0x44,0x99,0xB6,0xF5,0x6D,0xB9,0xB9,0x97,0xB0,0x72}

/* ******** VALUES MUST ADOPTED TO YOUR SPECIFIC PHRASE-LOCK USB-KEY END ******** */

/*
#define SQLITE_OK           0   // Successful result

// beginning-of-error-codes:
#define SQLITE_ERROR        1   // SQL error or missing database 
#define SQLITE_INTERNAL     2   // Internal logic error in SQLite 
#define SQLITE_PERM         3   // Access permission denied 
#define SQLITE_ABORT        4   // Callback routine requested an abort 
#define SQLITE_BUSY         5   // The database file is locked 
#define SQLITE_LOCKED       6   // A table in the database is locked 
#define SQLITE_NOMEM        7   // A malloc() failed 
#define SQLITE_READONLY     8   // Attempt to write a readonly database 
#define SQLITE_INTERRUPT    9   // Operation terminated by sqlite3_interrupt()
#define SQLITE_IOERR       10   // Some kind of disk I/O error occurred 
#define SQLITE_CORRUPT     11   // The database disk image is malformed 
#define SQLITE_NOTFOUND    12   // Unknown opcode in sqlite3_file_control() 
#define SQLITE_FULL        13   // Insertion failed because database is full 
#define SQLITE_CANTOPEN    14   // Unable to open the database file 
#define SQLITE_PROTOCOL    15   // Database lock protocol error 
#define SQLITE_EMPTY       16   // Database is empty 
#define SQLITE_SCHEMA      17   // The database schema changed 
#define SQLITE_TOOBIG      18   // String or BLOB exceeds size limit 
#define SQLITE_CONSTRAINT  19   // Abort due to constraint violation 
#define SQLITE_MISMATCH    20   // Data type mismatch 
#define SQLITE_MISUSE      21   // Library used incorrectly 
#define SQLITE_NOLFS       22   // Uses OS features not supported on host 
#define SQLITE_AUTH        23   // Authorization denied 
#define SQLITE_FORMAT      24   // Auxiliary database format error 
#define SQLITE_RANGE       25   // 2nd parameter to sqlite3_bind out of range 
#define SQLITE_NOTADB      26   // File opened that is not a database file 
#define SQLITE_ROW         100  // sqlite3_step() has another row ready 
#define SQLITE_DONE        101  // sqlite3_step() has finished executing
*/

#define _MEM_ERROR_ALERT_ 		/* Nothing left to do so far */

#define _DB_OPEN_	int dbres = SQLITE_ERROR; \
					int dbres_close = SQLITE_ERROR; \
					{\
								sqlite3 *pDB = NULL; \
								NSString * dbPath  = [db db_filePath]; \
								dbres = sqlite3_open([dbPath UTF8String],&pDB);	\
								if(pDB!=NULL && pDB!=nil){ \
									sqlite3_stmt *dbps=NULL;

#define _DB_CLOSE_  \
								dbres_close = sqlite3_close(pDB); \
							} \
					}

#define _DB_EXECUTE_(_CMD_, _dbres_1, _dbres_2, _dbres_3) \
								_dbres_1 = SQLITE_ERROR; \
								_dbres_2 = SQLITE_ERROR; \
								_dbres_3 = SQLITE_ERROR; \
								dbps=NULL; \
								_dbres_1 = sqlite3_prepare(pDB,[_CMD_ UTF8String], -1, &dbps, NULL); \
								_dbres_2 = sqlite3_step(dbps); \
								_dbres_3 = sqlite3_finalize(dbps);

#define CURRENT_DB_NAME			@"phraselock_db"

@interface db : NSObject {
	
}

#define ATOMIC_COUNTER 			@"ATOMIC_COUNTER"
#define GLOBAL_AUTHNDATA		@"GLOBAL_AUTHNDATA"
#define RESIDENT_KEY			@"RESIDENT_KEY_"
#define CORE_DATA				@"CORE_DATA_"

#pragma mark - Spezific functions -

+(void) resetAuthenticationState;

#pragma mark - DB Initialisation -

+(void)initOnStartDB;

#pragma mark - Blockdata -

+(BOOL) setBlockdata:(nonnull NSString*)key dataNSString:(nonnull NSString*)dataNSString;
+(BOOL) setBlockdata:(nonnull NSString*)key dataNSData:(nonnull NSData*)dataNSData;
+(BOOL) setBlockdata:(nonnull NSString*)key dataUint32_t:(uint32_t)dataUint32_t;

+(nullable NSString*) getBlockdata:(nonnull NSString*)key dataNSString:( nullable NSString*)dataNSString;
+(nullable NSData*) getBlockdata:(nonnull NSString*)key dataNSData:(nullable NSData*)dataNSData;
+(uint32_t) getBlockdata:(nonnull NSString*)key dataUint32_t:(uint32_t)dataUint32_t;

+(void)deleteBlockdata:(nonnull NSString*)key;
+(void)deleteAllBlockdataLike:(nonnull NSString*)key;

+(int)countAllBlockDataIndicesLike:(nonnull NSString*)idxStart;
+(nullable NSMutableArray*)getAllBlockDataWithIndicesLike:(nonnull NSString*)idxStart;

#pragma mark - Dump Tables -

+(nullable NSString*) dumpTable:(nullable NSString*)tablename;
+(nullable NSString*) dumpTableJSON:(nullable NSString*)tablename;
+(nullable NSString*) dumpQuery:(nullable NSString*)cmd;

#pragma mark - File write/read -

+(void) writeTXTFile:(nonnull NSString*)content fname:(nonnull NSString*)fname ext:(nonnull NSString*)ext;
+(void) deleteFile:(nonnull NSString*)fname ext:(nonnull NSString*)ext;
+(nullable NSString*) readTXTFile:(nonnull NSString*)fname ext:(nonnull NSString*)ext origBundle:(BOOL)origBundle;
+(nullable NSData*) readCertDataFromFile:(nonnull NSString*)fname ext:(nonnull NSString*)ext origBundle:(BOOL)origBundle;

#pragma mark - CTAP2 & Resident Credential Data -

+(void)storeResidentKeyRecord:(nonnull NSString*)uname
					   userid:(nonnull NSString*)userid
						dname:(nonnull NSString*)dname
					 rpidhash:(nonnull NSString*)rpidhash
					 cridhash:(nonnull NSString*)cridhash
				  residentkey:(nonnull NSString*)residentkey
					  privkey:(nonnull NSString*)privkey;

+(nullable NSString*)readResidentKeys:(nonnull NSString*)rpidHash;
+(nullable NSString*)readResidentKeys:(nonnull NSString*)cridHash rpidHash:(nonnull NSString*)rpidHash;

+(void) delete_All_residentCredData;

#pragma mark - Core Data Handling -

+(void)setCoreDataSet:(nonnull NSString*)ltc cd:(nonnull NSData*)cd;
+(nullable NSData*)getCoreDataSet:(nonnull NSString*)ltc;
+(int)countAllCoreDataSets;
+(nullable NSMutableArray*)getAllCoreDataSets;



@end
