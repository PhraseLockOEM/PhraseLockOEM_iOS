//  db.m
//
//  Created by Thomas Donhauser on 31.10.2022.
//  Copyright © 2022 Thomas Donhauser. All rights reserved.
//

#import "db.h"
#import "FC.h"
#import "TBXML.h"

#import <PhraseLockOEM/PhraseLock.h>

NSString *const kApplicationGroupId = @"group.com.phraselock.oem";

@implementation db

#pragma mark - Spezific functions -

+(void) resetAuthenticationState {
	[db deleteBlockdata:GLOBAL_AUTHNDATA];
}

#pragma mark - DB Initialisation -

+(void)initOnStartDB
{			
	// Block-Data
	[db checkBlockDataExists:FALSE];
	
	// Resident Credentials
	[db checkResidentCredDataExists:FALSE];
}

#pragma mark - Blockdata -

+(void) checkBlockDataExists:(BOOL)reset {
	int dbres_2= SQLITE_ERROR;
_DB_OPEN_
	dbps=NULL;
	dbres = sqlite3_prepare(pDB, [@"SELECT name FROM sqlite_master WHERE type='table' AND name='blockdata';" UTF8String],-1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
	dbres_2 = dbres;
_DB_CLOSE_
	if(dbres_2!= SQLITE_ROW || reset){
		[db dbBlockDataReset];
	}
}

+(void) dbBlockDataReset {
_DB_OPEN_
	if(pDB!=NULL && pDB!=nil){
		int dbres = SQLITE_ERROR;
		
		/* blockdata */
		dbres = sqlite3_prepare(pDB,"DROP TABLE IF EXISTS blockdata;",-1, &dbps, NULL);
		dbres = sqlite3_step(dbps);
		
		dbps=NULL;
		dbres = sqlite3_prepare(pDB,"CREATE TABLE IF NOT EXISTS blockdata (idx TEXT NOT NULL PRIMARY KEY, data TEXT);", -1, &dbps, NULL);
		dbres = sqlite3_step(dbps);
	}
_DB_CLOSE_
}


#pragma mark - BlockData I/O -

+(BOOL) setBlockdata:(nonnull NSString*)key dataNSString:(nonnull NSString*)dataNSString
{
  BOOL rVal = FALSE;
	if (dataNSString!=nil) {
_DB_OPEN_
		dbps=NULL;
		dbres = sqlite3_prepare(pDB,
		 [[NSString stringWithFormat:@"INSERT OR REPLACE INTO blockdata (idx, data) VALUES ('%@','%@');",key,dataNSString] UTF8String], -1, &dbps, NULL);
		dbres = sqlite3_step(dbps);
    if(dbres== SQLITE_DONE){
      rVal = TRUE;
    }
    _DB_CLOSE_
  }
  return rVal;
}

+(BOOL) setBlockdata:(nonnull NSString*)key dataNSData:(nonnull NSData*)dataNSData
{
  BOOL rVal = FALSE;
	if (dataNSData!=nil) {
		NSString* data = NSDataToHex(dataNSData);
_DB_OPEN_
		dbps=NULL;
		dbres = sqlite3_prepare(pDB,
		 [[NSString stringWithFormat:@"INSERT OR REPLACE INTO blockdata (idx, data) VALUES ('%@','%@');",key,data] UTF8String], -1, &dbps, NULL);
		dbres = sqlite3_step(dbps);
    if(dbres== SQLITE_DONE){
      rVal = TRUE;
    }
    _DB_CLOSE_
  }
  return rVal;
}

+(BOOL) setBlockdata:(nonnull NSString*)key dataUint32_t:(uint32_t)dataUint32_t {
  BOOL rVal = FALSE;
	NSString* data = [NSString stringWithFormat:@"%d", dataUint32_t];
_DB_OPEN_
	dbps=NULL;
	dbres = sqlite3_prepare(pDB,
	 [[NSString stringWithFormat:@"INSERT OR REPLACE INTO blockdata (idx, data) VALUES ('%@','%@');",key,data] UTF8String], -1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
  if(dbres== SQLITE_DONE){
    rVal = TRUE;
  }
  _DB_CLOSE_
  return rVal;
}

+(nullable NSString*) getBlockdata:(nonnull NSString*)key dataNSString:( nullable NSString*)dataNSString {
	NSString* result = nil;
_DB_OPEN_
	dbps=NULL;
	dbres = sqlite3_prepare(pDB, [[NSString stringWithFormat:@"SELECT * from blockdata where idx='%@';",key] UTF8String], -1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
	if(dbres==SQLITE_ROW){
		result = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(dbps, 1/*FieldNumber*/)];
	}else {
		if (dataNSString!=nil) {
			[db setBlockdata:key dataNSString:dataNSString];
			result = dataNSString;
		}
	}
_DB_CLOSE_
	return result;
}

+(nullable NSData*) getBlockdata:(nonnull NSString*)key dataNSData:(nullable NSData*)dataNSData {
	NSString* result = nil;
_DB_OPEN_
	dbps=NULL;
	dbres = sqlite3_prepare(pDB, [[NSString stringWithFormat:@"SELECT * from blockdata where idx='%@';",key] UTF8String], -1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
	if(dbres==SQLITE_ROW){
		result = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(dbps, 1/*FieldNumber*/)];
	}else {
		if (dataNSData!=nil) {
			[db setBlockdata:key dataNSData:dataNSData];
			result = NSDataToHex(dataNSData);
		}
	}
_DB_CLOSE_
	if(result!=nil && [result length]>0) {
		return hexStringToNSData(result);
	}
	return nil;
}

+(uint32_t) getBlockdata:(nonnull NSString*)key dataUint32_t:(uint32_t)dataUint32_t {
	NSString* result = nil;
_DB_OPEN_
	dbps=NULL;
	dbres = sqlite3_prepare(pDB, [[NSString stringWithFormat:@"SELECT * from blockdata where idx='%@';",key] UTF8String], -1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
	if(dbres==SQLITE_ROW){
		result = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(dbps, 1/*FieldNumber*/)];
	}else {
		[db setBlockdata:key dataUint32_t:dataUint32_t];
		result = [NSString stringWithFormat:@"%d", dataUint32_t];
	}
_DB_CLOSE_
	if(result!=nil && [result length]>0) {
		return [result intValue];
	}
	return 0;
}

+(void) deleteBlockdata:(NSString*)key {
_DB_OPEN_
	dbps=NULL;
	dbres = sqlite3_prepare(pDB,[[NSString stringWithFormat:@"DELETE from blockdata where idx='%@';",key] UTF8String], -1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
_DB_CLOSE_
}

+(void) deleteAllBlockdataLike:(NSString*)key {
_DB_OPEN_
	dbps=NULL;
	NSString*  cmd = [NSString stringWithFormat:@"DELETE from blockdata where idx like '%@%%';",key];
	dbres = sqlite3_prepare(pDB,[cmd UTF8String], -1, &dbps, NULL);
	dbres = sqlite3_step(dbps);
_DB_CLOSE_
}

+(int)countAllBlockDataIndicesLike:(nonnull NSString*)idxStart {
	NSString * count =@"0";
_DB_OPEN_
	dbps=NULL;
	NSString *cmd = [NSString stringWithFormat:@"SELECT COUNT(idx) as cx from blockdata where idx like '%@%%';",idxStart];
	dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
	if(sqlite3_step(dbps)==SQLITE_ROW){
		char* cx = (char*)sqlite3_column_text(dbps, 0);
		if (cx!=NULL) {
			count = [NSString stringWithFormat:@"%@", [[NSString alloc] initWithUTF8String:(const char*) cx]];
		}
	}
_DB_CLOSE_
	return [count intValue];
}

+(nullable NSMutableArray*)getAllBlockDataWithIndicesLike:(nonnull NSString*)idxStart {
	NSMutableArray *ars = nil;
	int cx = [db countAllBlockDataIndicesLike:idxStart];
	if(cx>0){
		ars = nil;
		ars = [[NSMutableArray alloc] initWithCapacity:cx];
_DB_OPEN_
		dbps=NULL;
		NSString *cmd = [NSString stringWithFormat:@"SELECT * from blockdata where idx like '%@%%';",idxStart];
		
		dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
		while(sqlite3_step(dbps)==SQLITE_ROW){
			NSString* ds  = [[NSString alloc] initWithUTF8String:(const char*) sqlite3_column_text(dbps, 1)];
			NSData* dx = hexStringToNSData(ds);
			[ars addObject:dx];
		}
_DB_CLOSE_
	}else{
		ars = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return ars;
}

#pragma mark - CTAP2 & Resident Credential Data -

+(void) checkResidentCredDataExists:(BOOL)reset
{
  int dbres_2= SQLITE_ERROR;
  _DB_OPEN_
  
  dbres = sqlite3_prepare(pDB, [@"SELECT name FROM sqlite_master WHERE type='table' AND name='residentCredData';" UTF8String],-1, &dbps, NULL);
  dbres = sqlite3_step(dbps);
  dbres_2 = dbres;
  _DB_CLOSE_
  if(dbres_2!= SQLITE_ROW || reset){
    [db dbResidentCredDataReset];
  }
}

+(void) dbResidentCredDataReset
{
  _DB_OPEN_
  if(pDB!=NULL && pDB!=nil){
    int dbres = SQLITE_ERROR;
    
    dbres = sqlite3_prepare(pDB, "DROP TABLE IF EXISTS residentCredData;",-1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = sqlite3_prepare(pDB, "DROP INDEX IF EXISTS residentCredData_idx01;",-1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = sqlite3_prepare(pDB, "DROP INDEX IF EXISTS residentCredData_idx02;",-1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = sqlite3_prepare(pDB, "DROP INDEX IF EXISTS residentCredData_idx03;",-1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = sqlite3_prepare(pDB, "DROP INDEX IF EXISTS residentCredData_idx04;",-1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = sqlite3_prepare(pDB,
                "CREATE TABLE IF NOT EXISTS residentCredData (\
                idx          INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, \
                credUUID    TEXT DEFAULT '-', \
                credDomain  TEXT DEFAULT '-', \
                credName    TEXT DEFAULT '-', \
                userid      TEXT DEFAULT '-', \
                uname        TEXT DEFAULT '-', \
                dname        TEXT DEFAULT '-', \
                rpidhash    TEXT DEFAULT '-', \
                cridhash    TEXT DEFAULT '-', \
                residentkey TEXT DEFAULT '-', \
                privkey     TEXT DEFAULT '-' \
                );", -1, &dbps, NULL);
    
    dbres = sqlite3_step(dbps);
    
    dbres = SQLITE_ERROR;
    dbres = sqlite3_prepare(pDB,"CREATE UNIQUE INDEX residentCredData_idx01 ON residentCredData (credUUID, rpidhash, cridhash);", -1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = SQLITE_ERROR;
    dbres = sqlite3_prepare(pDB,"CREATE INDEX residentCredData_idx02 ON residentCredData (rpidhash);", -1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = SQLITE_ERROR;
    dbres = sqlite3_prepare(pDB,"CREATE INDEX residentCredData_idx03 ON residentCredData (userid);", -1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbres = SQLITE_ERROR;
    dbres = sqlite3_prepare(pDB,"CREATE INDEX residentCredData_idx04 ON residentCredData (credUUID);", -1, &dbps, NULL);
    dbres = sqlite3_step(dbps);
    
    dbps = NULL; //obsolet
  }
  _DB_CLOSE_
}

+(void)storeResidentKeyRecord:(nonnull NSString*)credUUID
                   credDomain:(nonnull NSString*)credDomain
                     credName:(nonnull NSString*)credName
                        uname:(nonnull NSString*)uname
                       userid:(nonnull NSString*)userid
                        dname:(nonnull NSString*)dname
                     rpidhash:(nonnull NSString*)rpidhash
                     cridhash:(nonnull NSString*)cridhash
                  residentkey:(nonnull NSString*)residentkey
                      privkey:(nonnull NSString*)privkey
{
  _DB_OPEN_
  NSString *cmd;
  int dbres_1, dbres_2;
  cmd = nil;
  cmd = [NSString stringWithFormat:
       @"INSERT OR REPLACE INTO residentCredData \
       (credUUID,credDomain, credName, uname, userid, dname, rpidhash, cridhash, residentkey, privkey) \
       VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');",
         credUUID, credDomain, credName, uname, userid, dname, rpidhash, cridhash, residentkey, privkey];
  _DB_EXECUTE_( cmd, dbres_1, dbres_2 );
  _DB_CLOSE_
}
+(nullable NSString*)readResidentKeys:(nonnull NSString*)credUUID
                             rpidHash:(nonnull NSString*)rpidHash
{
  NSMutableString* sb = [[NSMutableString alloc] init];
  _DB_OPEN_
  
  /* NSString *cmd = [NSString stringWithFormat:@"SELECT residentkey, privkey from residentCredData \ */
  NSString *cmd = [NSString stringWithFormat:@"SELECT * from residentCredData \
                                               where credUUID='%@' and rpidhash='%@' ;", credUUID, rpidHash];
  dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
  [db dumpSQLResultJSON:dbps sb:sb tableName:@"rklist"];
  _DB_CLOSE_
  return [NSString stringWithString:sb];
}

+(nullable NSString*)readResidentKeys:(nonnull NSString*)credUUID
                             cridHash:(nonnull NSString*)cridHash
                             rpidHash:(nonnull NSString*)rpidHash
{
  NSMutableString* sb = [[NSMutableString alloc] init];
  _DB_OPEN_
  
  NSString *cmd = nil;
  /* cmd = [NSString stringWithFormat:@"SELECT rpidhash, cridhash, privkey from residentCredData \ */
  cmd = [NSString stringWithFormat:@"SELECT * from residentCredData \
                                     where credUUID='%@' and cridhash='%@' and rpidhash='%@';", credUUID, cridHash, rpidHash];
  dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
  [db dumpSQLResultJSON:dbps sb:sb tableName:@"rklist"];
  _DB_CLOSE_
  return [NSString stringWithString:sb];
}

+(void) delete_All_residentCredData_4_credUUID:(nonnull NSString*)credUUID
{
  _DB_OPEN_
  dbres = sqlite3_prepare(pDB,[[NSString stringWithFormat:@"DELETE from residentCredData \
                                                            where credUUID='%@';", credUUID] UTF8String], -1, &dbps, NULL);
  dbres = sqlite3_step(dbps);
  _DB_CLOSE_
}

+(void) deleteResidentCred4Idx:(NSString*)idx
{
  _DB_OPEN_
  dbres = sqlite3_prepare(pDB,[[NSString stringWithFormat:@"DELETE from residentCredData \
                                                            where idx='%@';", idx] UTF8String], -1, &dbps, NULL);
  dbres = sqlite3_step(dbps);
  _DB_CLOSE_
}

/*
 Wird nur hier gebraucht um alle RC zu löschen.
 */
+(void) delete_All_residentCredData {
  _DB_OPEN_
  dbps=NULL;
  dbres = sqlite3_prepare(pDB,[[NSString stringWithFormat:@"DELETE from residentCredData;"] UTF8String], -1, &dbps, NULL);
  dbres = sqlite3_step(dbps);
  _DB_CLOSE_
}


#pragma mark - Dump Tables -

+(NSString*) dumpTable:(NSString*)tablename {
	NSString * phrasedump = @"<root>";
_DB_OPEN_
	dbps=NULL;
	NSString *cmd = nil;
	cmd = [NSString stringWithFormat:@"SELECT * from %@;",tablename];
	dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
	int tx=0;
	phrasedump = [db dumpSQLResult:dbps dump:phrasedump ptx:&tx];
	phrasedump = [NSString stringWithFormat:@"%@</root>",phrasedump];
_DB_CLOSE_
	return phrasedump;
}

+(NSString*) dumpQuery:(NSString*)cmd {
	NSString * phrasedump = @"<root>";
_DB_OPEN_
	dbps=NULL;
	
	dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
	int tx=0;
	phrasedump = [db dumpSQLResult:dbps dump:phrasedump ptx:&tx];
	phrasedump = [NSString stringWithFormat:@"%@</root>",phrasedump];
_DB_CLOSE_
	return phrasedump;
}

+(NSString*) dumpTableJSON:(NSString*)tablename {
	NSMutableString* sb = [[NSMutableString alloc] init];
_DB_OPEN_
	dbps=NULL;
	NSString *cmd = nil;
	cmd = [NSString stringWithFormat:@"SELECT * from %@;",tablename];
	dbres = sqlite3_prepare(pDB, [cmd UTF8String], -1, &dbps, NULL);
	[db dumpSQLResultJSON:dbps sb:sb tableName:tablename];
_DB_CLOSE_
	return [NSString stringWithString:sb];
}

+(NSString*) dumpSQLResult:(sqlite3_stmt*)dbps dump:(NSString*)dump  ptx:(int*)ptx {
	while(sqlite3_step(dbps)==SQLITE_ROW){
		(*ptx)++;
		dump = [NSString stringWithFormat:@"%@<REC_%08d>",dump,(*ptx)];
		int cols = sqlite3_column_count(dbps);
		NSString *record = [[NSString alloc] init];
		for(int i=0;i<cols;i++){
			const char* n = sqlite3_column_name(dbps, i);
			const unsigned char* v = sqlite3_column_text(dbps, i); // const unsigned char
			if(n!=NULL && v!=NULL){
				NSString *nx = [[NSString alloc] initWithUTF8String:(const char*) n];
				NSString *vx = [[NSString alloc] initWithUTF8String:(const char*) v];
				if (nx!=nil && nx.length>0 && vx!=nil && vx.length>0) {
					record = [NSString stringWithFormat:@"%@<%@>%@</%@>",record,nx,vx,nx ];
				}
			}
		}
		dump = [NSString stringWithFormat:@"%@%@</REC_%08d>",dump,record,(*ptx)];
	}
	return dump;
}

+(void) dumpSQLResultJSON:(sqlite3_stmt*)dbps sb:(NSMutableString*)sb  tableName:(NSString*)tableName {
	int cres = sqlite3_step(dbps);
	
	[sb appendString:@"{\""];
	[sb appendString:tableName];
	[sb appendString:@"\":["];
	
	while(cres==SQLITE_ROW){
		[sb appendFormat:@" {"];
		int cols = sqlite3_column_count(dbps);
		NSString *record = [[NSString alloc] init];
		for(int i=0;i<cols;i++){
			const char* n = sqlite3_column_name(dbps, i);
			const unsigned char* v = sqlite3_column_text(dbps, i); // const unsigned char
			if(n!=NULL && v!=NULL){
				NSString *nx = [[NSString alloc] initWithUTF8String:(const char*) n];
				NSString *vx = [[NSString alloc] initWithUTF8String:(const char*) v];
				if (nx!=nil && nx.length>0 && vx!=nil && vx.length>0) {
					//record = [NSString stringWithFormat:@"%@<%@>%@</%@>",record,nx,vx,nx ];
					[sb appendFormat:@"\""];
					[sb appendFormat:@"%@",nx];
					[sb appendFormat:@"\""];
					[sb appendFormat:@":"];
					[sb appendFormat:@"\""];
					[sb appendFormat:@"%@",vx];
					[sb appendFormat:@"\""];
					if(i<cols-1){
						[sb appendFormat:@","];
					}
				}
			}
		}
		[sb appendFormat:@" %@}", record];
		cres = sqlite3_step(dbps);
		if(cres==SQLITE_ROW){
			[sb appendFormat:@","];
		}
	}
	[sb appendString:@"]}"];
}

#pragma mark - File write/read -

+(void) writeTXTFile:(NSString*)content fname:(NSString*)fname ext:(NSString*)ext {
	if(content!=nil){
		NSString *docDir	= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *fileName	= [NSString stringWithFormat:@"%@%@",fname,ext];
		NSString *filePath	= [docDir stringByAppendingPathComponent:fileName];
	
		NSError *error = nil;
		[content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
	}
}

+(void) deleteFile:(NSString*)fname ext:(NSString*)ext {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *docDir	= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName	= [NSString stringWithFormat:@"%@%@",fname,ext];
	NSString *filePath	= [docDir stringByAppendingPathComponent:fileName];

	[fileManager removeItemAtPath:filePath error:NULL];
}

+(NSString*) readTXTFile:(NSString*)fname ext:(NSString*)ext origBundle:(BOOL)origBundle {
	NSString *filePath = nil;
	NSString *content = nil;
	
	if(origBundle==YES){
		filePath = [[NSBundle mainBundle] pathForResource:fname ofType:ext];
	}else{
		NSString *docDir	= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *fileName	= [NSString stringWithFormat:@"%@%@",fname,ext];
		filePath			= [docDir stringByAppendingPathComponent:fileName];
	}

	if(filePath!=nil){
		NSData *dx = [NSData dataWithContentsOfFile:filePath];
		if(dx!=nil){
			content = [[NSString alloc] initWithData:dx encoding:NSUTF8StringEncoding];
		}
	}
	return content;
}

+(NSData*) readCertDataFromFile:(NSString*)fname ext:(NSString*)ext origBundle:(BOOL)origBundle {
	NSString *filePath = nil;
	NSData *content = nil;
	
	if(origBundle==YES){
		filePath = [[NSBundle mainBundle] pathForResource:fname ofType:ext];
	}else{
		NSString *docDir	= [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *fileName	= [NSString stringWithFormat:@"%@%@",fname,ext];
		filePath			= [docDir stringByAppendingPathComponent:fileName];
	}
	if(filePath!=nil){
		content = [NSData dataWithContentsOfFile:filePath];
	}
	return content;
}

#pragma mark - Core Data Handling -

+(void)setCoreDataSet:(NSString*)ltc cd:(NSData*)cd {
	NSString* idx = [NSString stringWithFormat:@"%@%@", CORE_DATA,ltc];
	[db deleteBlockdata:idx];
	[db setBlockdata:idx dataNSData:cd];
}

+(NSData*)getCoreDataSet:(NSString*)ltc {
	NSString* idx = [NSString stringWithFormat:@"%@%@", CORE_DATA,ltc];
	return [db getBlockdata:idx dataNSData:nil];
}

+(int)countAllCoreDataSets {
	return [db countAllBlockDataIndicesLike:CORE_DATA];
}

+(NSMutableArray*)getAllCoreDataSets {
	NSMutableArray* coreDataArray = [db getAllBlockDataWithIndicesLike:CORE_DATA];
	return coreDataArray;
}

#pragma mark - Table Management & Creation -

+(NSString *) appSharedDataDirectoryPath {
	NSURL *groupContainerDirectoryURL =
	[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kApplicationGroupId];
	return [groupContainerDirectoryURL path];
}

+(NSString *) db_filePath {
	NSString* shared_db_path = [self appSharedDataDirectoryPath];
	NSString *shared_db_file = [shared_db_path stringByAppendingPathComponent:CURRENT_DB_NAME];
	
	if ( ![[NSFileManager defaultManager] isReadableFileAtPath:shared_db_file] ){
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [paths objectAtIndex:0];
		NSString *local_db_file = [documentsDir stringByAppendingPathComponent:CURRENT_DB_NAME];

		if ( [[NSFileManager defaultManager] isReadableFileAtPath:local_db_file] ){
			
			NSURL *local_db_file_url = [NSURL fileURLWithPath :local_db_file];
			NSURL *shared_db_file_url = [NSURL fileURLWithPath :shared_db_file];
			
			[[NSFileManager defaultManager] copyItemAtURL:local_db_file_url toURL:shared_db_file_url error:nil];
		}
	}
	return shared_db_file;
}

@end
