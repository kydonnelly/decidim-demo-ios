// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class SessionQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Session {
      session {
        __typename
        user {
          __typename
          name
          nickname
          avatarUrl
          badge
          deleted
          organizationName
          profilePath
        }
      }
    }
    """

  public let operationName: String = "Session"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("session", type: .object(Session.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(session: Session? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "session": session.flatMap { (value: Session) -> ResultMap in value.resultMap }])
    }

    /// Return's information about the logged in user
    public var session: Session? {
      get {
        return (resultMap["session"] as? ResultMap).flatMap { Session(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "session")
      }
    }

    public struct Session: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Session"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("user", type: .object(User.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(user: User? = nil) {
        self.init(unsafeResultMap: ["__typename": "Session", "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The current user
      public var user: User? {
        get {
          return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "user")
        }
      }

      public struct User: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("nickname", type: .nonNull(.scalar(String.self))),
          GraphQLField("avatarUrl", type: .nonNull(.scalar(String.self))),
          GraphQLField("badge", type: .nonNull(.scalar(String.self))),
          GraphQLField("deleted", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("organizationName", type: .nonNull(.scalar(String.self))),
          GraphQLField("profilePath", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, nickname: String, avatarUrl: String, badge: String, deleted: Bool, organizationName: String, profilePath: String) {
          self.init(unsafeResultMap: ["__typename": "User", "name": name, "nickname": nickname, "avatarUrl": avatarUrl, "badge": badge, "deleted": deleted, "organizationName": organizationName, "profilePath": profilePath])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The user's name
        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// The user's nickname
        public var nickname: String {
          get {
            return resultMap["nickname"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "nickname")
          }
        }

        /// The user's avatar url
        public var avatarUrl: String {
          get {
            return resultMap["avatarUrl"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "avatarUrl")
          }
        }

        /// A badge for the user group
        public var badge: String {
          get {
            return resultMap["badge"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "badge")
          }
        }

        /// Whether the user's account has been deleted or not
        public var deleted: Bool {
          get {
            return resultMap["deleted"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "deleted")
          }
        }

        /// The user's organization name
        public var organizationName: String {
          get {
            return resultMap["organizationName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "organizationName")
          }
        }

        /// The user's profile url
        public var profilePath: String {
          get {
            return resultMap["profilePath"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "profilePath")
          }
        }
      }
    }
  }
}
