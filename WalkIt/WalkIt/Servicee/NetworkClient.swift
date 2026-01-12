//
//  NetworkClient.swift
//  WalkIt
//
//  Created by 조석진 on 12/13/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case unknown(Error)
}

final class NetworkClient {

    func request<T: Decodable>(
        _ request: URLRequest,
        responseType: T.Type
    ) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http2 = response as? HTTPURLResponse {
                debugPrint("request \(http2.statusCode)")
            }
            guard let http = response as? HTTPURLResponse else {
                debugPrint("url에러: \(request)")
                throw NetworkError.invalidResponse
            }

            guard (200..<300).contains(http.statusCode) else {
                debugPrint("http에러: \(http.statusCode)")
                throw NetworkError.httpError(http.statusCode)
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                debugPrint("디코딩 실패 data: \(String(data: data, encoding: .utf8) ?? "")")
                throw NetworkError.decodingError
            }
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    func requestVoid(_ request: URLRequest) async throws {
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http2 = response as? HTTPURLResponse {
                debugPrint("requestVoid \(http2.statusCode)")
            }
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw NetworkError.invalidResponse
            }
        } catch {
            debugPrint("알수없는 에러: \(error)")
            throw NetworkError.unknown(error)
        }
    }
}
