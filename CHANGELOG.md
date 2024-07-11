# Changelog

## [1.2.0](https://github.com/Isrothy/neominimap.nvim/compare/v1.1.1...v1.2.0) (2024-07-11)


### Features

* Add treesitter support ([ad0a740](https://github.com/Isrothy/neominimap.nvim/commit/ad0a740df20d1a40349097f2e2001be2a41113d4))

### Bug Fixed

* Correct indexing for Treesitter highlights in minimap ([0d1fdea](https://github.com/Isrothy/neominimap.nvim/commit/0d1fdea1ee8491a305ed4a8a212e982c23fcf14f))
* Fix Treesitter highlight index-out-of-bound in minimap ([5328153](https://github.com/Isrothy/neominimap.nvim/commit/5328153bfa5b9e1af9186d76f947c4da6227a458))
* Fix Another Treesitter highlight index-out-of-bound in minimap ([6fec961](https://github.com/Isrothy/neominimap.nvim/commit/6fec961dac3005c37886577c99369d430b363a8e))

## [1.1.1](https://github.com/Isrothy/neominimap.nvim/compare/v1.1.0...v1.1.1) (2024-07-11)


### Bug Fixes

* Fixed floor division in coordinate transformation ([404903b](https://github.com/Isrothy/neominimap.nvim/commit/404903b0be8fe1249a95aa55a0e270603e8a0063))
* Corrected wrong cursor column in minimap ([8a1dc0b](https://github.com/Isrothy/neominimap.nvim/commit/8a1dc0b00523a2e78334faaf37adefe00e5e4d56))

## [1.1.0](https://github.com/Isrothy/neominimap.nvim/compare/v1.0.0...v1.1.0) (2024-07-06)


### Features

* Add diagnostic support ([150bf76](https://github.com/Isrothy/neominimap.nvim/commit/150bf76b5e6c5f42adc287ef90ac289f09a1fdea))


### Bug Fixes

* correct window width ([cf3663d](https://github.com/Isrothy/neominimap.nvim/commit/cf3663df76756c0245e10eb4959fc21c06be2aaf))

## 1.0.0 (2024-07-04)

The first stable release of `neominimap.nvim`

### Features:

- **Code Minimap**: Displays a miniature version of your code on the right side of the windows.
- **Commands**:
  - `:NeominimapOpel`: Enable the minimap.
  - `:NeominimapClose`: Disable the minimap.
  - `:NeominimapToggle`: Toggle the minimap on or off.
 
### Known Issues
- Performance issues may occur with very large files.
