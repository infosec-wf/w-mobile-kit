//
//  WThemeTests.swift
//  WMobileKit
//
//  Copyright 2016 Workiva Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Quick
import Nimble
@testable import WMobileKit

class WThemeSpec: QuickSpec {
    override func spec() {
        describe("WThemeSpec") {
            beforeEach({
                // Init the theme manager
                WThemeManager.sharedInstance
            })

            afterEach({
                // reset the theme manager to the default theme
                WThemeManager.sharedInstance.currentTheme = DefaultTheme()
            })

            describe("when theme manager has been init"){
                it("should return a default theme if current theme not set") {
                    let currentTheme = WThemeManager.sharedInstance.currentTheme

                    expect(currentTheme is DefaultTheme).to(beTruthy())
                }

                it("should not return a custom theme if theme is not set") {
                    let currentTheme = WThemeManager.sharedInstance.currentTheme

                    expect(currentTheme is CustomTheme).to(beFalsy())
                }

                it("should return a custom theme if current theme is set to custom") {
                    WThemeManager.sharedInstance.currentTheme = CustomTheme()
                    let currentTheme = WThemeManager.sharedInstance.currentTheme

                    expect(currentTheme is CustomTheme).to(beTruthy())
                }

                it("should successfully override colors for a custom green theme when set to the current theme") {
                    WThemeManager.sharedInstance.currentTheme = GreenTheme()
                    let currentTheme = WThemeManager.sharedInstance.currentTheme

                    expect(currentTheme.navigationBarColor).to(equal(UIColor(hex: 0x42AD48)))
                    expect(currentTheme.pagingSelectorControlColor).to(equal(UIColor(hex: 0x6ABD5E)))
                }
            }
        }
    }
}