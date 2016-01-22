//
//  QuickSpecs.swift
//  SGDTestLogDemo
//
//  Created by Sangen on 1/21/16.
//  Copyright © 2016 Sangen. All rights reserved.
//

import XCTest
import Quick
import Nimble

class QuickSpecs: QuickSpec {
    override func spec() {

        it("succeed it") {
            expect([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5]
        }

        it("fail it") {
            expect([1, 2, 3, 4, 5]) == [1, 3, 5]
        }

        context("context") {
            it("succeed it") {
                expect("same text") == "same text"
            }

            it("fail it") {
                expect("same text") == "different text"
            }
        }

        describe("Quick") {
            describe("describe document") {
                context("context") {
                    it("succeed it") {
                        expect("same text") == "same text"
                    }

                    it("fail it") {
                        expect("same text") == "different text"
                    }
                }
            }
        }
    }
}
