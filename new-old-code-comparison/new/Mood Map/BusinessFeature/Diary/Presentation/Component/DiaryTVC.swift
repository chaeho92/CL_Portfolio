import UIKit

class DiaryTVC: UITableViewCell {

    let shareIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.and.arrow.up.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let emotion: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let date: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let location: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.addSubview(shareIcon)
        contentView.addSubview(emotion)
        contentView.addSubview(date)
        contentView.addSubview(title)
        contentView.addSubview(location)

        NSLayoutConstraint.activate([
            // shareIcon 좌중단
            shareIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            shareIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            shareIcon.widthAnchor.constraint(equalToConstant: 25),
            shareIcon.heightAnchor.constraint(equalToConstant: 25),

            // emotion 좌상단
            emotion.leadingAnchor.constraint(equalTo: shareIcon.trailingAnchor, constant: 18),
            emotion.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            emotion.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -50),  // 화면 중앙 기준 우에서 좌 거리

            // date 좌하단
            date.leadingAnchor.constraint(equalTo: shareIcon.trailingAnchor, constant: 18),
            date.topAnchor.constraint(equalTo: emotion.bottomAnchor, constant: 9),
            date.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
            date.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -50),  // 화면 중앙 기준 우에서 좌 거리

            // title 우상단
            title.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -50),  // 화면 중앙 기준 좌에서 우 거리
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),

            // location 우하단
            location.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -50),  // 화면 중앙 기준 좌에서 우 거리
            location.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            location.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 9),
            location.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18),
        ])
    }

}
