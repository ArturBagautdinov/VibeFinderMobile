import UIKit

protocol RemoteImageLoading: AnyObject {
    func loadImage(
        from url: URL?,
        completion: @escaping (UIImage?) -> Void
    ) -> URLSessionDataTask?
}

final class RemoteImageLoader: RemoteImageLoading {
    func loadImage(
        from url: URL?,
        completion: @escaping (UIImage?) -> Void
    ) -> URLSessionDataTask? {
        guard let url else {
            completion(nil)
            return nil
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            let image = data.flatMap(UIImage.init(data:))
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
        return task
    }
}
