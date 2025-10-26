import { Accessor, For, createState } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import Graphene from "gi://Graphene"

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

interface SelectorProps<T> {
  gdkmonitor: Gdk.Monitor
  onSearch(text: string): T[]
  onSelect(item: T): void
  onRender(item: T): {
    icon?: string | Accessor<string>
    label: string
  }
  limit?: number
  name: string
  placeholder?: string
}

export default function Selector<T>(props: SelectorProps<T>) {
  let contentbox: Gtk.Box
  let searchentry: Gtk.Entry
  let win: Astal.Window

  const [list, setList] = createState(new Array<T>())

  function search(text: string) {
    setList(props.onSearch(text).slice(0, props.limit ?? 10))
  }

  function select(item: T) {
    win.hide()
    props.onSelect(item)
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
      name={props.name}
      class="selector"
      anchor={TOP | LEFT | RIGHT}
      gdkmonitor={props.gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      onNotifyVisible={({ visible }) => {
        if (visible) {
          searchentry.grab_focus()
          setList(props.onSearch(""))
        } else {
          searchentry.set_text("")
        }
      }}
    >
      <Gtk.EventControllerKey onKeyPressed={onKey} />
      <Gtk.GestureClick onPressed={onClick} />
      <box
        $={(ref) => (contentbox = ref)}
        valign={Gtk.Align.START}
        halign={Gtk.Align.CENTER}
        orientation={Gtk.Orientation.VERTICAL}
        widthRequest={Math.floor(props.gdkmonitor.geometry.width / 4)}
        css={`
          padding-top: ${Math.floor(props.gdkmonitor.geometry.height / 12)}px;
        `}
      >
        <entry
          $={(ref) => (searchentry = ref)}
          onNotifyText={({ text }) => search(text)}
          placeholderText={props.placeholder ?? "Search"}
          onActivate={() => {
            const first = list.get().at(0)
            win.hide()
            if (first) select(first)
          }}
        />
        <box orientation={Gtk.Orientation.VERTICAL}>
          <For each={list}>
            {(item) => {
              const { label, icon } = props.onRender(item)

              return (
                <button onClicked={() => select(item)}>
                  <box>
                    <image
                      iconName={icon}
                      visible={Boolean(icon)}
                      iconSize={Gtk.IconSize.LARGE}
                    />
                    <label label={label} maxWidthChars={60} wrap />
                  </box>
                </button>
              )
            }}
          </For>
        </box>
      </box>
    </window>
  )
}
