import SwiftUI

struct ReactionButton: View {
    @Binding var isReacted: Bool
    @Binding var reactionCount: Int

    @State private var animate = false

    var image: Image
    var imageColor: Color

    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(
            action: {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.825)) {
                    isReacted.toggle()
                    reactionCount += isReacted ? 1 : -1
                    animate = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animate = false
                }

                onTap?()
            },
            label: {
                HStack {
                    image
                        .foregroundColor(imageColor)
                        .font(.subheadline)
                        .scaleEffect(animate ? 1.5 : 1.0)
                        .animation(.easeOut(duration: 0.2), value: animate)

                    Text("\(reactionCount)")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                }
            }
        )
    }
}
