import app from "ags/gtk4/app"
import style from "./style.scss"
import { Gdk, Gtk } from "ags/gtk4"
import { SpeakerSelector } from "./widget/SpeakerSelector"
import { MicrophoneSelector } from "./widget/MicrophoneSelector"
import { ApplicationLauncher } from "./widget/ApplicationLauncher"
import Tray from "./widget/Tray"

app.start({
  css: style,
  main() {
    app.add_window(
      SpeakerSelector(app.get_monitors().at(0) as Gdk.Monitor) as Gtk.Window,
    )
    app.add_window(
      MicrophoneSelector(app.get_monitors().at(0) as Gdk.Monitor) as Gtk.Window,
    )
    app.add_window(
      ApplicationLauncher(
        app.get_monitors().at(0) as Gdk.Monitor,
      ) as Gtk.Window,
    )
    app.add_window(Tray(app.get_monitors().at(0) as Gdk.Monitor) as Gtk.Window)
  },
})
