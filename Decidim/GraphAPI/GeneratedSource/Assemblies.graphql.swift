// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AssembliesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Assemblies {
      assemblies(filter: {publishedSince: "2018-01-01"}, order: {publishedAt: "asc"}) {
        __typename
        id
        title {
          __typename
          translation(locale: "en")
        }
      }
    }
    """

  public let operationName: String = "Assemblies"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("assemblies", arguments: ["filter": ["publishedSince": "2018-01-01"], "order": ["publishedAt": "asc"]], type: .list(.object(Assembly.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(assemblies: [Assembly?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "assemblies": assemblies.flatMap { (value: [Assembly?]) -> [ResultMap?] in value.map { (value: Assembly?) -> ResultMap? in value.flatMap { (value: Assembly) -> ResultMap in value.resultMap } } }])
    }

    /// Lists all assemblies
    public var assemblies: [Assembly?]? {
      get {
        return (resultMap["assemblies"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Assembly?] in value.map { (value: ResultMap?) -> Assembly? in value.flatMap { (value: ResultMap) -> Assembly in Assembly(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [Assembly?]) -> [ResultMap?] in value.map { (value: Assembly?) -> ResultMap? in value.flatMap { (value: Assembly) -> ResultMap in value.resultMap } } }, forKey: "assemblies")
      }
    }

    public struct Assembly: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Assembly"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("title", type: .nonNull(.object(Title.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, title: Title) {
        self.init(unsafeResultMap: ["__typename": "Assembly", "id": id, "title": title.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The internal ID for this assembly
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of this participatory space.
      public var title: Title {
        get {
          return Title(unsafeResultMap: resultMap["title"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "title")
        }
      }

      public struct Title: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["TranslatedField"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("translation", arguments: ["locale": "en"], type: .scalar(String.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(translation: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "TranslatedField", "translation": translation])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Returns a single translation given a locale.
        public var translation: String? {
          get {
            return resultMap["translation"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "translation")
          }
        }
      }
    }
  }
}
