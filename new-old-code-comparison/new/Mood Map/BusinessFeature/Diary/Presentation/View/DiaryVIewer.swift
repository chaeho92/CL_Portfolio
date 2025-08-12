import MapKit
import SwiftUI

struct DiaryViewer: View {
    @StateObject var viewModel: DiaryViewerVM

    var body: some View {
        ScrollView {
            HStack {
                Image(uiImage: viewModel.emotionIcon)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding()

                VStack(alignment: .leading) {
                    Text(viewModel.diary.title.isEmpty ? "제목 없음" : viewModel.diary.title)
                        .font(.largeTitle)
                        .bold()

                    Text(viewModel.diary.occurredAt.string(format: "yyyy. MM. dd"))
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }

            ScrollView {
                Text(viewModel.diary.body)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 20)
            }
            .frame(height: 300)

            HStack {
                if viewModel.diary.shared {
                    ReactionButton(
                        isReacted: $viewModel.isEmpathized,
                        reactionCount: $viewModel.empathyCount,
                        image: Image(systemName: viewModel.isEmpathized ? "heart.fill" : "heart"),
                        imageColor: viewModel.isEmpathized ? .red : .primary
                    ) {
                        viewModel.reactionTrigger.send()
                    }
                    .padding(.all, 8)
                }

                Spacer()

                Text(viewModel.diary.place)
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                    .padding(.all, 8)
            }

            if #available(iOS 17.0, *) {
                Map(position: .constant(.region(viewModel.region))) {
                    Annotation(
                        viewModel.diary.place,
                        coordinate: viewModel.coordinate
                    ) {
                        ZStack {
                            Image(uiImage: viewModel.placeIcon)
                        }
                    }
                }
                .mapControlVisibility(.hidden)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Map(
                    coordinateRegion: $viewModel.region,
                    annotationItems: [viewModel.diary]
                ) { diary in
                    MapAnnotation(
                        coordinate: viewModel.coordinate
                    ) {
                        Image(uiImage: viewModel.placeIcon)
                            .foregroundColor(.red)
                            .font(.title3)
                        Text(diary.place)
                            .font(.caption)
                            .padding(3)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .onAppear {
            viewModel.reloadDiary()
        }
    }
}

#Preview {
    // Emotion ID를 0으로 목 데이터를 만들면 Index out of range 발생
    let diary = Diary(emotion: Emotion(id: 1, name: "Joy"), title: "화창한 하늘", place: "집 앞", shared: true)

    DiaryViewer(
        viewModel: DiaryViewerVM(
            nil, nil,
            DiaryViewerRequest(
                diary: .init(), backButtonEvent: .init(), forwardButtonEvent: .init()
            ))
    )
}
