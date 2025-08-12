import Foundation

class DiaryUseCase {

    let diaryRepository: DiaryRepository
    let user: User

    init(
        diaryRepository: DiaryRepository = DefaultDiaryRepository(),
        userRepository: UserRepository = DefaultUserRepository()
    ) {
        self.diaryRepository = diaryRepository
        self.user = userRepository.fetchUserSession()?.user ?? .init()
    }

}

/*
 Create
 */
extension DiaryUseCase {

    func createDiary(_ diary: Diary) async throws -> Diary {
        return try await diaryRepository.createDiary(diary)
    }

    func restoreDiaries() async throws {
        return try await diaryRepository.restoreDiaries(userId: user.id)
    }

}

/*
 Read
 */
extension DiaryUseCase {

    func readDiary(uuid: String) -> Diary? {
        let diary = diaryRepository.readDiary(uuid: uuid)

        return user.id == diary?.user.id ? diary : nil
    }

    func readDiariesForList(date: Date) -> [Diary] {
        return diaryRepository.readDiariesForList(date: date)
            .filter { $0.user.id == user.id }
    }

    func readDiariesForCalendar(date: Date) -> [Diary] {
        return diaryRepository.readDiariesForCalendar(date: date)
            .filter { $0.user.id == user.id }
    }

    func readDiariesForStatistics() -> [Diary] {
        return diaryRepository.readDiariesForStatistics()
            .filter { $0.user.id == user.id }
    }

    func readSharedDiary(uuid: String) async throws -> Diary {
        return try await diaryRepository.readSharedDiary(uuid: uuid)
    }

    func readSharedDiaries(latitude: Double, longitude: Double, range: Double) async throws -> [Diary] {
        return try await diaryRepository.readSharedDiaries(latitude: latitude, longitude: longitude, range: range)
    }

}

/*
 Update
 */
extension DiaryUseCase {

    func updateDiary(_ diary: Diary) async throws -> Diary {
        var diary = diary
        diary.updatedAt = Date()

        return try await diaryRepository.updateDiary(diary)
    }

}

/*
 Delete
 */
extension DiaryUseCase {

    func deleteDiary(_ diary: Diary) async throws {
        try await diaryRepository.deleteDiary(diary)
    }

    func deleteDiaries() async throws -> Bool {
        return try await diaryRepository.deleteDiaries()
    }

    func deleteLocalDiaries() -> Bool {
        return diaryRepository.deleteLocalDiaries()
    }

}
