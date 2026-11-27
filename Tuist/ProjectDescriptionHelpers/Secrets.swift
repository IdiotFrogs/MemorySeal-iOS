import ProjectDescription

public enum Secrets {
    public enum Dev {
        public static let baseURL: String = required(Environment.devBaseUrl, name: "TUIST_DEV_BASE_URL")
        public static let serverHost: String = required(Environment.devServerHost, name: "TUIST_DEV_SERVER_HOST")
        public static let googleClientID: String = required(Environment.devGoogleClientId, name: "TUIST_DEV_GOOGLE_CLIENT_ID")
        public static let googleReversedClientID: String = required(Environment.devGoogleReversedClientId, name: "TUIST_DEV_GOOGLE_REVERSED_CLIENT_ID")
    }

    public enum Prod {
        public static let baseURL: String = required(Environment.prodBaseUrl, name: "TUIST_PROD_BASE_URL")
        public static let googleClientID: String = required(Environment.prodGoogleClientId, name: "TUIST_PROD_GOOGLE_CLIENT_ID")
        public static let googleReversedClientID: String = required(Environment.prodGoogleReversedClientId, name: "TUIST_PROD_GOOGLE_REVERSED_CLIENT_ID")
    }

    private static func required(_ value: Environment.Value?, name: String) -> String {
        guard case let .string(string)? = value, !string.isEmpty else {
            fatalError("\(name) 값이 없습니다. .env 파일을 확인하세요.")
        }
        return string
    }
}
