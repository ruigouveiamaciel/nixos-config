import { Gdk } from "ags/gtk4"
import Selector from "./Selector"
import AstalWp from "gi://AstalWp"

export function MicrophoneSelector(gdkmonitor: Gdk.Monitor) {
  const wp = AstalWp.get_default()

  return (
    <Selector<AstalWp.Endpoint>
      name="microphone-selector"
      gdkmonitor={gdkmonitor}
      onSearch={(text) => {
        text = text.trim().toLowerCase()
        return wp.audio.microphones.filter(
          (microphone) =>
            text === "" || microphone.description.toLowerCase().includes(text),
        )
      }}
      onSelect={(microphone) => microphone.set_is_default(true)}
      onRender={(microphone) => ({ label: microphone.description })}
      placeholder="Search microphones"
    />
  )
}
