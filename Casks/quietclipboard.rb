cask "quietclipboard" do
  version "0.1.7"
  sha256 "681c7efc7db17823593016fa4b4a08febb72dfee315e27d2fccf994c2b913177"

  url "https://github.com/quietapps/QuietClipboard/releases/download/#{version}/QuietClipboard-#{version}.zip",
      verified: "github.com/quietapps/QuietClipboard/"
  name "Quiet Clipboard"
  desc "Silent menu-bar clipboard history manager — text, images, links, files, code, colors"
  homepage "https://github.com/quietapps/QuietClipboard"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: ">= :sequoia"

  app "Quiet Clipboard.app"

  # Build is not signed with an Apple Developer ID. Make the app launchable on
  # any Mac out of the box:
  #   1. Strip ALL extended attributes (com.apple.quarantine, com.apple.macl,
  #      com.apple.provenance) so Gatekeeper does not block launch.
  #   2. Force-register the bundle with Launch Services so double-clicking from
  #      Finder / Dock launches the real binary.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Quiet Clipboard.app"],
                   sudo: false
    system_command "/System/Library/Frameworks/CoreServices.framework/" \
                   "Versions/A/Frameworks/LaunchServices.framework/" \
                   "Versions/A/Support/lsregister",
                   args: ["-f", "#{appdir}/Quiet Clipboard.app"],
                   sudo: false,
                   must_succeed: false
  end

  zap trash: [
    "~/Library/Preferences/app.quiet.QuietClipboard.plist",
    "~/Library/Application Support/QuietClipboard",
    "~/Library/Caches/app.quiet.QuietClipboard",
    "~/Library/HTTPStorages/app.quiet.QuietClipboard",
    "~/Library/Saved Application State/app.quiet.QuietClipboard.savedState",
  ]

  caveats <<~EOS
    Quiet Clipboard is distributed unsigned. The post-install hook strips
    Gatekeeper attributes automatically, but if the app refuses to launch
    on a fresh Mac, do this once:

      1. Open Finder → /Applications
      2. Right-click "Quiet Clipboard.app" → Open
      3. Click "Open" in the dialog
      4. macOS remembers your choice for every future launch

    Or run this in Terminal once after install:
      xattr -cr "/Applications/Quiet Clipboard.app"

    Quiet Clipboard needs Accessibility access to paste back into the app
    that was focused before you opened the quick search overlay. On first
    paste, grant access in:
      System Settings → Privacy & Security → Accessibility

    After upgrading, you may need to remove and re-add Quiet Clipboard in
    the Accessibility list because macOS binds permissions to the app's
    code signature, which changes between unsigned builds.
  EOS
end
