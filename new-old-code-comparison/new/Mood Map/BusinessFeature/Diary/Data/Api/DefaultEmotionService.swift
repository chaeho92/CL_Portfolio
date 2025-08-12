import Alamofire
import RxSwift

class DefaultEmotionService: EmotionService {

    private let networkService: NetworkService
    private let jwtKeychainService: JwtKeychainService

    init(
        networkService: NetworkService? = nil,
        jwtKeychainService: JwtKeychainService? = nil
    ) {
        self.networkService = networkService ?? NetworkService(baseURL: URL(string: AppConfiguration.shared.baseURL)!)
        self.jwtKeychainService = jwtKeychainService ?? DefaultJwtKeychainService()
    }

    func readEmotions() -> Observable<[Emotion]> {
        let endpoint = Endpoint<BaseResponse<[Emotion]>>(
            path: "api/diary/emotions",
            method: .get,
            headers: HTTPHeaders(["Authorization": "Bearer \(jwtKeychainService.getJwt() ?? .init())"])
        )

        return networkService.request(endpoint).map { $0.data }
    }

}
