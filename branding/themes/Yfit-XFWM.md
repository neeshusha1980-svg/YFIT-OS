# Yfit window decorations

The `8900-yfit-window-theme.hook.chroot` copies the Debian Trixie XFWM4 Daloa theme assets into `/usr/share/themes/Yfit/xfwm4` and recolors its XPM title/frame palette with Yfit's dark, yellow, and green tokens. It removes raster duplicates so XFWM4 reads the recolored XPMs. Debian's full xfwm4 copyright notice is copied into the installed `/usr/share/doc/yfit-os/DALOA-XFWM-COPYRIGHT`.

The user can switch between `Yfit` and `Yfit-Light` GTK themes in XFCE Appearance settings. The neutral XCursor theme is Whiteglass from Debian's `xcursor-themes`; the project does not replace pointer art.
