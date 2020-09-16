//
//  KrakenIconFont.swift
//
//  !!! AUTO-GENERATED FILE !!!!
//  !!! DO NOT EDIT DIRECTLY !!!
//  !!! generate_icon_font.py !!
//

import KTDIconFont

public enum KrakenIcon: unichar, IconFont {
    case notFound = 0x0
    
    case image = 0xe90d
    case bubble2 = 0xe96e
    case bubbles3 = 0xe96f
    case user = 0xe971
    case users = 0xe972
    case hourglass = 0xe979
    case spinner8 = 0xe981
    case shrink2 = 0xe98c
    case cog = 0xe994
    case power_switch = 0xe9b6
    case clipboard = 0xe9b8
    case menu = 0xe9bd
    case star_empty = 0xe9d7
    case star_full = 0xe9d9
    case heart = 0xe9da
    case sad = 0xe9e5
    case minus = 0xea0b
    case cancel_circle = 0xea0d
    case cross = 0xea0f
    case checkmark = 0xea10
    case infinite = 0xea2f
    case circle_up = 0xea41
    case checkbox_checked = 0xea52
    case checkbox_unchecked = 0xea53
    case circle = 0xea56
    
    public static var fontFileName: String {
        return "Kraken"
    }
}

extension UIImageView: IconAppearance {
    public typealias AssociatedIcon = KrakenIcon
}

extension UIButton: IconAppearance {
    public typealias AssociatedIcon = KrakenIcon
}

extension UIBarButtonItem: IconAppearance {
    public typealias AssociatedIcon = KrakenIcon
}

extension UITabBarItem: IconAppearance {
    public typealias AssociatedIcon = KrakenIcon
}
