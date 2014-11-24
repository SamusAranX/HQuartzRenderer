//
//  ViewController.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 27.08.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa
import Quartz
import AppKit
//import AVFoundation

class ViewController: NSViewController {
	
	@IBOutlet var compositionField: NSTextField!
	
	@IBOutlet var frameWidthField: NSTextField!
	@IBOutlet var frameHeightField: NSTextField!
	@IBOutlet var frameRateField: NSTextField!
	@IBOutlet var frameBlendField: NSTextField!
	@IBOutlet var frameDownsampleField: NSTextField!
	@IBOutlet var videoDurationField: NSTextField!
	
	@IBOutlet var outputField: NSTextField!
	
	@IBOutlet var openButton: NSButton!
	@IBOutlet var searchButton: NSButton!
	@IBOutlet var renderButton: NSButton!
	
	@IBOutlet var previewView: NSImageView!
	@IBOutlet var renderProgressBar: NSProgressIndicator!
	@IBOutlet var renderProgressLabel: NSTextField!
	
	var isRendering = false
	var rootMenu: NSMenu!
	var openMenu: NSMenuItem!, outputMenu: NSMenuItem!, renderMenu: NSMenuItem!
	
	var defaults = NSUserDefaults.standardUserDefaults()
	
	var blender: FrameBlender!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		rootMenu = NSApp.mainMenu
		openMenu = rootMenu.itemAtIndex(1)!.submenu!.itemWithTag(1)
		outputMenu = rootMenu.itemAtIndex(1)!.submenu!.itemWithTag(2)
		renderMenu = rootMenu.itemAtIndex(1)!.submenu!.itemWithTag(3)
		
//		let progressIndicator = NSProgressIndicator()
//		progressIndicator.style = NSProgressIndicatorStyle.BarStyle
//		progressIndicator.indeterminate = false
//		NSApplication.sharedApplication().dockTile.contentView?.addSubview(progressIndicator)
//		NSApplication.sharedApplication().dockTile.display()
//		NSApplication.sharedApplication().dockTile.badgeLabel = "80%"
		
//		compositionPath = "/Volumes/iMac Ext/Quartz Composer/Compositions/\(compositionName).qtz".stringByExpandingTildeInPath
//		outputPath = "/Volumes/iMac Ext/Quartz Composer/\(compositionName)/\(compositionName).mov".stringByExpandingTildeInPath
//		outputFramePath = "/Volumes/iMac Ext/Quartz Composer/\(compositionName)/Frames".stringByExpandingTildeInPath
	}
	
	func updateControls() {
		frameWidthField.enabled = !isRendering
		frameHeightField.enabled = !isRendering
		frameRateField.enabled = !isRendering
		frameBlendField.enabled = !isRendering
		frameDownsampleField.enabled = !isRendering
		videoDurationField.enabled = !isRendering
	
		compositionField.enabled = !isRendering
		outputField.enabled = !isRendering
		
		openButton.enabled = !isRendering
		searchButton.enabled = !isRendering
		renderButton.enabled = !isRendering
	}
	
	@IBAction func renderFrame(sender: NSButton) {
		isRendering = true
		updateControls()
		
		var compositionPath = compositionField.stringValue
		var outputFramePath = outputField.stringValue
		
		if compositionPath.isEmpty || outputFramePath.isEmpty {
			var alert = NSAlert()
			alert.messageText = "Specify input and output paths before continuing."
			alert.runModal()
			isRendering = false
			updateControls()
			return
		}
		
		let videoWidth = frameWidthField.stringValue.toInt()
		let videoHeight = frameHeightField.stringValue.toInt()
		let frameRate = frameRateField.stringValue.toInt()
		var framesToBlend = frameBlendField.stringValue.toInt()
		let videoDuration = videoDurationField.doubleValue
		let frameDownsample = frameDownsampleField.stringValue.toInt()
		
//		println(compositionPath)
//		println(outputFramePath)
//		println(videoWidth)
//		println(videoHeight)
//		println(frameRate)
//		println(framesToBlend)
//		println(videoDuration)
//		println(frameDownsample)
		
		var errorMessage = ""
		if compositionPath.isEmpty {
			errorMessage += "No composition path given.\n"
		}
		if outputFramePath.isEmpty {
			errorMessage += "No output path given.\n"
		}
		if videoWidth == nil || videoHeight == nil {
			errorMessage += "No size given.\n"
		}
		if videoWidth! <= 0 || videoHeight! <= 0 {
			errorMessage += "Invalid size given.\n"
		}
		if frameRate == nil || frameRate! <= 0 {
			errorMessage += "Invalid frame rate given.\n"
		}
		if framesToBlend == nil || framesToBlend! <= 0 {
			errorMessage += "Invalid frame blending value given.\n"
		}
		if videoDuration == 0.0 {
			errorMessage += "Invalid duration given.\n"
		}
		if frameDownsample == nil || frameDownsample! <= 0 {
			errorMessage += "Invalid downsampling value given.\n"
		}
		if !errorMessage.isEmpty {
			var alert = NSAlert()
			alert.messageText = errorMessage
			alert.runModal()
			return
		}
		
		let totalFrameCount = Double(frameRate!) * Double(framesToBlend!) * videoDuration
		let totalFrameCountInt = Int(totalFrameCount)
		let totalFrameFormatLength = totalFrameCountInt.format("0").utf16Count
		let compositionName = compositionPath.lastPathComponent.stringByDeletingPathExtension
		
		blender = FrameBlender(blendRate: framesToBlend!, frameName: compositionName, framePath: outputFramePath, paddedZeros: totalFrameFormatLength)
		blender.blendFraction = 1.0
		println("FrameBlender initialized")
		
		let videoSize = NSSize(width: videoWidth!, height: videoHeight!) //final frame size
		let videoSizeDS = NSSize(width: videoWidth! * frameDownsample!, height: videoHeight! * frameDownsample!) //size frames have to be rendered at
		
		let qcComposition = QCComposition(file: compositionPath)
		let qcRenderer = QCRenderer(offScreenWithSize: videoSizeDS, colorSpace: CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), composition: qcComposition)

		println("Frames to render: \(totalFrameCountInt)")
		
		var bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		
		dispatch_async(bgQueue, {
			let start = NSDate()
			
			var imageCache: [NSImage] = [NSImage]()
			var imageCachePaths: [String] = [String]()
			let cacheCapacity = framesToBlend!
			
			for var frameIndex = 0.0; frameIndex < totalFrameCount; frameIndex++ {
				let frameIndexInt = Int(frameIndex)
				let frameTime: NSTimeInterval = frameIndex / Double(frameRate!) / Double(framesToBlend!)
				
				autoreleasepool {
//					if !qcRenderer.renderAtTime(frameTime, arguments: nil) {
//						println("Rendering failed at \(frameTime)s.")
//						self.isRendering = false
//						self.updateControls()
//						NSApp.requestUserAttention(NSRequestUserAttentionType.InformationalRequest)
//						return
//					}
					
					if !self.blender.shouldIgnoreFrame(Int(frameIndex)) {
						println("Use frame \(frameIndexInt)")
					}
					
//					var frame = qcRenderer.snapshotImage()
//					
//					if frame == nil {
//						println("Captured frame is nil")
//						self.isRendering = false
//						self.updateControls()
//						NSApp.requestUserAttention(NSRequestUserAttentionType.InformationalRequest)
//						return
//					}
//					
//					var resizedFrame: NSImage
//					if frameDownsample! > 1 {
//						resizedFrame = frame.resizeImage(videoSize)
//					} else {
//						resizedFrame = frame
//					}
//					
//					let framePath = outputFramePath.stringByAppendingPathComponent("\(compositionName)\(frameNameNumber).png")
//					imageCache.append(resizedFrame)
//					imageCachePaths.append(framePath)
//					
//					let saveImage = imageCache.count == cacheCapacity || frameIndexInt == totalFrameCountInt
//					
//					if saveImage {
//						for var i = 0; i < imageCache.count; i++ {
//							imageCache[i].saveAsPngWithPath(imageCachePaths[i])
//						}
//						imageCache.removeAll()
//						imageCachePaths.removeAll()
//					}
//					
					dispatch_async(dispatch_get_main_queue(), {
//						if saveImage {
//							println("Updating preview image")
//							self.previewView.image = resizedFrame
//						}
						self.renderProgressBar.doubleValue = (frameIndex + 1) / totalFrameCount * 100
						self.renderProgressLabel.stringValue = "\(frameIndexInt + 1) of \(totalFrameCountInt) frames rendered"
						
						if frameIndexInt == totalFrameCountInt {
							//We're done
							self.isRendering = false
							self.updateControls()
							NSApp.requestUserAttention(NSRequestUserAttentionType.InformationalRequest)
						}
					})
//					println("Saved \(framePath)")
				}
			}
			let end = NSDate()
			
			let sysCalendar = NSCalendar.currentCalendar()
			let unitFlags = NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
			let breakdown = sysCalendar.components(unitFlags, fromDate: start, toDate: end, options: nil)
			
			let formatter = NSNumberFormatter()
			formatter.minimumIntegerDigits = 2
			
			let pluralString = totalFrameCountInt > 1 ? "frames" : "frame"
			let minuteString = formatter.stringFromNumber(breakdown.minute)!
			let secondString = formatter.stringFromNumber(breakdown.second)!
			println("Rendered \(totalFrameCountInt) \(pluralString) in \(minuteString):\(secondString).")
		})
		
	}
	
	func saveAsPngWithPath(image: NSBitmapImageRep, path: String) {
		var imageData = image.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: ["": ""])
		imageData!.writeToFile(path, atomically: false)
	}
	
	@IBAction func openComposition(sender: NSButton) {
		var openPanel = NSOpenPanel()
		openPanel.canChooseFiles = true
		openPanel.canChooseDirectories = false
		openPanel.canCreateDirectories = true
		openPanel.resolvesAliases = true
		openPanel.allowsMultipleSelection = false
		openPanel.allowedFileTypes = ["qtz"]
		
		let openPanelURL = defaults.URLForKey("openPanelURL")
		if openPanelURL != nil {
			openPanel.directoryURL = openPanelURL!
		}
		
		if openPanel.runModal() == NSOKButton {
			let openedFile = openPanel.URL?.path
			if openedFile != nil {
				compositionField.stringValue = openedFile!
				defaults.setURL(openPanel.directoryURL!, forKey: "openPanelURL")
			} else {
				println("File path is nil")
			}
			
		}
	}
	@IBAction func searchOutputDirectory(sender: NSButton) {
		var openPanel = NSOpenPanel()
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		openPanel.resolvesAliases = true
		openPanel.allowsMultipleSelection = false
		
		let savePanelURL = defaults.URLForKey("savePanelURL")
		if savePanelURL != nil {
			openPanel.directoryURL = savePanelURL!
		}
		
		if openPanel.runModal() == NSOKButton {
			let openedPath = openPanel.URL?.path
			if openedPath != nil {
				outputField.stringValue = openedPath!
				defaults.setURL(openPanel.directoryURL!, forKey: "savePanelURL")
			}
		}
	}
	func newDocument(sender: AnyObject) {
		//Clear everything
		frameWidthField.stringValue = ""
		frameHeightField.stringValue = ""
		frameRateField.stringValue = ""
		frameBlendField.stringValue = ""
		videoDurationField.stringValue = ""
		frameDownsampleField.stringValue = ""
		
		previewView.image = nil
		
		compositionField.stringValue = ""
		outputField.stringValue = ""
		
		renderButton.enabled = true
		
		renderProgressBar.doubleValue = 0
		renderProgressLabel.stringValue = "0 of 0 frames rendered" //cheap hardcoded thingy
	}
	

}














