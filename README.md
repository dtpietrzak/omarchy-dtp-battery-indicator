# omarchy-dtp-battery-indicator

An outlined horizontal battery for the Omarchy bar. The tip is on the left, the outline is 75% opaque, the inside fills from the right at 35% opacity, and the charge is the same color as the outline. There is no percent sign and no charge fill.

Click it to open the power panel: charge details, power profile, and system stats. While this plugin is on the bar it takes the place of `omarchy.power`. Turning it off puts the stock battery back, including the percentage setting it had.

The popup matches `omarchy.power` from Omarchy 4.5.0-3. After an Omarchy update, re-copy `Panel.qml` and `Model.js` from `/usr/share/omarchy/shell/plugins/panels/power/` and put the bar mark back.

## Install

`omarchy-dtp-install` installs this and swaps it into the battery's place. By hand:

```bash
omarchy plugin add https://github.com/dtpietrzak/omarchy-dtp-battery-indicator.git --enable
```
