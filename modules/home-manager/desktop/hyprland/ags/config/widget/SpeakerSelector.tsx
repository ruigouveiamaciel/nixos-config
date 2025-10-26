import { Gdk } from "ags/gtk4"
import Selector from "./Selector"
import AstalWp from "gi://AstalWp"

export function SpeakerSelector(gdkmonitor: Gdk.Monitor) {
  const wp = AstalWp.get_default()

  return (
    <Selector<AstalWp.Endpoint>
      name="speaker-selector"
      gdkmonitor={gdkmonitor}
      onSearch={(text) => {
        text = text.trim().toLowerCase()
        return wp.audio.speakers.filter(
          (speaker) =>
            text === "" || speaker.description.toLowerCase().includes(text),
        )
      }}
      onSelect={(speaker) => speaker.set_is_default(true)}
      onRender={(speaker) => ({ label: speaker.description })}
      placeholder="Search speakers"
    />
  )
}
