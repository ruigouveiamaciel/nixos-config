import { Gdk } from "ags/gtk4"
import Selector from "./Selector"
import AstalApps from "gi://AstalApps"

export function ApplicationLauncher(gdkmonitor: Gdk.Monitor) {
  const apps = new AstalApps.Apps()

  return (
    <Selector<AstalApps.Application>
      name="application-launcher"
      gdkmonitor={gdkmonitor}
      onSearch={(text) => {
        text = text.trim().toLowerCase()
        if (text === "") return []
        return apps.fuzzy_query(text)
      }}
      onSelect={(app) => app.launch()}
      onRender={(app) => ({ label: app.name, icon: app.iconName })}
      placeholder="Search applications"
    />
  )
}
