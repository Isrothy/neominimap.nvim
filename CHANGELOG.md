# Changelog

## [3.15.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.15.1...v3.15.2) (2025-09-17)


### Bug Fixes

* Safely warp set_current_line_by_percentage ([9a40328](https://github.com/Isrothy/neominimap.nvim/commit/9a40328226f01842770f09e1cb48bc092e006a38))

## [3.15.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.15.0...v3.15.1) (2025-08-18)


### Bug Fixes

* neominimap boundary line issue ([0d7d546](https://github.com/Isrothy/neominimap.nvim/commit/0d7d54696de301808fc92dc94d33dce047b4525b))
* neominimap boundary line issue ([42e9e73](https://github.com/Isrothy/neominimap.nvim/commit/42e9e738827083a1052b18f6c026234a9eea774f))

## [3.15.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.14.4...v3.15.0) (2025-08-18)


### Features

* add percent-based current-line positioning ([b2e0d0c](https://github.com/Isrothy/neominimap.nvim/commit/b2e0d0ccbaa00831c11356cddf0e6338031f1b9c))

## [3.14.4](https://github.com/Isrothy/neominimap.nvim/compare/v3.14.3...v3.14.4) (2025-06-24)


### Bug Fixes

* Breaking changes in treesitter api ([021b45d](https://github.com/Isrothy/neominimap.nvim/commit/021b45de94934efd4e4671927e553385e3ebdaef))
* Breaking changes in treesitter api ([4314fc1](https://github.com/Isrothy/neominimap.nvim/commit/4314fc1075282e05f5a7c371a528c49ced67da4c))
* NPE in line index ([42b8b63](https://github.com/Isrothy/neominimap.nvim/commit/42b8b63838b016db87c60192dd3a5610603fc292))

## [3.14.3](https://github.com/Isrothy/neominimap.nvim/compare/v3.14.2...v3.14.3) (2025-06-24)


### Bug Fixes

* Only show diagnostic from one source ([3d54bb6](https://github.com/Isrothy/neominimap.nvim/commit/3d54bb6d61d71db2d29ec75f77f8e774fe7f32c7))
* Only show diagnostic from one source ([ee8978b](https://github.com/Isrothy/neominimap.nvim/commit/ee8978bc9abd8e5334941312590c0651c99fd624))

## [3.14.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.14.1...v3.14.2) (2025-05-25)


### Bug Fixes

* ts_util not available on main branch of treesitter ([8eafa33](https://github.com/Isrothy/neominimap.nvim/commit/8eafa334a91125fb3b72e33a7e675962fa6c4047))
* ts_util not available on main branch of treesitter ([c7a797f](https://github.com/Isrothy/neominimap.nvim/commit/c7a797fbe2d5e099f421bce79fa7172cb8db15ba))

## [3.14.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.14.0...v3.14.1) (2025-05-01)


### Bug Fixes

* **treesitter:** Clear highlight cache when colorscheme changes ([0c0c096](https://github.com/Isrothy/neominimap.nvim/commit/0c0c096a13d0f9352cae749cdc8496292c2b560d))

## [3.14.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.13.0...v3.14.0) (2025-04-29)


### Features

* New command to keep consistent with vim command style; Deprecate old command ([f86ceaf](https://github.com/Isrothy/neominimap.nvim/commit/f86ceaf1a2d6f9da1180cf0f6da4bd2d2f43339d))
* New lua api ([168a6d8](https://github.com/Isrothy/neominimap.nvim/commit/168a6d8176ae541d6de402bc71f83afef34728f2))


### Bug Fixes

* Capability for older neovim version ([9de43e4](https://github.com/Isrothy/neominimap.nvim/commit/9de43e4c118066257db7a52e3aa32aadabaed666))
* Correct is_minimap_buffer function with function call instead of table look up ([1d4a8f7](https://github.com/Isrothy/neominimap.nvim/commit/1d4a8f79fd3cd9c040b99322bedd4b8eb2856b07))
* Get buffer safely in git plugins ([4e602c4](https://github.com/Isrothy/neominimap.nvim/commit/4e602c49f7f29bb4300f0b23c4ecf9edfa994400))
* Safe set diagnostic info ([766932f](https://github.com/Isrothy/neominimap.nvim/commit/766932f686923f828d347d73a6e2d6fa6ef5386f))

## [3.13.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.12.2...v3.13.0) (2025-04-29)


### Features

* Better handler api ([41c6108](https://github.com/Isrothy/neominimap.nvim/commit/41c61081e48381e781c369fcd9c4283e7f6b3415))


### Bug Fixes

* Use pcall to safely load external dependencies ([2be105c](https://github.com/Isrothy/neominimap.nvim/commit/2be105c74d0a2576de49a70eddff5a32cf6f0ede))
* Use pcall to safely load external dependencies ([632ebf0](https://github.com/Isrothy/neominimap.nvim/commit/632ebf0bc5f07ecc54ce02b52f70733892f20f2a))

## [3.12.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.12.1...v3.12.2) (2025-04-26)


### Bug Fixes

* notification level should be info ([c9d5377](https://github.com/Isrothy/neominimap.nvim/commit/c9d53773cb0ae8be92f8016db9ccd39cf5a1a0fc))

## [3.12.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.12.0...v3.12.1) (2025-04-26)


### Performance Improvements

* Better log ([851ec1b](https://github.com/Isrothy/neominimap.nvim/commit/851ec1bfef29240d6d1b29044249ff207da3ea03))
* Better log ([e56ae38](https://github.com/Isrothy/neominimap.nvim/commit/e56ae3804a1bebacc0fe91031455dd87b37f8779))

## [3.12.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.11.1...v3.12.0) (2025-04-25)


### Features

* Add persist options to both float and split layout ([16fe4b0](https://github.com/Isrothy/neominimap.nvim/commit/16fe4b0988b8a6308e77b430dda20faf7f385f33))
* Add persist options to buffer ([f831a6f](https://github.com/Isrothy/neominimap.nvim/commit/f831a6f21f36154fb99e82cc9c5f2c4fdc174766))

## [3.11.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.11.0...v3.11.1) (2025-04-10)


### Bug Fixes

* Use correct group for user events ([90da838](https://github.com/Isrothy/neominimap.nvim/commit/90da838c631882a3080bd267e45b0eadd6d61dee))
* Use correct group for user events ([8bacc1b](https://github.com/Isrothy/neominimap.nvim/commit/8bacc1bd3d1b2090071b4759ef9c2c99a1c8e303))

## [3.11.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.10.0...v3.11.0) (2025-04-08)


### Features

* Apply async tree parsing for neovim 0.11 ([abffb9f](https://github.com/Isrothy/neominimap.nvim/commit/abffb9f68e17d686d3a1314294e0fea203cf5362))
* Implment api for the status of minimap ([dc83e0d](https://github.com/Isrothy/neominimap.nvim/commit/dc83e0d388c111187f2b3d4a07aedab65729be89))
* Support mini-diff ([5e984da](https://github.com/Isrothy/neominimap.nvim/commit/5e984da911c73ce7482ffe2287aeeb4c827faa28))
* Support mini-diff ([f3cb8bf](https://github.com/Isrothy/neominimap.nvim/commit/f3cb8bff7a731883942e6b2e593d1c81c4707cbc))

## [3.10.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.9.4...v3.10.0) (2025-03-20)


### Features

* Support split layout for botright, rightbelow, topleft and aboveleft ([f2bd8f3](https://github.com/Isrothy/neominimap.nvim/commit/f2bd8f3827a659dcc89aeefe7b9ed60093314e06))


### Bug Fixes

* Buffer refresh do not affact cursor position ([503d8f7](https://github.com/Isrothy/neominimap.nvim/commit/503d8f72d41b6cd8a08fb5b6f5c7b3868844e369))

## [3.9.4](https://github.com/Isrothy/neominimap.nvim/compare/v3.9.3...v3.9.4) (2025-03-02)


### Bug Fixes

* Buffer refresh do not affact cursor position ([4d3ba82](https://github.com/Isrothy/neominimap.nvim/commit/4d3ba8244eac49ca41708d752ebb93534f1e76aa))

## [3.9.3](https://github.com/Isrothy/neominimap.nvim/compare/v3.9.2...v3.9.3) (2025-03-02)


### Reverts

* "Merge pull request [#212](https://github.com/Isrothy/neominimap.nvim/issues/212) from 0xFishbyte/fix-buffer-jump" ([09de58b](https://github.com/Isrothy/neominimap.nvim/commit/09de58bc6b62abfe7c679093139b6e669003508c))

## [3.9.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.9.1...v3.9.2) (2025-02-27)


### Bug Fixes

* minimap jump to the end of buffer on source buffer change ([62ddce5](https://github.com/Isrothy/neominimap.nvim/commit/62ddce5bc8483088b86b4a972b837c9fe8fa7bdc))

## [3.9.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.9.0...v3.9.1) (2024-12-26)


### Bug Fixes

* Highlight of injected languages should have higher priority ([3c8d9d8](https://github.com/Isrothy/neominimap.nvim/commit/3c8d9d8790fc4b1f9e64e378d23c8d813cbaf63a))

## [3.9.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.8.4...v3.9.0) (2024-12-11)


### Features

* Add tab filter ([898614d](https://github.com/Isrothy/neominimap.nvim/commit/898614d24d1160195645ee36d778f79540914b36))

## [3.8.4](https://github.com/Isrothy/neominimap.nvim/compare/v3.8.3...v3.8.4) (2024-12-08)


### Bug Fixes

* Display minimap on start screen when layout is split ([691a251](https://github.com/Isrothy/neominimap.nvim/commit/691a251130782640251944d7971826799b87c7ba))
* Quit when only floating windows exist ([11ec72a](https://github.com/Isrothy/neominimap.nvim/commit/11ec72a1bd56694eda41c94f21220e8db89c2e14))
* Scrolloff overwritten when buffer is set ([dc576af](https://github.com/Isrothy/neominimap.nvim/commit/dc576afed82d7f2bd9e961dbfee36a1bc29df195))
* Type check ([d8913b4](https://github.com/Isrothy/neominimap.nvim/commit/d8913b412ecc9bc91c31ed2997395eecea652d8e))

## [3.8.3](https://github.com/Isrothy/neominimap.nvim/compare/v3.8.2...v3.8.3) (2024-12-01)


### Bug Fixes

* Minimap not showing up for start page ([6102528](https://github.com/Isrothy/neominimap.nvim/commit/6102528eb54598a86de6c934447de03af1ab56b9))

## [3.8.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.8.1...v3.8.2) (2024-12-01)


### Performance Improvements

* Use cooperative scheduling to make it non-blocking ([98ad591](https://github.com/Isrothy/neominimap.nvim/commit/98ad591ec10a424ecfcef061a2cb083eb6e71a27))

## [3.8.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.8.0...v3.8.1) (2024-11-24)


### Bug Fixes

* **search:** respect "search" in "foldopen" ([d283dd7](https://github.com/Isrothy/neominimap.nvim/commit/d283dd73d67cab8f2a4526e5b5b8fea06daba35f))

## [3.8.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.6...v3.8.0) (2024-11-22)


### Features

* Ignore bigfile when snacks.bigfile is enabled ([cf240d0](https://github.com/Isrothy/neominimap.nvim/commit/cf240d03514c6100ed8c1d3b4d2a698a207bc978))

## [3.7.6](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.5...v3.7.6) (2024-11-07)


### Bug Fixes

* fix-178 ([e490be9](https://github.com/Isrothy/neominimap.nvim/commit/e490be90776cede01868634142f4eab1b0ba32c8))

## [3.7.5](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.4...v3.7.5) (2024-11-01)


### Performance Improvements

* Lazy create autocmds for split window ([bf5107f](https://github.com/Isrothy/neominimap.nvim/commit/bf5107f393f1d8ed943161753ab326da58117608))

## [3.7.4](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.3...v3.7.4) (2024-11-01)


### Performance Improvements

* Lazy load commands ([4d3e56a](https://github.com/Isrothy/neominimap.nvim/commit/4d3e56a1691478a2418bcc8d0cb9c64c99433861))
* Validate configuration in checkhealth ([9b21120](https://github.com/Isrothy/neominimap.nvim/commit/9b21120fae860f1ec22ae9ea347dd4a9a0db66ba))

## [3.7.3](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.2...v3.7.3) (2024-10-05)


### Bug Fixes

* Add permissions to workflow ([29d52ce](https://github.com/Isrothy/neominimap.nvim/commit/29d52ce9e0d6a650b1e89db605fc4be1b88d2f50))
* Use pcall in noautocmd ([1ebe37f](https://github.com/Isrothy/neominimap.nvim/commit/1ebe37f754bdd0df6589b86a251cc27008cda21e))
* Use secrets.GITHUB_TOKEN ([233d05f](https://github.com/Isrothy/neominimap.nvim/commit/233d05f4c0663805c1dcf7afa006f176e0a46d55))

## [3.7.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.1...v3.7.2) (2024-09-18)


### Bug Fixes

* Disable winbar for lualine ([c3f3fd2](https://github.com/Isrothy/neominimap.nvim/commit/c3f3fd2abe33e447c35e9857319f7f0afcfa6754))

## [3.7.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.7.0...v3.7.1) (2024-09-17)


### Performance Improvements

* Do not load unnucessary window handler ([e6043ea](https://github.com/Isrothy/neominimap.nvim/commit/e6043eae48b32e18094aba67265f15ae2059891f))

## [3.7.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.6.0...v3.7.0) (2024-09-17)


### Features

* Introduce lualine component ([24d3d7e](https://github.com/Isrothy/neominimap.nvim/commit/24d3d7e389d3d354d9959925de353de1fb44d2de))

## [3.6.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.5.5...v3.6.0) (2024-09-01)


### Features

* Add customized handler API ([d625b2c](https://github.com/Isrothy/neominimap.nvim/commit/d625b2c3f641b8eb963544e572576c8eaeb99259))

## [3.5.5](https://github.com/Isrothy/neominimap.nvim/compare/v3.5.4...v3.5.5) (2024-09-01)


### Bug Fixes

* Incorrect highlights ([10a033e](https://github.com/Isrothy/neominimap.nvim/commit/10a033e5e2c33bb562748c1b0fa435f6fe954399))

## [3.5.4](https://github.com/Isrothy/neominimap.nvim/compare/v3.5.3...v3.5.4) (2024-08-31)


### Bug Fixes

* Correct module name ([5e8cc1f](https://github.com/Isrothy/neominimap.nvim/commit/5e8cc1faeeddc92c67fd7cc008a1b522e859c6fd))

## [3.5.3](https://github.com/Isrothy/neominimap.nvim/compare/v3.5.2...v3.5.3) (2024-08-30)


### Bug Fixes

* typo ([b97048e](https://github.com/Isrothy/neominimap.nvim/commit/b97048ed09e4286dd4ca2ed8f02cf78c910ccc3b))

## [3.5.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.5.1...v3.5.2) (2024-08-29)


### Bug Fixes

* Do no trigger autocmd when setting win/buf opt ([8e8f498](https://github.com/Isrothy/neominimap.nvim/commit/8e8f498407ba1f75aa8b0db764bdcd9f8d2b797f))

## [3.5.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.5.0...v3.5.1) (2024-08-26)


### Bug Fixes

* Incorrect mark lineNr ([3a23307](https://github.com/Isrothy/neominimap.nvim/commit/3a23307d0bd1519cd5ac95e60630b970e7af186f))

## [3.5.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.4.1...v3.5.0) (2024-08-26)


### Features

* Implement mark handler ([e24b1f5](https://github.com/Isrothy/neominimap.nvim/commit/e24b1f50238e696b21838809adaf7ed2f0c272fb))
* More highlights in cursorline ([0f4836a](https://github.com/Isrothy/neominimap.nvim/commit/0f4836a5ebb9d9a0ba7fc5da8bee8bad539edc9a))

## [3.4.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.4.0...v3.4.1) (2024-08-24)


### Bug Fixes

* Correct lua API ([fb8a84c](https://github.com/Isrothy/neominimap.nvim/commit/fb8a84cebffe4f6e667812c37101f78711274e6d))

## [3.4.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.3.3...v3.4.0) (2024-08-23)


### Features

* New Annotation mode: icons ([ad5eba7](https://github.com/Isrothy/neominimap.nvim/commit/ad5eba759572e53999f8bf6129e5a4793312991a))

## [3.3.3](https://github.com/Isrothy/neominimap.nvim/compare/v3.3.2...v3.3.3) (2024-08-23)


### Bug Fixes

* Handle cases when annotation range starting or ending are hidden in folds ([9d59016](https://github.com/Isrothy/neominimap.nvim/commit/9d59016c99e6ebcac16ddf58f145ae0fd0ee6473))

## [3.3.2](https://github.com/Isrothy/neominimap.nvim/compare/v3.3.1...v3.3.2) (2024-08-23)


### Bug Fixes

*  Correct row of annotations when foldings exist ([565f0c6](https://github.com/Isrothy/neominimap.nvim/commit/565f0c696a0f559b057775b04b4375d75418733c))

## [3.3.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.3.0...v3.3.1) (2024-08-23)


### Bug Fixes

* Set cursor line safely ([4a2b09d](https://github.com/Isrothy/neominimap.nvim/commit/4a2b09d4cf62e10b59d077eec2e4a11be95b71c0))

## [3.3.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.2.0...v3.3.0) (2024-08-22)


### Features

* Allow to fix minimap width ([ff71476](https://github.com/Isrothy/neominimap.nvim/commit/ff71476f1c954b0e7379e12dc7e1aac3ed130f9f))

## [3.2.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.1.0...v3.2.0) (2024-08-22)


### Features

* Add option to close if minimap is the last window ([37107fe](https://github.com/Isrothy/neominimap.nvim/commit/37107fedc51611edcdf6fe41e9a1adff0534be85))


### Bug Fixes

* Update cursor line when minimap text changed ([af8d138](https://github.com/Isrothy/neominimap.nvim/commit/af8d13891319b55e2b8b8ee30be6124244835a9c))
* Validate config.split.close_if_last_window ([4f33e39](https://github.com/Isrothy/neominimap.nvim/commit/4f33e39c172028e76954f98ac42a3ae983d2fc25))

## [3.1.0](https://github.com/Isrothy/neominimap.nvim/compare/v3.0.1...v3.1.0) (2024-08-22)


### Features

* Support split direction ([f27f3f5](https://github.com/Isrothy/neominimap.nvim/commit/f27f3f5cd87e3e78bb93f41c2c7097976a1c091d))

## [3.0.1](https://github.com/Isrothy/neominimap.nvim/compare/v3.0.0...v3.0.1) (2024-08-22)


### Bug Fixes

* Errors when windows or buffers are nil or not valid ([695c3b4](https://github.com/Isrothy/neominimap.nvim/commit/695c3b42b2066587d087cb9430f120f7ce529188))
* Set buffer unmodifiable ([775667d](https://github.com/Isrothy/neominimap.nvim/commit/775667d4a5b6c8c50709c91ed2c5ecdb26f5e5dd))
* Set parent to nil when appropriate ([be81003](https://github.com/Isrothy/neominimap.nvim/commit/be81003ab8b1784de6960db475a74158493e41c9))

## [3.0.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.12.3...v3.0.0) (2024-08-21)


### ⚠ BREAKING CHANGES

* Change winopt and bufopt configuration
* Change layout configuration
* Remove statuscolumn in default winopt

### Features

* Add tab commands ([f0c4e43](https://github.com/Isrothy/neominimap.nvim/commit/f0c4e43db70b0950fbf46fee5964cb0a0db7066a))
* Introduce split layout ([6dcb593](https://github.com/Isrothy/neominimap.nvim/commit/6dcb5939c81d93a9de8f13a75845a55295db09e4))

## [2.12.3](https://github.com/Isrothy/neominimap.nvim/compare/v2.12.2...v2.12.3) (2024-08-19)


### Bug Fixes

* make eob character unseen in neominimap ([f3e9c52](https://github.com/Isrothy/neominimap.nvim/commit/f3e9c52bd6844efdd76f475e8cfd08e02ac18095))

## [2.12.2](https://github.com/Isrothy/neominimap.nvim/compare/v2.12.1...v2.12.2) (2024-08-17)


### Bug Fixes

* Handle cases when str is binary ([79a7d6b](https://github.com/Isrothy/neominimap.nvim/commit/79a7d6bafb6da25015bd66c2cfa193e8561e493e))
* Incorrect function name ([07bea09](https://github.com/Isrothy/neominimap.nvim/commit/07bea09c63974e2f49c0f629a0e029544d7fa0b5))

## [2.12.1](https://github.com/Isrothy/neominimap.nvim/compare/v2.12.0...v2.12.1) (2024-08-17)


### Bug Fixes

* do not show eol characters ([85b2b5d](https://github.com/Isrothy/neominimap.nvim/commit/85b2b5d2b2321282d7daf33c02c633758c9f4439))

## [2.12.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.11.0...v2.12.0) (2024-08-16)


### Features

* Support mouse click ([f86bb95](https://github.com/Isrothy/neominimap.nvim/commit/f86bb95dc6f897e8e1382537c8681343cec85946))

## [2.11.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.10.0...v2.11.0) (2024-08-16)


### Features

* Set neominimap filetype ([309deb2](https://github.com/Isrothy/neominimap.nvim/commit/309deb2842158edc68c30671b291627cf7875cd4))

## [2.10.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.9.0...v2.10.0) (2024-08-16)


### Features

* Autocmds to trigger search update ([93fc883](https://github.com/Isrothy/neominimap.nvim/commit/93fc883c14c8f6384a4fa054b64ff1397d170a33))
* Autocmds to trigger search update ([694447a](https://github.com/Isrothy/neominimap.nvim/commit/694447a5bac5ac3307121c5b9ee92e3d24439916))
* Incorrect line number for gitsigns ([1a73bdc](https://github.com/Isrothy/neominimap.nvim/commit/1a73bdc2732b6577db554becf23f5995fc7cc784))
* Introduce search marks ([aa99135](https://github.com/Isrothy/neominimap.nvim/commit/aa9913515e9ce2a38b786045b8a93c929d7842f2))


### Bug Fixes

* Handle cases when hl.fg is nil ([c931780](https://github.com/Isrothy/neominimap.nvim/commit/c931780391fbc7da6019db7ef0bcd38b1d9507ca))

## [2.9.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.8.3...v2.9.0) (2024-08-14)


### Features

* Introduce checkhealth ([9f2b354](https://github.com/Isrothy/neominimap.nvim/commit/9f2b354456962f7c7d7815927facde3522b17148))

## [2.8.3](https://github.com/Isrothy/neominimap.nvim/compare/v2.8.2...v2.8.3) (2024-08-14)


### Bug Fixes

* Handle cases when bufnr may be null ([a35a9d3](https://github.com/Isrothy/neominimap.nvim/commit/a35a9d3566e315dc9854e0a9e55e84931a7be0b1))

## [2.8.2](https://github.com/Isrothy/neominimap.nvim/compare/v2.8.1...v2.8.2) (2024-08-14)


### Bug Fixes

* Handle cases when hunks are null ([80033b3](https://github.com/Isrothy/neominimap.nvim/commit/80033b31ed1523ad2683032d9f7c8e295a50efa5))

## [2.8.1](https://github.com/Isrothy/neominimap.nvim/compare/v2.8.0...v2.8.1) (2024-08-13)


### Bug Fixes

* Handle case where args.data.buffer may be null ([2ad19b6](https://github.com/Isrothy/neominimap.nvim/commit/2ad19b6dbd87c1a776b70edd5ae93526dc3c0a70))
* Respect config.git.enabled ([80879bd](https://github.com/Isrothy/neominimap.nvim/commit/80879bd115512f0c7de2d661302efe5982d1ec0c))

## [2.8.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.7.2...v2.8.0) (2024-08-13)


### Features

* Draw signcolumn when this is sign to display ([407f62a](https://github.com/Isrothy/neominimap.nvim/commit/407f62a3b66c3377d1041c89ab31f3affd28ea00))
* Support gitsigns ([a348b2c](https://github.com/Isrothy/neominimap.nvim/commit/a348b2c8c2327e94811c719839db2f26d3e31f66))
* Support signcolumn ([3924f18](https://github.com/Isrothy/neominimap.nvim/commit/3924f18a65729fab6cc46c2a1e9d61716d6ce38b))


### Bug Fixes

* Respect  setting ([256c609](https://github.com/Isrothy/neominimap.nvim/commit/256c609def794098be686a6d896b8feaa404a2c3))

## [2.7.2](https://github.com/Isrothy/neominimap.nvim/compare/v2.7.1...v2.7.2) (2024-08-11)


### Bug Fixes

* Validate sync_cursor ([d905c76](https://github.com/Isrothy/neominimap.nvim/commit/d905c7659934c5b0b6ac0a45166f0a819f458af2))

## [2.7.1](https://github.com/Isrothy/neominimap.nvim/compare/v2.7.0...v2.7.1) (2024-08-11)


### Bug Fixes

* Do not show minimap when the window is too small ([7427624](https://github.com/Isrothy/neominimap.nvim/commit/74276249ddc5e2ed7a13a734b8919909a4a84f32))
* Handle cases when borders has highlight groups ([54ea78a](https://github.com/Isrothy/neominimap.nvim/commit/54ea78a236bb31913e8a259e228470d6055b2e91))
* Handle cases where 'border' length is less than 8 ([98ce237](https://github.com/Isrothy/neominimap.nvim/commit/98ce237f3fbf6e928cbdf7d69f8680b7555df000))
* Incorrect win height when border==shadow ([3d63539](https://github.com/Isrothy/neominimap.nvim/commit/3d63539dcb65ac76fd52dbf06ac2ef2bc278a75d))

## [2.7.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.6.0...v2.7.0) (2024-08-09)


### Features

* Add toggleFocus command ([65d8ae2](https://github.com/Isrothy/neominimap.nvim/commit/65d8ae2976cfebb7899e6abcd140ff703b28c58d))
* Support folds ([74e81c7](https://github.com/Isrothy/neominimap.nvim/commit/74e81c78014b4e86d5961e01596231194480a62d))


### Bug Fixes

* Inconsistency of current line when folds on ([08ea1c8](https://github.com/Isrothy/neominimap.nvim/commit/08ea1c8d760d576be5a7ded35716f6b558ab9e10))

## [2.6.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.5.0...v2.6.0) (2024-08-07)


### Features

* Add configuration option to enable/disable cursor line sync ([4267c24](https://github.com/Isrothy/neominimap.nvim/commit/4267c241803724f66d6c8360ffe247e65e2763cd))
* Add focus feature for minimap ([59bde8b](https://github.com/Isrothy/neominimap.nvim/commit/59bde8b702a69d387cad83640e38c9a1e2df0d34))
* Sync cursor line between windows and minimap ([db49cca](https://github.com/Isrothy/neominimap.nvim/commit/db49cca37eecee7c0cd78b7115b9b382bb50aa17))

## [2.5.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.4.2...v2.5.0) (2024-08-02)


### Features

* Add perf command ([638fdfc](https://github.com/Isrothy/neominimap.nvim/commit/638fdfc994c278add09f4a90ce42b5db482ce14f))

### Performance Improvements

* Optimize is_white_space ([5771b81](https://github.com/Isrothy/neominimap.nvim/commit/5771b8169ec1c394e7be4507c03175ebf24f8e7e))

## [2.4.2](https://github.com/Isrothy/neominimap.nvim/compare/v2.4.1...v2.4.2) (2024-07-27)


### Bug Fixes

* Handle Blob input correctly in str_to_visible_codepoints() ([3c53bfd](https://github.com/Isrothy/neominimap.nvim/commit/3c53bfd51f6316258becd4c5e367c377f39df7f9))

## [2.4.1](https://github.com/Isrothy/neominimap.nvim/compare/v2.4.0...v2.4.1) (2024-07-25)


### Bug Fixes

* Set undolevels to -1 to reduce memoey use ([a3e6e25](https://github.com/Isrothy/neominimap.nvim/commit/a3e6e25d933a569c929bb861208530df9529c025))

## [2.4.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.3.0...v2.4.0) (2024-07-24)


### Features

* Enable type check if lazydev is enabled ([9164627](https://github.com/Isrothy/neominimap.nvim/commit/916462778401b5003fa53bdbeb06415f9c173e0c))
* Use vim.validate to validate user config ([1a815e9](https://github.com/Isrothy/neominimap.nvim/commit/1a815e90d02b307e7b0ace806dac50ae75bb42be))

## [2.3.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.2.0...v2.3.0) (2024-07-22)


### Features

* Allow users to override window options and buffer optinos ([9eca6eb](https://github.com/Isrothy/neominimap.nvim/commit/9eca6eb33389f4f9a54415a40891c43d8aa5addc))

## [2.2.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.1.1...v2.2.0) (2024-07-22)


### Features

* Add badges ([36ddc11](https://github.com/Isrothy/neominimap.nvim/commit/36ddc1113880eda2a0ad6f101d45fb2d281ed7cb))

## [2.1.1](https://github.com/Isrothy/neominimap.nvim/compare/v2.1.0...v2.1.1) (2024-07-22)


### Bug Fixes

* **window:** set spell false for the minimap window ([dbc959c](https://github.com/Isrothy/neominimap.nvim/commit/dbc959cabfc887e014da9639ade465cbebde8e58))

## [2.1.0](https://github.com/Isrothy/neominimap.nvim/compare/v2.0.2...v2.1.0) (2024-07-20)


### Features

* Added  configuration option to set margins ([87bf665](https://github.com/Isrothy/neominimap.nvim/commit/87bf665e978fd179bbe85413a60d56e1a73c9c77))


### Bug Fixes

* Ensure buffer ID validity ([16e490c](https://github.com/Isrothy/neominimap.nvim/commit/16e490cd061fae90f2cba30346debc6e25a77a60))

## [2.0.2](https://github.com/Isrothy/neominimap.nvim/compare/v2.0.1...v2.0.2) (2024-07-17)


### Bug Fixes

* Handle invalid buffer in debounced function ([29e9a27](https://github.com/Isrothy/neominimap.nvim/commit/29e9a2755eacb9041e03f6bbca61681691acc7a3))

## [2.0.1](https://github.com/Isrothy/neominimap.nvim/compare/v2.0.0...v2.0.1) (2024-07-16)


### Bug Fixes

* handle potential nil index in for-loop ([b88371c](https://github.com/Isrothy/neominimap.nvim/commit/b88371c40d2891bb366e65d1e9bed75445e90794))

## [2.0.0](https://github.com/Isrothy/neominimap.nvim/compare/v1.4.1...v1.5.0) (2024-07-14)


### Features

* Rewrote Vim command interface ([65ac122](https://github.com/Isrothy/neominimap.nvim/commit/65ac122c41939b9f30d12dfe91aaf28583f3b6b1))

## [1.4.1](https://github.com/Isrothy/neominimap.nvim/compare/v1.4.0...v1.4.1) (2024-07-14)


### Bug Fixes

* neominimap cannot show minimap for the 1st buffer ([5863669](https://github.com/Isrothy/neominimap.nvim/commit/58636692a779e021f70c6e056b7b6d3bf2010765))
* winhighlight ignored ([76386e3](https://github.com/Isrothy/neominimap.nvim/commit/76386e3ca9be5d7ed95a0b16fc43cdab2d555d7a))
* Wrong event to create minimap buffer ([9d2bf16](https://github.com/Isrothy/neominimap.nvim/commit/9d2bf166535356232d1b93b0e2fc0f8c017722be))

## [1.4.0](https://github.com/Isrothy/neominimap.nvim/compare/v1.3.2...v1.4.0) (2024-07-13)


### Features

* Add user configuration validation ([10cc88f](https://github.com/Isrothy/neominimap.nvim/commit/10cc88fe5ea071361bc442950bd990674d367246))

## [1.3.2](https://github.com/Isrothy/neominimap.nvim/compare/v1.3.1...v1.3.2) (2024-07-13)


### Bug Fixes

* enable cursorline even if not enabled ([b1147c9](https://github.com/Isrothy/neominimap.nvim/commit/b1147c9dd4b6edae0bb61a3312d899db765c059c))

## [1.3.1](https://github.com/Isrothy/neominimap.nvim/compare/v1.3.0...v1.3.1) (2024-07-12)


### Bug Fixes

* Correct buffer updating for diagnostic highlights ([38045d3](https://github.com/Isrothy/neominimap.nvim/commit/38045d37fdd2feffad6d1faaf50ab7f273959927))

## [1.3.0](https://github.com/Isrothy/neominimap.nvim/compare/v1.2.2...v1.3.0) (2024-07-12)


### Features

* **workflow:** Add panvimdoc workflow for generating vimdoc ([8204143](https://github.com/Isrothy/neominimap.nvim/commit/820414301e625219ef3ff1644fb1d65c30f69da0))

## [1.2.2](https://github.com/Isrothy/neominimap.nvim/compare/v1.2.1...v1.2.2) (2024-07-12)


### Bug Fixes

* call update_diagnostic on the correct buffers ([a3b53e6](https://github.com/Isrothy/neominimap.nvim/commit/a3b53e64573503197fc6106f06a6b59e2e7da0d4))

## [1.2.1](https://github.com/Isrothy/neominimap.nvim/compare/v1.2.0...v1.2.1) (2024-07-11)


### Bug Fixes

* Display only foreground color in minimap Treesitter highlights ([eaba632](https://github.com/Isrothy/neominimap.nvim/commit/eaba632b396c552f1b204e3abb258ebdc06d1378))

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
