# Create a "Simultaneous" null sink, link its monitor ports to every
# physical output, and make it the default sink, so audio plays on all
# outputs at once.
#
# Behaviour:
#   * If a "Simultaneous" sink already exists, it is always torn down
#     (including duplicates) and rebuilt from scratch.
#   * Fails immediately if either target output is not currently
#     available — no waiting around.
set -u

SINK=Simultaneous
RETRIES=20        # 20 * 0.25s = 5s max wait for the new sink's own ports
SLEEP=0.25

say()  { echo "simultaneous-output: $*"; }
warn() { say "$*" >&2; }

# Print the name (column 2) of the first sink whose name matches regex $1.
sink_matching() {
  pactl list short sinks 2>/dev/null | awk -F'\t' -v pat="$1" '$2 ~ pat {print $2; exit}'
}

# --- Tear down any previous Simultaneous sinks (including duplicates) ----
pactl list short modules 2>/dev/null \
  | awk -F'\t' -v pat="sink_name=$SINK" '$3 ~ pat {print $1}' \
  | while read -r mod; do
      pactl unload-module "$mod" 2>/dev/null || true
    done

# Wait until the old sink is fully gone so the new one gets a clean name
# (PipeWire otherwise renames it Simultaneous.1, .2, ...).
for ((i = 0; i < RETRIES; i++)); do
  [ -z "$(sink_matching "^$SINK([.][0-9]+)?$")" ] && break
  sleep "$SLEEP"
done
if [ -n "$(sink_matching "^$SINK([.][0-9]+)?$")" ]; then
  warn "old '$SINK' sink still present, giving up"
  exit 1
fi

# --- Fail fast if either output is missing -------------------------------
usb=$(sink_matching 'Apple.*3[.]5mm')
hdmi=$(sink_matching 'hdmi-stereo-extra2')

if [ -z "$usb" ] || [ -z "$hdmi" ]; then
  [ -n "$usb" ] || warn "USB-C headphone jack not found"
  [ -n "$hdmi" ] || warn "HDMI output not found"
  warn "available sinks:"
  pactl list short sinks 2>/dev/null | cut -f2 | sed 's/^/  /' >&2
  exit 1
fi

# --- Create a fresh null sink --------------------------------------------
pactl load-module module-null-sink \
  media.class=Audio/Sink sink_name=$SINK channel_map=stereo \
  >/dev/null 2>&1 || { warn "could not create null sink"; exit 1; }

# Wait briefly for the new sink's monitor ports to register in PipeWire
# (this is our own sink, not a missing output).
for ((i = 0; i < RETRIES; i++)); do
  pw-link -o "$SINK" >/dev/null 2>&1 && break
  sleep "$SLEEP"
done
pw-link -o "$SINK" >/dev/null 2>&1 \
  || { warn "'$SINK' ports did not register"; exit 1; }

# --- Link both channels to both outputs -----------------------------------
link() {
  local src="$1" dst="$2" label="$3"
  if ! pw-link "$src" "$dst" >/dev/null 2>&1; then
    warn "$label: could not link $src -> $dst"
    warn "  target ports: $(pw-link -i "${dst%%:*}" 2>/dev/null | tr '\n' ' ')"
    exit 1
  fi
}

for ch in FL FR; do
  link "$SINK:monitor_$ch" "$usb:playback_$ch"  "USB-C headphone jack"
  link "$SINK:monitor_$ch" "$hdmi:playback_$ch" "HDMI"
done

# --- Make it the default sink ---------------------------------------------
pactl set-default-sink "$SINK" || { warn "could not set default sink"; exit 1; }

say "done: '$SINK' linked to USB jack + HDMI and set as default"
