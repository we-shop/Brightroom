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

import Foundation

import PixelEngine
import Verge

open class VignetteControlBase : FilterControlBase {
  
  public required init(viewModel: PixelEditViewModel) {
    super.init(viewModel: viewModel)
  }
}

open class VignetteControl : VignetteControlBase {
  
  open override var title: String {
    return L10n.editVignette
  }
  
  private let navigationView = NavigationView()
  
  public let slider = StepSlider(frame: .zero)
  
  open override func setup() {
    super.setup()
    
    backgroundColor = Style.default.control.backgroundColor
    
    TempCode.layout(navigationView: navigationView, slider: slider, in: self)
    
    slider.mode = .plus
    slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    
    navigationView.didTapCancelButton = { [weak self] in
      
      guard let self = self else { return }
      
      self.viewModel.editingStack.revertEdit()
      self.pop(animated: true)
    }
    
    navigationView.didTapDoneButton = { [weak self] in
      
      guard let self = self else { return }
      
      self.viewModel.editingStack.takeSnapshot()
      self.pop(animated: true)
    }
  }
  
  open override func didReceiveCurrentEdit(state: Changes<PixelEditViewModel.State>) {
    
    if let vignette = state.takeIfChanged(\.editingState.currentEdit.filters.vignette) {
      slider.set(value: vignette?.value ?? 0, in: FilterVignette.range)
    }
               
  }
  
  @objc
  private func valueChanged() {
    
    let value = slider.transition(in: FilterVignette.range)
    
    guard value != 0 else {
      viewModel.editingStack.set(filters: { $0.vignette = nil })
      return
    }
       
    viewModel.editingStack.set(
      filters: {
        var f = FilterVignette()
        f.value = value
        $0.vignette = f
    })

  }
  
}