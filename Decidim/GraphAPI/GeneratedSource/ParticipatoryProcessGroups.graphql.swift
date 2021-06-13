// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class ParticipatoryProcessGroupsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ParticipatoryProcessGroups {
      participatoryProcessGroups {
        __typename
        id
        name {
          __typename
          translation(locale: "en")
        }
        description {
          __typename
          translation(locale: "en")
        }
        heroImage
        participatoryProcesses {
          __typename
          id
          slug
          title {
            __typename
            translation(locale: "en")
          }
        }
      }
    }
    """

  public let operationName: String = "ParticipatoryProcessGroups"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("participatoryProcessGroups", type: .nonNull(.list(.object(ParticipatoryProcessGroup.selections)))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(participatoryProcessGroups: [ParticipatoryProcessGroup?]) {
      self.init(unsafeResultMap: ["__typename": "Query", "participatoryProcessGroups": participatoryProcessGroups.map { (value: ParticipatoryProcessGroup?) -> ResultMap? in value.flatMap { (value: ParticipatoryProcessGroup) -> ResultMap in value.resultMap } }])
    }

    /// Lists all participatory process groups
    public var participatoryProcessGroups: [ParticipatoryProcessGroup?] {
      get {
        return (resultMap["participatoryProcessGroups"] as! [ResultMap?]).map { (value: ResultMap?) -> ParticipatoryProcessGroup? in value.flatMap { (value: ResultMap) -> ParticipatoryProcessGroup in ParticipatoryProcessGroup(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.map { (value: ParticipatoryProcessGroup?) -> ResultMap? in value.flatMap { (value: ParticipatoryProcessGroup) -> ResultMap in value.resultMap } }, forKey: "participatoryProcessGroups")
      }
    }

    public struct ParticipatoryProcessGroup: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ParticipatoryProcessGroup"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .object(Name.selections)),
        GraphQLField("description", type: .object(Description.selections)),
        GraphQLField("heroImage", type: .scalar(String.self)),
        GraphQLField("participatoryProcesses", type: .nonNull(.list(.object(ParticipatoryProcess.selections)))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, name: Name? = nil, description: Description? = nil, heroImage: String? = nil, participatoryProcesses: [ParticipatoryProcess?]) {
        self.init(unsafeResultMap: ["__typename": "ParticipatoryProcessGroup", "id": id, "name": name.flatMap { (value: Name) -> ResultMap in value.resultMap }, "description": description.flatMap { (value: Description) -> ResultMap in value.resultMap }, "heroImage": heroImage, "participatoryProcesses": participatoryProcesses.map { (value: ParticipatoryProcess?) -> ResultMap? in value.flatMap { (value: ParticipatoryProcess) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// ID of this participatory process group
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The name of this participatory process group
      public var name: Name? {
        get {
          return (resultMap["name"] as? ResultMap).flatMap { Name(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "name")
        }
      }

      /// The description of this participatory process group
      public var description: Description? {
        get {
          return (resultMap["description"] as? ResultMap).flatMap { Description(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "description")
        }
      }

      /// The hero image for this participatory process group
      public var heroImage: String? {
        get {
          return resultMap["heroImage"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "heroImage")
        }
      }

      /// Lists all the participatory processes belonging to this group
      public var participatoryProcesses: [ParticipatoryProcess?] {
        get {
          return (resultMap["participatoryProcesses"] as! [ResultMap?]).map { (value: ResultMap?) -> ParticipatoryProcess? in value.flatMap { (value: ResultMap) -> ParticipatoryProcess in ParticipatoryProcess(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.map { (value: ParticipatoryProcess?) -> ResultMap? in value.flatMap { (value: ParticipatoryProcess) -> ResultMap in value.resultMap } }, forKey: "participatoryProcesses")
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

      public struct Description: GraphQLSelectionSet {
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

      public struct ParticipatoryProcess: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ParticipatoryProcess"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("slug", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .nonNull(.object(Title.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, slug: String, title: Title) {
          self.init(unsafeResultMap: ["__typename": "ParticipatoryProcess", "id": id, "slug": slug, "title": title.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The internal ID for this participatory process
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        public var slug: String {
          get {
            return resultMap["slug"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "slug")
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
}
