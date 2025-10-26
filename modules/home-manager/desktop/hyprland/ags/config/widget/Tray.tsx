import { Accessor, For, createBinding } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import AstalTray from "gi://AstalTray"
import Graphene from "gi://Graphene"

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

export default function Tray(gdkmonitor: Gdk.Monitor) {
  let contentbox: Gtk.Box
  let win: Astal.Window

  const tray = AstalTray.get_default()
  const items = createBinding(tray, "items")

  const init = (btn: Gtk.MenuButton, item: AstalTray.TrayItem) => {
    btn.menuModel = item.menuModel
    btn.insert_action_group("dbusmenu", item.actionGroup)
    item.connect("notify::action-group", () => {
      btn.insert_action_group("dbusmenu", item.actionGroup)
    })
  }

  function onKey(
    _e: Gtk.EventControllerKey,
    keyval: number,
    _: number,
    _mod: number,
  ) {
    if (keyval === Gdk.KEY_Escape) {
      win.hide()
      return
    }
  }

  function onClick(_e: Gtk.GestureClick, _: number, x: number, y: number) {
    const [, rect] = contentbox.compute_bounds(win)
    const position = new Graphene.Point({ x, y })

    if (!rect.contains_point(position)) {
      win.hide()
      return true
    }
  }

  return (
    <window
      $={(ref) => (win = ref)}
      name="tray"
      class="tray"
      anchor={TOP | LEFT | RIGHT}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
    >
      <Gtk.EventControllerKey onKeyPressed={onKey} />
      <Gtk.GestureClick onPressed={onClick} />
      <box
        $={(ref) => (contentbox = ref)}
        valign={Gtk.Align.START}
        halign={Gtk.Align.CENTER}
        orientation={Gtk.Orientation.VERTICAL}
        css={`
          padding-top: ${Math.floor(gdkmonitor.geometry.height / 12)}px;
        `}
      >
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <For each={items}>
            {(item) => (
              <menubutton $={(self) => init(self, item)}>
                <image
                  gicon={createBinding(item, "gicon")}
                  iconSize={Gtk.IconSize.LARGE}
                />
              </menubutton>
            )}
          </For>
        </box>
      </box>
    </window>
  )
}
