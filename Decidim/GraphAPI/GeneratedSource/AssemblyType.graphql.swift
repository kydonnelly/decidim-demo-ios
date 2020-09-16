// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AssemblyTypeQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query AssemblyType {
      assembliesType(id: "2") {
        __typename
        id
        assemblies {
          __typename
          id
        }
        title {
          __typename
          translation(locale: "en")
        }
      }
    }
    """

  public let operationName: String = "AssemblyType"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("assembliesType", arguments: ["id": "2"], type: .object(AssembliesType.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(assembliesType: AssembliesType? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "assembliesType": assembliesType.flatMap { (value: AssembliesType) -> ResultMap in value.resultMap }])
    }

    /// Finds an assemblies type group
    public var assembliesType: AssembliesType? {
      get {
        return (resultMap["assembliesType"] as? ResultMap).flatMap { AssembliesType(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "assembliesType")
      }
    }

    public struct AssembliesType: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AssembliesType"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("assemblies", type: .nonNull(.list(.object(Assembly.selections)))),
        GraphQLField("title", type: .nonNull(.object(Title.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, assemblies: [Assembly?], title: Title) {
        self.init(unsafeResultMap: ["__typename": "AssembliesType", "id": id, "assemblies": assemblies.map { (value: Assembly?) -> ResultMap? in value.flatMap { (value: Assembly) -> ResultMap in value.resultMap } }, "title": title.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The assemblies type's unique ID
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// Assemblies with this assemblies type
      public var assemblies: [Assembly?] {
        get {
          return (resultMap["assemblies"] as! [ResultMap?]).map { (value: ResultMap?) -> Assembly? in value.flatMap { (value: ResultMap) -> Assembly in Assembly(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Assembly?) -> ResultMap? in value.flatMap { (value: Assembly) -> ResultMap in value.resultMap } }, forKey: "assemblies")
        }
      }

      /// The title of this assemblies type.
      public var title: Title {
        get {
          return Title(unsafeResultMap: resultMap["title"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "title")
        }
      }

      public struct Assembly: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Assembly"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID) {
          self.init(unsafeResultMap: ["__typename": "Assembly", "id": id])
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
