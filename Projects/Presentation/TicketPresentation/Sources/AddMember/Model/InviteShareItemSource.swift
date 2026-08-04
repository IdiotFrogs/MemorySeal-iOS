import UIKit
import LinkPresentation

final class InviteShareItemSource: NSObject, UIActivityItemSource {
    private let content: InviteShareContent
    private let thumbnail: UIImage?

    init(content: InviteShareContent, thumbnail: UIImage?) {
        self.content = content
        self.thumbnail = thumbnail
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return content.message
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        return content.message
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        return content.title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = content.link
        metadata.url = content.link
        metadata.title = content.title

        if let thumbnail {
            metadata.imageProvider = NSItemProvider(object: thumbnail)
            metadata.iconProvider = NSItemProvider(object: thumbnail)
        }

        return metadata
    }
}
