// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class RecentParticipatoryProcessesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query RecentParticipatoryProcesses {
      participatoryProcesses(filter: {publishedSince: "2018-01-01"}, order: {publishedAt: "asc"}) {
        __typename
        id
        slug
        title {
          __typename
          translation(locale: "en")
        }
      }
    }
    """

  public let operationName: String = "RecentParticipatoryProcesses"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("participatoryProcesses", arguments: ["filter": ["publishedSince": "2018-01-01"], "order": ["publishedAt": "asc"]], type: .list(.object(ParticipatoryProcess.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(participatoryProcesses: [ParticipatoryProcess?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "participatoryProcesses": participatoryProcesses.flatMap { (value: [ParticipatoryProcess?]) -> [ResultMap?] in value.map { (value: ParticipatoryProcess?) -> ResultMap? in value.flatMap { (value: ParticipatoryProcess) -> ResultMap in value.resultMap } } }])
    }

    /// Lists all participatory_processes
    public var participatoryProcesses: [ParticipatoryProcess?]? {
      get {
        return (resultMap["participatoryProcesses"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ParticipatoryProcess?] in value.map { (value: ResultMap?) -> ParticipatoryProcess? in value.flatMap { (value: ResultMap) -> ParticipatoryProcess in ParticipatoryProcess(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [ParticipatoryProcess?]) -> [ResultMap?] in value.map { (value: ParticipatoryProcess?) -> ResultMap? in value.flatMap { (value: ParticipatoryProcess) -> ResultMap in value.resultMap } } }, forKey: "participatoryProcesses")
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
