// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class AssemblyProposalsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query AssemblyProposals {
      assembly(id: "2") {
        __typename
        components(filter: {type: "Proposals"}) {
          __typename
          id
          name {
            __typename
            translation(locale: "en")
          }
          ... on Proposals {
            proposals(first: 2, after: "Mg") {
              __typename
              pageInfo {
                __typename
                endCursor
                startCursor
                hasPreviousPage
                hasNextPage
              }
              edges {
                __typename
                node {
                  __typename
                  id
                  title
                }
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "AssemblyProposals"

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
          GraphQLTypeCase(
            variants: ["Proposals": AsProposals.selections],
            default: [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("name", type: .nonNull(.object(Name.selections))),
            ]
          )
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

        public static func makeSortitions(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Sortitions", "id": id, "name": name.resultMap])
        }

        public static func makeSurveys(id: GraphQLID, name: Name) -> Component {
          return Component(unsafeResultMap: ["__typename": "Surveys", "id": id, "name": name.resultMap])
        }

        public static func makeProposals(id: GraphQLID, name: AsProposals.Name, proposals: AsProposals.Proposal? = nil) -> Component {
          return Component(unsafeResultMap: ["__typename": "Proposals", "id": id, "name": name.resultMap, "proposals": proposals.flatMap { (value: AsProposals.Proposal) -> ResultMap in value.resultMap }])
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

        public var asProposals: AsProposals? {
          get {
            if !AsProposals.possibleTypes.contains(__typename) { return nil }
            return AsProposals(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsProposals: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Proposals"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.object(Name.selections))),
            GraphQLField("proposals", arguments: ["first": 2, "after": "Mg"], type: .object(Proposal.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, name: Name, proposals: Proposal? = nil) {
            self.init(unsafeResultMap: ["__typename": "Proposals", "id": id, "name": name.resultMap, "proposals": proposals.flatMap { (value: Proposal) -> ResultMap in value.resultMap }])
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

          /// List all proposals
          public var proposals: Proposal? {
            get {
              return (resultMap["proposals"] as? ResultMap).flatMap { Proposal(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "proposals")
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

          public struct Proposal: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["ProposalConnection"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
              GraphQLField("edges", type: .list(.object(Edge.selections))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
              self.init(unsafeResultMap: ["__typename": "ProposalConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Information to aid in pagination.
            public var pageInfo: PageInfo {
              get {
                return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
              }
            }

            /// A list of edges.
            public var edges: [Edge?]? {
              get {
                return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
              }
            }

            public struct PageInfo: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["PageInfo"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("endCursor", type: .scalar(String.self)),
                GraphQLField("startCursor", type: .scalar(String.self)),
                GraphQLField("hasPreviousPage", type: .nonNull(.scalar(Bool.self))),
                GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(endCursor: String? = nil, startCursor: String? = nil, hasPreviousPage: Bool, hasNextPage: Bool) {
                self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "startCursor": startCursor, "hasPreviousPage": hasPreviousPage, "hasNextPage": hasNextPage])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// When paginating forwards, the cursor to continue.
              public var endCursor: String? {
                get {
                  return resultMap["endCursor"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "endCursor")
                }
              }

              /// When paginating backwards, the cursor to continue.
              public var startCursor: String? {
                get {
                  return resultMap["startCursor"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "startCursor")
                }
              }

              /// When paginating backwards, are there more items?
              public var hasPreviousPage: Bool {
                get {
                  return resultMap["hasPreviousPage"]! as! Bool
                }
                set {
                  resultMap.updateValue(newValue, forKey: "hasPreviousPage")
                }
              }

              /// When paginating forwards, are there more items?
              public var hasNextPage: Bool {
                get {
                  return resultMap["hasNextPage"]! as! Bool
                }
                set {
                  resultMap.updateValue(newValue, forKey: "hasNextPage")
                }
              }
            }

            public struct Edge: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["ProposalEdge"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("node", type: .object(Node.selections)),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(node: Node? = nil) {
                self.init(unsafeResultMap: ["__typename": "ProposalEdge", "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// The item at the end of the edge.
              public var node: Node? {
                get {
                  return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "node")
                }
              }

              public struct Node: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Proposal"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                  GraphQLField("title", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(id: GraphQLID, title: String) {
                  self.init(unsafeResultMap: ["__typename": "Proposal", "id": id, "title": title])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: GraphQLID {
                  get {
                    return resultMap["id"]! as! GraphQLID
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "id")
                  }
                }

                /// This proposal's title
                public var title: String {
                  get {
                    return resultMap["title"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "title")
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
