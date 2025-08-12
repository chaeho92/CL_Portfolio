import Alamofire
import RxSwift

class DefaultDiaryService: DiaryService {

    private let networkService: NetworkService
    private let jwtKeychainService: JwtKeychainService

    init(
        networkService: NetworkService? = nil,
        jwtKeychainService: JwtKeychainService? = nil
    ) {
        self.networkService = networkService ?? NetworkService(baseURL: URL(string: AppConfiguration.shared.baseURL)!)
        self.jwtKeychainService = jwtKeychainService ?? DefaultJwtKeychainService()
    }

    func updateDiary(_ diary: Diary) -> Observable<Diary> {
        let endpoint = Endpoint<BaseResponse<Diary>>(
            path: "api/diary",
            method: .put,
            parameters: diary.toJsonObject(),
            headers: HTTPHeaders(["Authorization": "Bearer \(jwtKeychainService.getJwt() ?? .init())"])
        )

        return networkService.request(endpoint).map { $0.data }
    }

    func deleteDiaryById(_ id: String) -> Observable<Void> {
        let endpoint = Endpoint<BaseResponse<EmptyResponse>>(
            path: "api/diary/\(id)",
            method: .delete,
            headers: HTTPHeaders(["Authorization": "Bearer \(jwtKeychainService.getJwt() ?? .init())"])
        )

        return networkService.request(endpoint).map { _ in }
    }

    func getDiariesByLocationAndShared(latitude: Double, longitude: Double, range: Double) -> Observable<[Diary]> {
        let endpoint = Endpoint<BaseResponse<[Diary]>>(
            path: "api/diary/multiple/\(latitude)/\(longitude)/\(range)",
            method: .get,
            headers: HTTPHeaders(["Authorization": "Bearer \(jwtKeychainService.getJwt() ?? .init())"])
        )

        return networkService.request(endpoint).map { $0.data }
    }

    func getDiaryById(_ id: String) -> Observable<Diary> {
        let endpoint = Endpoint<BaseResponse<Diary>>(
            path: "api/diary/single/\(id)",
            method: .get,
            headers: HTTPHeaders(["Authorization": "Bearer \(jwtKeychainService.getJwt() ?? .init())"])
        )

        return networkService.request(endpoint).map { $0.data }
    }

}

extension DefaultDiaryService {

    func restoreDiaries(userId: Int) -> Observable<[Diary]> {
        let endpoint = Endpoint<BaseResponse<[Diary]>>(
            path: "api/diary/restore/\(userId)",
            method: .get,
            headers: HTTPHeaders(["Authorization": "Bearer \(jwtKeychainService.getJwt() ?? .init())"])
        )

        return networkService.request(endpoint).map { $0.data }
    }

}
