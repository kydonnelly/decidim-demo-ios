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
    
    case bell = 0xe900
    case check = 0xe901
    case chevron_down = 0xe902
    case chevron_left = 0xe903
    case chevron_up = 0xe904
    case circle = 0xe905
    case edit_2 = 0xe906
    case feather = 0xe907
    case heart1 = 0xe908
    case home = 0xe909
    case message_circle = 0xe90a
    case plus = 0xe90b
    case `repeat` = 0xe90c
    case search = 0xe90d
    case thumbs_down = 0xe90e
    case thumbs_up = 0xe90f
    case user_check = 0xe910
    case user = 0xe911
    case users = 0xe912
    case x = 0xe913
    case image = 0xe914
    case bubbles3 = 0xe96f
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
    case cancel_circle = 0xea0d
    case cross = 0xea0f
    case checkmark = 0xea10
    case infinite = 0xea2f
    case circle_up = 0xea41
    case checkbox_checked = 0xea52
    case checkbox_unchecked = 0xea53
    
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
