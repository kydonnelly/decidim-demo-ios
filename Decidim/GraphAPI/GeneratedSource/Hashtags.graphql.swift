// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class HashtagsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Hashtags {
      hashtags {
        __typename
        name
      }
    }
    """

  public let operationName: String = "Hashtags"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("hashtags", type: .list(.object(Hashtag.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(hashtags: [Hashtag?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "hashtags": hashtags.flatMap { (value: [Hashtag?]) -> [ResultMap?] in value.map { (value: Hashtag?) -> ResultMap? in value.flatMap { (value: Hashtag) -> ResultMap in value.resultMap } } }])
    }

    /// The hashtags for current organization
    public var hashtags: [Hashtag?]? {
      get {
        return (resultMap["hashtags"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Hashtag?] in value.map { (value: ResultMap?) -> Hashtag? in value.flatMap { (value: ResultMap) -> Hashtag in Hashtag(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Hashtag?]) -> [ResultMap?] in value.map { (value: Hashtag?) -> ResultMap? in value.flatMap { (value: Hashtag) -> ResultMap in value.resultMap } } }, forKey: "hashtags")
      }
    }

    public struct Hashtag: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["HashtagType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String) {
        self.init(unsafeResultMap: ["__typename": "HashtagType", "name": name])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The hashtag's name
      public var name: String {
        get {
          return resultMap["name"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}
