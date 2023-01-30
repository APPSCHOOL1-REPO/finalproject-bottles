// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var email: String?
  public var followShopList: [String?]?
  public var followItemList: [String?]?
  public var pickupList: [String?]?
  public var userPhoneNumber: [String?]?
  public var recentlyBottles: [String?]?
  public var nickname: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      email: String? = nil,
      followShopList: [String?]? = nil,
      followItemList: [String?]? = nil,
      pickupList: [String?]? = nil,
      userPhoneNumber: [String?]? = nil,
      recentlyBottles: [String?]? = nil,
      nickname: String? = nil) {
    self.init(id: id,
      email: email,
      followShopList: followShopList,
      followItemList: followItemList,
      pickupList: pickupList,
      userPhoneNumber: userPhoneNumber,
      recentlyBottles: recentlyBottles,
      nickname: nickname,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      email: String? = nil,
      followShopList: [String?]? = nil,
      followItemList: [String?]? = nil,
      pickupList: [String?]? = nil,
      userPhoneNumber: [String?]? = nil,
      recentlyBottles: [String?]? = nil,
      nickname: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.email = email
      self.followShopList = followShopList
      self.followItemList = followItemList
      self.pickupList = pickupList
      self.userPhoneNumber = userPhoneNumber
      self.recentlyBottles = recentlyBottles
      self.nickname = nickname
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}