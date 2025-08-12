import SwiftUI

struct DiaryEditor: View {
    @StateObject var viewModel: DiaryEditorVM

    @State private var isHiddenImageSliderGuide = false
    @State private var isBlinkingImageSliderGuide = false

    var body: some View {
        ScrollView {
            HStack {
                ZStack {
                    ImageSlider(
                        imageIndex: $viewModel.emotionIndex,
                        images: viewModel.emojis,
                        imageSize: CGSize(width: 80, height: 80)
                    )
                    .frame(width: 80, height: 80)
                    .onAppear { isBlinkingImageSliderGuide = true }
                    .onChange(of: viewModel.emotionIndex) { _ in isHiddenImageSliderGuide = true }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if !isHiddenImageSliderGuide {
                                Image(systemName: "hand.rays.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .foregroundStyle(.background)
                                    // 깜빡임 애니메이션 추가
                                    .opacity(isBlinkingImageSliderGuide ? 1.0 : 0.3).animation(
                                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                                        value: isBlinkingImageSliderGuide
                                    )
                            }
                        }
                    }
                }
                .background(.ultraThinMaterial)
                .frame(width: 100, height: 100)
                .cornerRadius(16)

                VStack(alignment: .leading) {
                    DatePicker(
                        "날짜",
                        selection: $viewModel.newDiary.occurredAt,
                        in: Date(timeIntervalSince1970: 0)...Date()
                    )
                    .labelsHidden()
                    .environment(\.locale, Locale.current)

                    Spacer()

                    TextField("제목", text: $viewModel.newDiary.title)
                        .padding(.all, 4)
                }
                .padding(.all, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
            }

            ZStack {
                Spacer().background(.ultraThinMaterial)  // 배경 추가
                    .cornerRadius(16)

                TextEditor(text: $viewModel.newDiary.body)
                    .padding()
                    .scrollContentBackground(.hidden)  // 기본 배경 제거
            }
            .frame(height: 300)
            .padding(.vertical, 10)

            HStack {
                Button {
                    viewModel.toMapSearcher()
                } label: {
                    Image(systemName: "map")
                    Text("장소 선택").bold().font(.title3)
                }
                .padding(.all, 8)

                Spacer()

                TextField("장소 이름", text: $viewModel.newDiary.place)
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                    .padding(.all, 8)

                /*
                 장소 이름 변경 시 맵을 리로드
                 맵이 리로드 될 때 다시 장소 텍스트 필드에 이벤트가 전달되지만
                 onChange 시 이전에 캡처된 값을 할당받아 변경 사항이 있을 때 값을 반영
                 */
                if #available(iOS 17.0, *) {
                    ZStack { /* 변경 감지 */  }
                        .onChange(of: viewModel.newDiary.place, initial: false) { _, _ in
                            viewModel.reloadMapViewer()
                        }
                } else {
                    ZStack { /* 변경 감지 */  }
                        .onChange(of: viewModel.newDiary.place) { _ in
                            viewModel.reloadMapViewer()
                        }
                }
            }

            MapViewer(viewModel: viewModel.mapViewerVM)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}

#Preview {
    DiaryEditor(viewModel: DiaryEditorVM())
}
