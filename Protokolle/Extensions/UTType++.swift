//
//  UTType+plist.swift
//  Feather
//
//  Created by samara on 20.04.2025.
//


import UniformTypeIdentifiers

extension UTType {
	static var plist = UTType(filenameExtension: "plist", conformingTo: .data)!
	static var mobiledevicepairing = UTType(filenameExtension: "mobiledevicepairing", conformingTo: .data)!
}
