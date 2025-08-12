import RxSwift

protocol EmotionService {
    func readEmotions() -> Observable<[Emotion]>
}
