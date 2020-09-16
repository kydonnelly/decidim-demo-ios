// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AssemblyQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Assembly {
      assembly(id: "2") {
        __typename
        components(filter: {type: "Proposals"}) {
          __typename
          id
          name {
            __typename
            translation(locale: "en")
          }
        }
      }
    }
    """

  public let operationName: String = "Assembly"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("assembly", arguments: ["id": "2"], type: .object(Assembly.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(assembly: Assembly? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "assembly": assembly.flatMap { (value: Assembly) -> ResultMap in value.resultMap }])
    }

    /// Finds a assembly
    public var assembly: Assembly? {
      get {
        return (resultMap["assembly"] as? ResultMap).flatMap { Assembly(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "assembly")
      }
    }

    public struct Assembly: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Assembly"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("components", arguments: ["filter": ["type": "Proposals"]], type: .list(.object(Component.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(components: [Component?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Assembly", "components": components.flatMap { (value: [Component?]) -> [ResultMap?] in value.map { (value: Component?) -> ResultMap? in value.flatMap { (value: Component) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Lists the components this space contains.
      public var components: [Component?]? {
        get {
          return (resultMap["components"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Component?] in value.map { (value: ResultMap?) -> Component? in value.flatMap { (value: ResultMap) -> Component in Component(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Component?]) -> [ResultMap?] in value.map { (value: Component?) -> ResultMap? in value.flatMap { (value: Component) -> ResultMap in value.resultMap } } }, forKey: "components")
        }
      }

      public struct Component: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Accountability", "Result", "Blogs", "Budgets", "Debates", "Meetings", "Pages", "Proposals", "Sortitions", "Surveys"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.object(Name.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public static func makeAccountability(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Accountability", "id": id, "name": name.resultMap])
        }

        public static func makeResult(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Result", "id": id, "name": name.resultMap])
        }

        public static func makeBlogs(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Blogs", "id": id, "name": name.resultMap])
        }

        public static func makeBudgets(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Budgets", "id": id, "name": name.resultMap])
        }

        public static func makeDebates(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Debates", "id": id, "name": name.resultMap])
        }

        public static func makeMeetings(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Meetings", "id": id, "name": name.resultMap])
        }

        public static func makePages(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Pages", "id": id, "name": name.resultMap])
        }

        public static func makeProposals(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Proposals", "id": id, "name": name.resultMap])
        }

        public static func makeSortitions(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Sortitions", "id": id, "name": name.resultMap])
        }

        public static func makeSurveys(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Surveys", "id": id, "name": name.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The Component's unique ID
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The name of this component.
        public var name: Name {
          get {
            return Name(unsafeResultMap: resultMap["name"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "name")
          }
        }

        public struct Name: GraphQLSelectionSet {
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
}
