import ProjectDescription

public enum Secrets {
    public static let baseURL: String = required(Environment.baseUrl, name: "TUIST_BASE_URL")
    public static let serverHost: String = required(Environment.serverHost, name: "TUIST_SERVER_HOST")
    public static let googleClientID: String = required(Environment.googleClientId, name: "TUIST_GOOGLE_CLIENT_ID")
    public static let googleReversedClientID: String = required(Environment.googleReversedClientId, name: "TUIST_GOOGLE_REVERSED_CLIENT_ID")

    private static func required(_ value: Environment.Value?, name: String) -> String {
        guard case let .string(string)? = value, !string.isEmpty else {
            fatalError("\(name) 값이 없습니다. .env 파일을 확인하세요.")
        }
        return string
    }
}
