//
// Copyright (c) 2018 Muukii <muukii.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if !COCOAPODS
import BrightroomEngine
#endif
import UIKit
import Verge

/**
 A view that displays the edited image, plus displays original image for comparison with touch-down interaction.
 */
public final class ImagePreviewView: PixelEditorCodeBasedView {
  // MARK: - Properties

  #if false
  private let imageView = _ImageView()
  private let originalImageView = _ImageView()
  #else
  private let imageView = MetalImageView()
  private let originalImageView = MetalImageView()
  #endif

  private let editingStack: EditingStack
  private var subscriptions = Set<VergeAnyCancellable>()

  private var loadingOverlayFactory: (() -> UIView)?
  private weak var currentLoadingOverlay: UIView?

  private var isBinding = false

  // MARK: - Initializers

  public init(editingStack: EditingStack) {
    // FIXME: Loading State

    self.editingStack = editingStack

    super.init(frame: .zero)

    originalImageView.accessibilityIdentifier = "pixel.originalImageView"

    imageView.accessibilityIdentifier = "pixel.editedImageView"

    clipsToBounds = true

    [
      originalImageView,
      imageView,
    ].forEach { imageView in
      addSubview(imageView)
      imageView.clipsToBounds = true
      imageView.contentMode = .scaleAspectFit
      imageView.isOpaque = false
      imageView.frame = bounds
      imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    originalImageView.isHidden = true

    defaultAppearance: do {
      setLoadingOverlay(factory: {
        LoadingBlurryOverlayView(
          effect: UIBlurEffect(style: .dark),
          activityIndicatorStyle: .whiteLarge
        )
      })
    }
  }

  // MARK: - Functions

  public func setLoadingOverlay(factory: (() -> UIView)?) {
    _pixeleditor_ensureMainThread()
    loadingOverlayFactory = factory
  }

  override public func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)

    if newWindow != nil {
      editingStack.start()

      if isBinding == false {
        isBinding = true
        editingStack.sinkState { [weak self] state in

          guard let self = self else { return }

          state.ifChanged(\.isLoading) { isLoading in
            self.updateLoadingOverlay(displays: isLoading)
          }

          UIView.performWithoutAnimation {
            if let state = state._beta_map(\.loadedState) {
              state.ifChanged(\.editingCroppedPreviewImage) { image in
                self.imageView.display(image: image)
                EditorLog.debug("ImagePreviewView.image set", image.extent as Any)
              }

              state.ifChanged(\.editingCroppedImage) { image in
                self.originalImageView.display(image: image)
                EditorLog.debug("ImagePreviewView.originalImage set", image.extent as Any)
              }
            }
          }
        }
        .store(in: &subscriptions)
      }
    }
  }

  private func updateLoadingOverlay(displays: Bool) {
    if displays, let factory = loadingOverlayFactory {
      let loadingOverlay = factory()
      currentLoadingOverlay = loadingOverlay
      addSubview(loadingOverlay)
      AutoLayoutTools.setEdge(loadingOverlay, self)

      loadingOverlay.alpha = 0
      UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
        loadingOverlay.alpha = 1
      }
      .startAnimation()

    } else {
      if let view = currentLoadingOverlay {
        UIViewPropertyAnimator(duration: 0.6, dampingRatio: 1) {
          view.alpha = 0
        }&>.do {
          $0.addCompletion { _ in
            view.removeFromSuperview()
          }
          $0.startAnimation()
        }
      }
    }
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    originalImageView.isHidden = false
    imageView.isHidden = true
  }

  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    originalImageView.isHidden = true
    imageView.isHidden = false
  }

  override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    originalImageView.isHidden = true
    imageView.isHidden = false
  }
}