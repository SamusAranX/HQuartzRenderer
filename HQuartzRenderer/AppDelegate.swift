//
//  AppDelegate.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 27.08.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
	
	//Couldn't be arsed to make this a proper document-based app.
	//As such, the list of recent files will always be empty.
	//Maybe I'll implement it in the future, when there's enough documentation on how to do it in Swift.
	
	func applicationDidFinishLaunching(aNotification: NSNotification?) {
		
	}

	func applicationWillTerminate(aNotification: NSNotification?) {
		
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication!) -> Bool {
		return true
	}
}

