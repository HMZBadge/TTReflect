//
//  TTReflectTests.swift
//  TTReflectTests
//
//  Created by 谢许峰 on 16/1/10.
//  Copyright © 2016年 tifatsubasa. All rights reserved.
//

import XCTest
@testable import TTReflect
import Alamofire
import SwiftyJSON

class TTReflectTests: XCTestCase {
  
  func assertBook(book: Book) {
    XCTAssertEqual(book.tt, "满月之夜白鲸现")
    XCTAssertEqual(book.tags.count, 8)
    XCTAssertEqual(book.tags.first?.count, 136)
    XCTAssertNotNil(book.image)
    XCTAssertEqual(book.image, "")
    XCTAssertEqual(book.imgs.medium, "")
    XCTAssertEqual(book.imgs.large, "https://img1.doubanio.com/lpic/s1747553.jpg")
    XCTAssertEqual(book.tags.last?.title, "")
    XCTAssertEqual(book.tags.first?.title, "片山恭一")
    XCTAssertNotNil(book.test_null)
  }
  
  func assertCast(casts: [Cast]) {
    XCTAssertEqual(casts.count, 4)
    XCTAssertEqual(casts.first?.alt, "http://movie.douban.com/celebrity/1054395/")
    XCTAssertEqual(casts.last?.avatars.medium, "https://img1.doubanio.com/img/celebrity/medium/42033.jpg")
  }
  
  func testConvert() {
    let convertUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("convert", ofType: nil)!)
    let convertData = NSData(contentsOfURL: convertUrl)
    let convert = Reflect<Convert>.mapObject(data: convertData)
    XCTAssertEqual(convert.scns, 42.3)
    XCTAssertEqual(convert.ncss, "23.98")
    XCTAssertEqual(convert.bcss, "1")
    XCTAssertEqual(convert.scbs, true)
    XCTAssertEqual(convert.scbe, false)
  }
  
  func testBookData() {
    let bookUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("book", ofType: nil)!)
    let bookData = NSData(contentsOfURL: bookUrl)
    let book = Reflect<Book>.mapObject(data: bookData)
    assertBook(book)
  }
  
  func testBookJson() {
    let bookUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("book", ofType: nil)!)
    let bookData = NSData(contentsOfURL: bookUrl)
    let json = try! NSJSONSerialization.JSONObjectWithData(bookData!, options: .MutableContainers)
    let book = Reflect<Book>.mapObject(json: json)
    assertBook(book)
  }
  
  func testCastData() {
    let castUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("casts", ofType: nil)!)
    let castsData = NSData(contentsOfURL: castUrl)
    let casts = Reflect<Cast>.mapObjects(data: castsData)
    assertCast(casts)
  }
  
  func testCastJson() {
    let castUrl = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("casts", ofType: nil)!)
    let castsData = NSData(contentsOfURL: castUrl)
    let castsJson = try! NSJSONSerialization.JSONObjectWithData(castsData!, options: .MutableContainers)
    let casts = Reflect<Cast>.mapObjects(json: castsJson)
    assertCast(casts)
  }
  
  func testAlamofire() {
     let expectation = expectationWithDescription("Alamofire request")
    Alamofire.request(.GET, "https://api.douban.com/v2/movie/subject/1764796", parameters: nil)
      .response { request, response, data, error in
        let json = JSON(data: data!)
        debugPrint(json)
        let movie = Reflect<Movie>.mapObject(json: json.rawValue)
        XCTAssertEqual(movie.title, "机器人9号")
//        XCTAssertEqual(movie.images.small, "https://img1.doubanio.com/view/movie_poster_cover/ipst/public/p494268647.jpg")
        XCTAssertEqual(movie.subtype, "movie")
        expectation.fulfill()
    }
    waitForExpectationsWithTimeout(10, handler: nil)
  }
  
  func testAlamofireObjects() {
    let expectation = expectationWithDescription("Alamofire objects request")
    Alamofire.request(.GET, "https://api.douban.com/v2/movie/in_theaters", parameters: nil)
      .response { request, response, data, error in
        let json = JSON(data: data!)
        let movie = Reflect<Movie>.mapObjects(json: json["subjects"].rawValue)
        XCTAssertNotEqual(movie.first?.title, "")
        expectation.fulfill()
    }
    waitForExpectationsWithTimeout(10, handler: nil)
  }
}
