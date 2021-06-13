// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class OrganizationQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Organization {
      organization {
        __typename
        name
        stats {
          __typename
          name
          value
        }
      }
    }
    """

  public let operationName: String = "Organization"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("organization", type: .object(Organization.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(organization: Organization? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "organization": organization.flatMap { (value: Organization) -> ResultMap in value.resultMap }])
    }

    /// The current organization
    public var organization: Organization? {
      get {
        return (resultMap["organization"] as? ResultMap).flatMap { Organization(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "organization")
      }
    }

    public struct Organization: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Organization"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("stats", type: .list(.object(Stat.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(name: String? = nil, stats: [Stat?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Organization", "name": name, "stats": stats.flatMap { (value: [Stat?]) -> [ResultMap?] in value.map { (value: Stat?) -> ResultMap? in value.flatMap { (value: Stat) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The name of the current organization
      public var name: String? {
        get {
          return resultMap["name"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "name")
        }
      }

      /// The statistics associated to this object
      public var stats: [Stat?]? {
        get {
          return (resultMap["stats"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Stat?] in value.map { (value: ResultMap?) -> Stat? in value.flatMap { (value: ResultMap) -> Stat in Stat(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Stat?]) -> [ResultMap?] in value.map { (value: Stat?) -> ResultMap? in value.flatMap { (value: Stat) -> ResultMap in value.resultMap } } }, forKey: "stats")
        }
      }

      public struct Stat: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Statistic"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, value: Int) {
          self.init(unsafeResultMap: ["__typename": "Statistic", "name": name, "value": value])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the statistic
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// The actual value of the statistic
        public var value: Int {
          get {
            return resultMap["value"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}
