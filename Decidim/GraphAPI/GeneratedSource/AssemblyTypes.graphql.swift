// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AssemblyTypesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query AssemblyTypes {
      assembliesTypes {
        __typename
        id
        title {
          __typename
          translation(locale: "en")
        }
      }
    }
    """

  public let operationName: String = "AssemblyTypes"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("assembliesTypes", type: .nonNull(.list(.object(AssembliesType.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(assembliesTypes: [AssembliesType?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "assembliesTypes": assembliesTypes.map { (value: AssembliesType?) -> ResultMap? in value.flatMap { (value: AssembliesType) -> ResultMap in value.resultMap } }])
    }

    /// Lists all assemblies types
    public var assembliesTypes: [AssembliesType?] {
      get {
        return (resultMap["assembliesTypes"] as! [ResultMap?]).map { (value: ResultMap?) -> AssembliesType? in value.flatMap { (value: ResultMap) -> AssembliesType in AssembliesType(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: AssembliesType?) -> ResultMap? in value.flatMap { (value: AssembliesType) -> ResultMap in value.resultMap } }, forKey: "assembliesTypes")
      }
    }

    public struct AssembliesType: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AssembliesType"]

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
        self.init(unsafeResultMap: ["__typename": "AssembliesType", "id": id, "title": title.resultMap])
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

      /// The title of this assemblies type.
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
