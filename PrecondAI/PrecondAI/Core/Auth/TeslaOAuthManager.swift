import Foundation
import AuthenticationServices
import CryptoKit
import SwiftUI

@MainActor
final class TeslaOAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = TeslaOAuthManager()
    
    private let authURL = URL(string: "https://auth.tesla.com/oauth2/v3/authorize")!
    private let tokenURL = URL(string: "https://auth.tesla.com/oauth2/v3/token")!
    private let clientId: String
    private let redirectURI: String
    private let scope = "openid offline_access vehicle_device_data vehicle_cmds vehicle_charging_cmds"
    
    private var currentSession: ASWebAuthenticationSession?
    private var codeVerifier: String?
    
    @Published var isAuthenticating = false
    @Published var isAuthenticated = false
    
    override private init() {
        self.clientId = Bundle.main.infoDictionary?["TESLA_CLIENT_ID"] as? String ?? ""
        self.redirectURI = "precondai://auth/tesla/callback"
        super.init()
        self.isAuthenticated = (try? KeychainTokenStorage.getAccessToken()) != nil
    }
    
    func startAuthFlow() async throws -> TeslaAuthResponse {
        isAuthenticating = true
        
        let (codeVerifier, codeChallenge) = generatePKCE()
        self.codeVerifier = codeVerifier
        
        let authURL = buildAuthURL(codeChallenge: codeChallenge)
        
        let callbackURL: URL?
        do {
            callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL?, Error>) in
                let session = ASWebAuthenticationSession(
                    url: authURL,
                    callbackURLScheme: "precondai"
                ) { callbackURL, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: callbackURL)
                    }
                }
                
                session.presentationContextProvider = self
                self.currentSession = session
                session.start()
            }
        } catch {
            isAuthenticating = false
            throw TeslaOAuthError.authCancelled
        }
        
        guard let callbackURL = callbackURL, let code = extractCode(from: callbackURL) else {
            isAuthenticating = false
            throw TeslaOAuthError.invalidCallback
        }
        
        let response = try await exchangeCodeForToken(code: code, codeVerifier: codeVerifier)
        try KeychainTokenStorage.saveAuthResponse(response)
        
        isAuthenticated = true
        isAuthenticating = false
        return response
    }
    
    func refreshAccessToken() async throws -> TeslaAuthResponse {
        guard let refreshToken = try KeychainTokenStorage.getRefreshToken() else {
            throw TeslaOAuthError.noRefreshToken
        }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "grant_type": "refresh_token",
            "client_id": clientId,
            "refresh_token": refreshToken
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TeslaOAuthError.tokenRefreshFailed
        }
        
        let authResponse = try JSONDecoder().decode(TeslaAuthResponse.self, from: data)
        try KeychainTokenStorage.saveAuthResponse(authResponse)
        
        return authResponse
    }
    
    func signOut() throws {
        try KeychainTokenStorage.clearAll()
        isAuthenticated = false
    }
    
    private func generatePKCE() -> (codeVerifier: String, codeChallenge: String) {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let codeVerifier = Data(bytes).base64URLEncodedString()
        
        let sha256 = SHA256.hash(data: Data(codeVerifier.utf8))
        let codeChallenge = Data(sha256).base64URLEncodedString()
        
        return (codeVerifier, codeChallenge)
    }
    
    private func buildAuthURL(codeChallenge: String) -> URL {
        var components = URLComponents(string: authURL.absoluteString)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: UUID().uuidString)
        ]
        return components.url!
    }
    
    private func exchangeCodeForToken(code: String, codeVerifier: String) async throws -> TeslaAuthResponse {
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "grant_type": "authorization_code",
            "client_id": clientId,
            "code": code,
            "redirect_uri": redirectURI,
            "code_verifier": codeVerifier
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            if let errorJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                throw TeslaOAuthError.tokenExchangeFailed(errorJSON)
            }
            throw TeslaOAuthError.tokenExchangeFailed(nil)
        }
        
        return try JSONDecoder().decode(TeslaAuthResponse.self, from: data)
    }
    
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let codeItem = queryItems.first(where: { $0.name == "code" }) else {
            return nil
        }
        return codeItem.value
    }
    
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

enum TeslaOAuthError: LocalizedError {
    case authCancelled
    case invalidCallback
    case noRefreshToken
    case tokenExchangeFailed([String: Any]?)
    case tokenRefreshFailed
    
    var errorDescription: String? {
        switch self {
        case .authCancelled: return "Authorization was cancelled"
        case .invalidCallback: return "Invalid callback URL"
        case .noRefreshToken: return "No refresh token available"
        case .tokenExchangeFailed(let details):
            if let details {
                return "Token exchange failed"
            }
            return "Token exchange failed"
        case .tokenRefreshFailed: return "Token refresh failed"
        }
    }
}
