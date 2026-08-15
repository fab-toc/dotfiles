# Android Studio

## Arch — AUR

```sh
yay -S android-studio
```

Enable the [multilib] repository first. The SDK ships 32-bit binaries, and
without multilib you get `error: target not found: lib32-*`.

If Studio opens as a blank window, export `_JAVA_AWT_WM_NONREPARENTING=1`.
Recent builds bundle their own Java, so the `archlinux-java` default usually
does not matter — see [jdk-openjdk.md](./jdk-openjdk.md) if it does.

## Debian and Ubuntu — manual

Android Studio is not packaged. Download the tarball from
<https://developer.android.com/studio>, unpack it under `/opt`, and run
`bin/studio.sh`. It is a `manual` row in the manifest for exactly this reason.

## The SDK belongs to Studio, not to the package manager

Let Studio's Setup Wizard install and update the SDK. It lands in
`~/Android/Sdk`, which is what `ANDROID_HOME` in `.zshenv` points at.

The AUR also has SDK components (`android-sdk-cmdline-tools-latest`,
`android-sdk-build-tools`, `android-platform`, …) which install to
`/opt/android-sdk`. **Do not mix the two.** They are mutually exclusive layouts,
the AUR packages lag upstream, and Studio's own updater will fight whatever
pacman installed. Keeping one owner is worth more here than the package
tracking ADR-0001 normally prefers.

`ANDROID_HOME` is exported unconditionally, on headless machines too. It costs
nothing when the directory is absent, and the `PATH` entries that depend on it
are filtered by zsh's `(N-/)` qualifier, so they simply drop out.

For command-line builds (`./gradlew assembleDebug`), `ANDROID_HOME` is the only
variable Gradle needs.
