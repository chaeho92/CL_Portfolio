import RxSwift

class DefaultDiaryRepository: DiaryRepository {

    let localDiaryService: LocalDiaryService
    let diaryService: DiaryService
    let localEmotionService: LocalEmotionService

    init(
        localDiaryService: LocalDiaryService = DefaultLocalDiaryService(),
        diaryService: DiaryService = DefaultDiaryService(),
        localEmotionService: LocalEmotionService = DefaultLocalEmotionService(),
    ) {
        self.localDiaryService = localDiaryService
        self.diaryService = diaryService
        self.localEmotionService = localEmotionService
    }

}

/*
 Create
 */
extension DefaultDiaryRepository {

    func createDiary(_ diary: Diary) async throws -> Diary {
        let updateDiary = try await diaryService.updateDiary(diary).asyncValue()

        createDiaryObject(diary)

        return updateDiary
    }

    func restoreDiaries(userId: Int) async throws {
        let diaries = try await diaryService.restoreDiaries(userId: userId).asyncValue()

        diaries.forEach { diary in
            createDiaryObject(diary)
        }
    }

    func createDiaryObject(_ diary: Diary) {
        Task {
            let diaryObject = DiaryObject()
            diaryObject.id = diary.id
            diaryObject.userId = diary.user.id
            diaryObject.emotion = localEmotionService.readEmotion(id: diary.emotion.id)
            diaryObject.title = diary.title
            diaryObject.body = diary.body
            diaryObject.views = diary.views
            diaryObject.occurredAt = diary.occurredAt
            diaryObject.createdAt = diary.createdAt
            diaryObject.updatedAt = diary.updatedAt
            diaryObject.latitude = diary.latitude
            diaryObject.longitude = diary.longitude
            diaryObject.place = diary.place
            diaryObject.shared = diary.shared

            localDiaryService.createDiary(diaryObject)
        }
    }

}

/*
 Read
 */
extension DefaultDiaryRepository {

    func readDiary(uuid: String) -> Diary? {
        return localDiaryService.readDiary(uuid: uuid)?.toModel()
    }

    func readDiariesForList(date: Date) -> [Diary] {
        return localDiaryService.readDiariesByDay(date: date)
            .map { $0.toModel() }
    }

    func readDiariesForCalendar(date: Date) -> [Diary] {
        return localDiaryService.readDiariesByDay(date: date)
            .map { $0.toModelOnlyEmotionAndOccurredAt() }
    }

    func readDiariesForStatistics() -> [Diary] {
        return localDiaryService.readAllDiary()
            .map { $0.toModelOnlyEmotionAndOccurredAt() }
    }

    func readSharedDiary(uuid: String) async throws -> Diary {
        return try await diaryService.getDiaryById(uuid).asyncValue()
    }

    func readSharedDiaries(latitude: Double, longitude: Double, range: Double) async throws -> [Diary] {
        return try await diaryService.getDiariesByLocationAndShared(
            latitude: latitude, longitude: longitude, range: range
        ).asyncValue()
    }

}

/*
 Update
 */
extension DefaultDiaryRepository {

    func updateDiary(_ diary: Diary) async throws -> Diary {
        var diary = diary
        diary.updatedAt = Date()

        let updatedDiary = try await diaryService.updateDiary(diary).asyncValue()

        _ = localDiaryService.updateDiary(updatedDiary)

        return updatedDiary
    }

}

/*
 Delete
 */
extension DefaultDiaryRepository {

    func deleteDiary(_ diary: Diary) async throws {
        var diary = diary
        diary.deleted = true

        _ = try await diaryService.updateDiary(diary).asyncValue()

        Task {
            if let diaryObject = localDiaryService.readDiary(uuid: diary.id) {
                localDiaryService.deleteDiaries(diaryObjects: [diaryObject])
            }
        }
    }

    func deleteDiaries() async throws -> Bool {
        let diaryObjects = localDiaryService.readAllDiary()
        guard !diaryObjects.isEmpty else {
            return true
        }

        let updatedDiaries = diaryObjects.map {
            var diary = $0.toModel()
            diary.deleted = true

            return diary
        }.map {
            return diaryService.updateDiary($0).take(1)
        }

        return try await Observable.zip(updatedDiaries).flatMap { _ -> Observable<Bool> in
            return .just(self.deleteLocalDiaries())
        }.asyncValue()
    }

    func deleteLocalDiaries() -> Bool {
        var diaryObjects: [DiaryObject] {
            return localDiaryService.readAllDiary()
        }
        localDiaryService.deleteDiaries(diaryObjects: diaryObjects)

        return diaryObjects.isEmpty
    }

}
