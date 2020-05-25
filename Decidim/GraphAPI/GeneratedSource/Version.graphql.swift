// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class VersionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Version {
      decidim {
        __typename
        version
      }
    }
    """

  public let operationName: String = "Version"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("decidim", type: .object(Decidim.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(decidim: Decidim? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "decidim": decidim.flatMap { (value: Decidim) -> ResultMap in value.resultMap }])
    }

    /// Decidim's framework properties.
    public var decidim: Decidim? {
      get {
        return (resultMap["decidim"] as? ResultMap).flatMap { Decidim(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "decidim")
      }
    }

    public struct Decidim: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Decidim"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("version", type: .nonNull(.scalar(String.self))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(version: String) {
        self.init(unsafeResultMap: ["__typename": "Decidim", "version": version])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The current decidim's version of this deployment.
      public var version: String {
        get {
          return resultMap["version"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "version")
        }
      }
    }
  }
}
