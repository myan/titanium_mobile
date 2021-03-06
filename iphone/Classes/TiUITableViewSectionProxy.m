/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#ifdef USE_TI_UITABLEVIEW

#import "TiUITableViewSectionProxy.h"
#import "TiUITableViewRowProxy.h"
#import "TiUITableViewAction.h"
#import	"TiUITableView.h"
#import "TiUtils.h"

@implementation TiUITableViewSectionProxy

@synthesize rows, table, section;

#pragma mark Internal 

-(void)_destroy
{
	self.modelDelegate = nil;
	for (TiUITableViewRowProxy * thisRow in rows)
	{
		if ([thisRow parent] == self)
		{
			[thisRow setParent:nil];
		}
	}
	RELEASE_TO_NIL(rows);
	[super _destroy];
}

-(void)_initWithProperties:(NSDictionary *)properties
{
	[super _initWithProperties:properties];
	self.modelDelegate = self;
}	

-(void)reorderRows
{
	NSInteger index = 0;
	for (TiUITableViewRowProxy *row in rows)
	{
		row.row = index++;
	}
}

-(void)triggerSectionUpdate
{
	TiUITableViewAction *action = [[[TiUITableViewAction alloc] initWithRow:nil animation:nil section:self.section type:TiUITableViewActionSectionReload] autorelease];
	[table dispatchAction:action];
}

-(void)setTable:(TiUITableView *)newTable
{
	table = newTable;
	for (TiUITableViewRowProxy * thisRow in rows)
	{
		[thisRow setTable:newTable];
	}
}

#pragma mark Public APIs

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len;
{
	return [rows countByEnumeratingWithState:state objects:stackbuf count:len];
}

-(NSInteger)rowCount
{
//The result of a method call on a nil is 0;
	return [rows count];
}

-(TiUITableViewRowProxy*)rowAtIndex:(NSInteger)index
{
//The result of a method call also happens to be nil.
	return [rows objectAtIndex:index];
}

-(void)add:(id)proxy
{
	ENSURE_SINGLE_ARG(proxy,TiUITableViewRowProxy);
	if (rows==nil)
	{
		rows = [[NSMutableArray array] retain];
	}
	[rows addObject:proxy];
}

-(void)remove:(id)proxy
{
	ENSURE_SINGLE_ARG(proxy,TiUITableViewRowProxy);
	if (rows!=nil)
	{
		[rows removeObject:proxy];
	}
}

-(UIView*)view
{
	return nil;
}

-(NSString*)headerTitle
{
	return [super valueForUndefinedKey:@"headerTitle"];
}

-(NSString*)footerTitle
{
	return [super valueForUndefinedKey:@"footerTitle"];
}

#pragma mark Delegate 

-(void)propertyChanged:(NSString*)key oldValue:(id)oldValue newValue:(id)newValue proxy:(TiProxy*)proxy
{
	// these properties should trigger a re-paint for the row
	static NSSet * TableViewSectionProperties = nil;
	if (TableViewSectionProperties==nil)
	{
		TableViewSectionProperties = [[NSSet alloc] initWithObjects:
								  @"headerTitle", @"footerTitle",
								  @"headerView", @"footerView",
								  nil];
	}
	
	
	if ([TableViewSectionProperties member:key]!=nil && table!=nil)
	{
		[self triggerSectionUpdate];
	}
}

@end

#endif