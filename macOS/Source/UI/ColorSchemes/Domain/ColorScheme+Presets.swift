//
//  ColorScheme+Presets.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

extension ColorScheme {
    
    static let lava: ColorScheme = .init(name: "Lava", systemDefined: true,
                                         
                                         backgroundColor: PlatformColor(red: 0.144, green: 0.144, blue: 0.144),
                                         buttonColor: .white70Percent,
                                         
                                         captionTextColor: .white40Percent,
                                         
                                         primaryTextColor: .white70Percent,
                                         secondaryTextColor: .white50Percent,
                                         tertiaryTextColor: .white40Percent,
                                         
                                         primarySelectedTextColor: .white,
                                         secondarySelectedTextColor: .white75Percent,
                                         tertiarySelectedTextColor: .white50Percent,
                                         
                                         textSelectionColor: .black,
                                         
                                         activeControlColor: .lava,
                                         inactiveControlColor: .white40Percent,
                                         suppressedControlColor: PlatformColor(red: 0.5, green: 0.204, blue: 0.107))
    
    static let blackAqua: ColorScheme = .init(name: "Black & aqua", systemDefined: true,
                                              
                                              backgroundColor: .white8Percent,
                                              buttonColor: .white90Percent,
                                              
                                              captionTextColor: .white40Percent,
                                              
                                              primaryTextColor: .white70Percent,
                                              secondaryTextColor: .white45Percent,
                                              tertiaryTextColor: .white30Percent,
                                              
                                              primarySelectedTextColor: .white,
                                              secondarySelectedTextColor: .white75Percent,
                                              tertiarySelectedTextColor: .white50Percent,
                                              
                                              textSelectionColor: .white15Percent,
                                              
                                              activeControlColor: .aqua,
                                              inactiveControlColor: .white30Percent,
                                              suppressedControlColor: PlatformColor(red: 0, green: 0.31, blue: 0.5))
    
    static let blackGreen: ColorScheme = .init(name: "Black & green", systemDefined: true,
                                               
                                               backgroundColor: .white8Percent,
                                               buttonColor: .white90Percent,
                                               
                                               captionTextColor: .white40Percent,
                                               
                                               primaryTextColor: .white70Percent,
                                               secondaryTextColor: .white45Percent,
                                               tertiaryTextColor: .white30Percent,
                                               
                                               primarySelectedTextColor: .white,
                                               secondarySelectedTextColor: .white75Percent,
                                               tertiarySelectedTextColor: .white50Percent,
                                               
                                               textSelectionColor: .white15Percent,
                                               
                                               activeControlColor: .green75Percent,
                                               inactiveControlColor: .white30Percent,
                                               suppressedControlColor: .green50Percent)
    
    static let grayRed: ColorScheme = .init(name: "Gray & red", systemDefined: true,
                                               
                                               backgroundColor: .white20Percent,
                                               buttonColor: .white55Percent,
                                               
                                               captionTextColor: .white40Percent,
                                               
                                               primaryTextColor: .white60Percent,
                                               secondaryTextColor: .white50Percent,
                                               tertiaryTextColor: .white40Percent,
                                               
                                               primarySelectedTextColor: .white80Percent,
                                               secondarySelectedTextColor: .white70Percent,
                                               tertiarySelectedTextColor: .white60Percent,
                                               
                                               textSelectionColor: .black,
                                               
                                            activeControlColor: .red,
                                               inactiveControlColor: .black,
                                               suppressedControlColor: PlatformColor(red: 0.75, green: 0, blue: 0))
    
    static let whiteBlight: ColorScheme = .init(name: "White blight", systemDefined: true,
                                                
                                                backgroundColor: .white75Percent,
                                                buttonColor: .black,
                                                
                                                captionTextColor: .white30Percent,
                                                
                                                primaryTextColor: .black,
                                                secondaryTextColor: .white25Percent,
                                                tertiaryTextColor: .white40Percent,
                                                
                                                primarySelectedTextColor: .white,
                                                secondarySelectedTextColor: .white85Percent,
                                                tertiarySelectedTextColor: .white20Percent,
                                                
                                                textSelectionColor: .white60Percent,
                                                
                                                activeControlColor: .black,
                                                inactiveControlColor: .white50Percent,
                                                suppressedControlColor: .white25Percent)
    
    static let gloomyDay: ColorScheme = .init(name: "Gloomy day", systemDefined: true,
                                              
                                              backgroundColor: .white20Percent,
                                              buttonColor: .white80Percent,
                                              
                                              captionTextColor: .white40Percent,
                                              
                                              primaryTextColor: .white70Percent,
                                              secondaryTextColor: .white45Percent,
                                              tertiaryTextColor: .white35Percent,
                                              
                                              primarySelectedTextColor: .white,
                                              secondarySelectedTextColor: .white75Percent,
                                              tertiarySelectedTextColor: .white50Percent,
                                              
                                              textSelectionColor: .black,
                                              
                                              activeControlColor: .white70Percent,
                                              inactiveControlColor: .white35Percent,
                                              suppressedControlColor: .white50Percent)
    
    static let brownie: ColorScheme = .init(name: "Brownie", systemDefined: true,
                                            
                                            backgroundColor: PlatformColor(red: 0.25, green: 0.162, blue: 0.131),
                                            buttonColor: PlatformColor(red: 0.636, green: 0.483, blue: 0.44),
                                            
                                            captionTextColor: PlatformColor(red: 0.536, green: 0.356, blue: 0.29),
                                            
                                            primaryTextColor: PlatformColor(red: 0.614, green: 0.407, blue: 0.332),
                                            secondaryTextColor: PlatformColor(red: 0.448, green: 0.297, blue: 0.243),
                                            tertiaryTextColor: PlatformColor(red: 0.38, green: 0.252, blue: 0.206),
                                            
                                            primarySelectedTextColor: PlatformColor(red: 0.856, green: 0.346, blue: 0.286),
                                            secondarySelectedTextColor: PlatformColor(red: 0.668, green: 0.271, blue: 0.221),
                                            tertiarySelectedTextColor: PlatformColor(red: 0.521, green: 0.212, blue: 0.171),
                                            
                                            textSelectionColor: PlatformColor(red: 0.073, green: 0.047, blue: 0.038),
                                            
                                            activeControlColor: PlatformColor(red: 0.8, green: 0.329, blue: 0.293),
                                            inactiveControlColor: PlatformColor(red: 0.668, green: 0.507, blue: 0.436),
                                            suppressedControlColor: PlatformColor(red: 0.599, green: 0.245, blue: 0.217))
    
    static let poolsideFM: ColorScheme = .init(name: "Poolside.fm", systemDefined: true,
                                                
                                                backgroundColor: PlatformColor(red: 1, green: 0.7882353, blue: 0.7882353),
                                                buttonColor: .black,
                                                
                                                captionTextColor: .black,
                                                
                                                primaryTextColor: .black,
                                                secondaryTextColor: .white20Percent,
                                                tertiaryTextColor: .white40Percent,
                                                
                                                primarySelectedTextColor: .white,
                                                secondarySelectedTextColor: .white80Percent,
                                                tertiarySelectedTextColor: .white60Percent,
                                                
                                                textSelectionColor: PlatformColor(red: 0.55, green: 0.38, blue: 0.39),
                                                
                                                activeControlColor: .black,
                                                inactiveControlColor: .white50Percent,
                                                suppressedControlColor: .white25Percent)
    
    static let allPresets: [ColorScheme] = [.lava, .blackAqua, .blackGreen, .grayRed, .whiteBlight, .gloomyDay, .brownie, .poolsideFM]
}
