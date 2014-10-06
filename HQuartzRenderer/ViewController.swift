//
//  ViewController.swift
//  HQuartzRenderer
//
//  Created by Peter Wunder on 27.08.14.
//  Copyright (c) 2014 Peter Wunder. All rights reserved.
//

import Cocoa
import Quartz
import AVFoundation

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
	
	var blender: FrameBlender!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		rootMenu = NSApp.mainMenu
		openMenu = rootMenu.itemAtIndex(1)!.submenu!.itemWithTag(1)
		outputMenu = rootMenu.itemAtIndex(1)!.submenu!.itemWithTag(2)
		renderMenu = rootMenu.itemAtIndex(1)!.submenu!.itemWithTag(3)
		
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
		
		var compositionPath = compositionField.stringValue.stringByRemovingPercentEncoding
		var outputFramePath = outputField.stringValue.stringByRemovingPercentEncoding
		
		if compositionPath != nil && outputFramePath != nil && !compositionPath!.isEmpty && !outputFramePath!.isEmpty {
			compositionPath = (compositionPath! as NSString).substringFromIndex(7)
			outputFramePath = (outputFramePath! as NSString).substringFromIndex(7)
		} else {
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
		
		println(compositionPath)
		println(outputFramePath)
		println(videoWidth)
		println(videoHeight)
		println(frameRate)
		println(framesToBlend)
		println(videoDuration)
		println(frameDownsample)
		
		var errorMessage = ""
		if compositionPath!.isEmpty {
			errorMessage += "No composition path given.\n"
		}
		if outputFramePath!.isEmpty {
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
		
		blender = FrameBlender(blendRate: framesToBlend!)
		println("FrameBlender initialized")
		
		let videoSize = NSSize(width: videoWidth!, height: videoHeight!)
		let videoSizeDS = NSSize(width: videoWidth! * frameDownsample!, height: videoHeight! * frameDownsample!)
		
		println(videoSize)
		println(videoSizeDS)

		var qcComposition = QCComposition(file: compositionPath)
		var qcRenderer = QCRenderer(offScreenWithSize: videoSizeDS, colorSpace: CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), composition: qcComposition)
		
		let totalFrameCount = Double(frameRate!) * Double(framesToBlend!) * videoDuration
		let totalFrameCountInt = Int(totalFrameCount)
		let totalFrameCountString = totalFrameCountInt.format("0")
		let frameNumberFormat = "0" + String(totalFrameCountString.utf16Count)

		println("Frames to render: \(totalFrameCountString)")
		println("Starting.")
		
		var bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		
		dispatch_async(bgQueue, {
			for var frameIndex = 0.0; frameIndex < totalFrameCount; frameIndex++ {
				autoreleasepool {
					var frameTime: NSTimeInterval = frameIndex / Double(frameRate!) / Double(framesToBlend!)
					if !qcRenderer.renderAtTime(frameTime, arguments: nil) {
						println("Rendering failed at \(frameTime)s.")
						return
					}
					
					let frameIndexInt = Int(frameIndex) + 1
					var frame = qcRenderer.snapshotImage()
					let frameNameNumber = (frameIndexInt).format(frameNumberFormat)
					
					let compositionName = compositionPath!.lastPathComponent.stringByDeletingPathExtension
					let framePath = outputFramePath!.stringByAppendingPathComponent("\(compositionName)\(frameNameNumber).png")
					var resizedFrame: NSImage
					if frameDownsample! > 1 {
						resizedFrame = frame.resizeImage(videoSize)
					} else {
						resizedFrame = frame
					}
					
					if framesToBlend > 1 {
						resizedFrame.saveAsPngWithPath(framePath) //TODO: Change to FrameBlender later on!
					} else {
						resizedFrame.saveAsPngWithPath(framePath)
					}
					
					dispatch_async(dispatch_get_main_queue(), {
						self.previewView.image = resizedFrame
						self.renderProgressBar.doubleValue = (frameIndex + 1) / totalFrameCount * 100
						self.renderProgressLabel.stringValue = "\(frameIndexInt) of \(totalFrameCountInt) frames rendered"
						
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
		
		})
		
	}
	
	func saveAsPngWithPath(image: NSBitmapImageRep, path: String) {
		var imageData = image.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: ["": ""])
		imageData!.writeToFile(path, atomically: false)
	}
	
	@IBAction func openComposition(sender: NSButton) {
		var openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.allowedFileTypes = ["qtz"]
		
		if openPanel.runModal() == NSOKButton {
			compositionField.stringValue = openPanel.URL!.absoluteString!
		}
	}
	@IBAction func searchOutputDirectory(sender: NSButton) {
		var openPanel = NSOpenPanel()
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.resolvesAliases = true
		openPanel.allowsMultipleSelection = false
		if openPanel.runModal() == NSOKButton {
			outputField.stringValue = openPanel.URL!.absoluteString!
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














