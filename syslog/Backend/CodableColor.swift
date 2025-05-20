//
//  CodableColor.swift
//  Antoine
//
//  Created by Serena on 09/12/2022
//

import UIKit

/// A type representing a color, which could be encoded by `Codable`
/// and represented by `UIColor`
struct CodableColor: Codable, Hashable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(uiColor: UIColor) {
        var _red: CGFloat = 0, _blue: CGFloat = 0, _green: CGFloat = 0, _alpha: CGFloat = 0
        uiColor.getRed(&_red, green: &_green, blue: &_blue, alpha: &_alpha)
        
        self.red = _red
        self.blue = _blue
        self.green = _green
        self.alpha = _alpha
    }
}
