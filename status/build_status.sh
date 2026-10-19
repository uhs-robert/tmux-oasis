#!/usr/bin/env bash
# Builds status-left and status-right from @oasis_status_left / @oasis_status_right.
#
# A list is groups split by "|", each holding space-separated module names, e.g.
# "sync | folder | clock". Groups alternate accent and surface tones starting
# with accent at the screen edge, and separators are drawn between neighbouring
# groups. tmux formats can't split strings, so the lists are parsed here at load
# time; the output is still a format, so colours follow the mode at draw time.
#
# Inside #{?cond,a,b} tmux splits on every top-level comma and doesn't skip #[...],
# so styles are emitted one attribute per #[...] block.

set -u

ACCENT_COLOUR='#{E:@oasis_color_mode}'
SURFACE_COLOUR='#{@thm_surface}'
MIDDLE_COLOUR='#{@thm_mantle}'

option() { tmux show -gqv "$1"; }

# Glyphs are UTF-8 byte escapes: \u escapes need bash 4.2 and macOS ships 3.2
case "$(option @oasis_separator)" in
  flat)  left_glyph='';              right_glyph='' ;;
  round) left_glyph=$'\xee\x82\xb4'; right_glyph=$'\xee\x82\xb6' ;;
  slant) left_glyph=$'\xee\x82\xbc'; right_glyph=$'\xee\x82\xbe' ;;
  *)     left_glyph=$'\xee\x82\xb0'; right_glyph=$'\xee\x82\xb2' ;;
esac
left_override=$(option @oasis_separator_left)
right_override=$(option @oasis_separator_right)
[ -n "$left_override" ] && left_glyph=$left_override
[ -n "$right_override" ] && right_glyph=$right_override
module_separator=$(option @oasis_separator_module)

# Each window is its own pill on the middle colour, so its caps never depend on a neighbour
window_separator=$(option @oasis_window_separator)
case "$window_separator" in
  flat)      window_left_glyph='';              window_right_glyph='' ;;
  powerline) window_left_glyph=$'\xee\x82\xb0'; window_right_glyph=$'\xee\x82\xb0' ;;
  slant)     window_left_glyph=$'\xee\x82\xba'; window_right_glyph=$'\xee\x82\xbc' ;;
  *)         window_left_glyph=$'\xee\x82\xb6'; window_right_glyph=$'\xee\x82\xb4' ;;
esac
# powerline's left cap is cut out of the pill, drawn in the middle colour on top of it
window_left_is_notch=false
[ "$window_separator" = powerline ] && window_left_is_notch=true
window_left_override=$(option @oasis_window_separator_left)
window_right_override=$(option @oasis_window_separator_right)
[ -n "$window_left_override" ] && window_left_glyph=$window_left_override && window_left_is_notch=false
[ -n "$window_right_override" ] && window_right_glyph=$window_right_override

# Conditions are tmux formats; an empty condition means "always shown"
any_of() {
  local result="" condition
  for condition in "$@"; do
    [ -z "$condition" ] && return
    if [ -z "$result" ]; then result=$condition; else result="#{||:$condition,$result}"; fi
  done
  printf '%s' "$result"
}

both_of() {
  if [ -z "$1" ]; then printf '%s' "$2"
  elif [ -z "$2" ]; then printf '%s' "$1"
  else printf '%s' "#{&&:$1,$2}"
  fi
}

shown_when() {
  local condition=$1 text=$2
  if [ -z "$condition" ] || [ -z "$text" ]; then printf '%s' "$text"; else printf '%s' "#{?$condition,$text,}"; fi
}

colour_of_tone() {
  case "$1" in
    accent)  printf '%s' "$ACCENT_COLOUR" ;;
    surface) printf '%s' "$SURFACE_COLOUR" ;;
    middle)  printf '%s' "$MIDDLE_COLOUR" ;;
  esac
}

separator() {
  local from_tone=$1 to_tone=$2 glyph=$3
  # Same tones meet only when a conditional group between them is hidden; they merge
  if [ "$from_tone" = "$to_tone" ] || [ -z "$glyph" ]; then return; fi
  printf '#[nobold]#[fg=%s]#[bg=%s]%s' "$(colour_of_tone "$from_tone")" "$(colour_of_tone "$to_tone")" "$glyph"
}

# Fills group_modules, group_conditions and group_tones for one side
parse_groups() {
  local list=$1 side=$2 group name modules count i edge_distance
  local -a raw_groups names conditions
  group_modules=(); group_conditions=(); group_tones=()
  IFS='|' read -ra raw_groups <<< "$list"
  for group in "${raw_groups[@]}"; do
    read -ra names <<< "$group"
    modules=""; conditions=()
    for name in ${names[@]+"${names[@]}"}; do
      if [ -z "$(option "@oasis_module_$name")" ]; then
        tmux display-message "oasis: unknown status module '$name'"
        continue
      fi
      modules+="$name "
      conditions+=("$(option "@oasis_module_${name}_when")")
    done
    [ -z "$modules" ] && continue
    group_modules+=("$modules")
    group_conditions+=("$(any_of "${conditions[@]}")")
  done
  count=${#group_modules[@]}
  for ((i = 0; i < count; i++)); do
    if [ "$side" = left ]; then edge_distance=$i; else edge_distance=$((count - 1 - i)); fi
    if ((edge_distance % 2 == 0)); then group_tones+=(accent); else group_tones+=(surface); fi
  done
}

group_body() {
  local tone=$1 modules=$2 name condition body="" text_tone=surface
  local -a earlier_conditions=()
  [ "$tone" = surface ] && text_tone=accent
  for name in $modules; do
    condition=$(option "@oasis_module_${name}_when")
    if [ ${#earlier_conditions[@]} -gt 0 ]; then
      body+=$(shown_when "$(both_of "$condition" "$(any_of "${earlier_conditions[@]}")")" "$module_separator")
    fi
    body+=$(shown_when "$condition" "#{E:@oasis_module_$name}")
    earlier_conditions+=("$condition")
  done
  printf '#[bg=%s]#[fg=%s]#[bold] %s ' "$(colour_of_tone "$tone")" "$(colour_of_tone "$text_tone")" "$body"
}

# Takes the indices of the groups between this one and the middle, nearest first.
# The nearest visible one decides the separator's colour, else the middle does.
separator_toward_middle() {
  local own_tone=$1 glyph=$2; shift 2
  local condition separator_to_nearest
  if [ $# -eq 0 ]; then
    separator "$own_tone" middle "$glyph"
    return
  fi
  condition=${group_conditions[$1]}
  separator_to_nearest=$(separator "$own_tone" "${group_tones[$1]}" "$glyph")
  shift
  if [ -z "$condition" ]; then printf '%s' "$separator_to_nearest"; return; fi
  printf '#{?%s,%s,%s}' "$condition" "$separator_to_nearest" "$(separator_toward_middle "$own_tone" "$glyph" "$@")"
}

build_left() {
  local count=${#group_modules[@]} i j output=""
  local -a groups_toward_middle
  for ((i = 0; i < count; i++)); do
    groups_toward_middle=()
    for ((j = i + 1; j < count; j++)); do groups_toward_middle+=("$j"); done
    output+=$(shown_when "${group_conditions[$i]}" \
      "$(group_body "${group_tones[$i]}" "${group_modules[$i]}")$(separator_toward_middle "${group_tones[$i]}" "$left_glyph" ${groups_toward_middle[@]+"${groups_toward_middle[@]}"})")
  done
  # One cell of gap before the window list
  [ -n "$output" ] && output+="#[nobold]#[bg=$MIDDLE_COLOUR] "
  printf '%s' "$output"
}

build_right() {
  local count=${#group_modules[@]} i j output=""
  local -a groups_toward_middle
  for ((i = 0; i < count; i++)); do
    groups_toward_middle=()
    for ((j = i - 1; j >= 0; j--)); do groups_toward_middle+=("$j"); done
    output+=$(shown_when "${group_conditions[$i]}" \
      "$(separator_toward_middle "${group_tones[$i]}" "$right_glyph" ${groups_toward_middle[@]+"${groups_toward_middle[@]}"})$(group_body "${group_tones[$i]}" "${group_modules[$i]}")")
  done
  [ -n "$output" ] && output=" $output"
  printf '%s' "$output"
}

parse_groups "$(option @oasis_status_left)" left
tmux set -g status-left "$(build_left)"

parse_groups "$(option @oasis_status_right)" right
tmux set -g status-right "$(build_right)"

window_format() {
  local pill_colour=$1 text_style=$2 module=$3 output=""
  if [ -n "$window_left_glyph" ]; then
    if $window_left_is_notch; then
      output+="#[fg=$MIDDLE_COLOUR]#[bg=$pill_colour]$window_left_glyph"
    else
      output+="#[fg=$pill_colour]#[bg=$MIDDLE_COLOUR]$window_left_glyph"
    fi
  fi
  output+="#[bg=$pill_colour]$text_style#{E:@oasis_module_$module}"
  [ -n "$window_right_glyph" ] && output+="#[fg=$pill_colour]#[bg=$MIDDLE_COLOUR]$window_right_glyph"
  printf '%s' "$output"
}

# Inactive windows change text colour while the prefix key table is active
inactive_text_style='#{?#{==:#{client_key_table},prefix},#[fg=#{@thm_secondary}],#[fg=#{@thm_primary_strong}]}'
active_text_style='#[fg=#{@thm_core}]#[bold]'
tmux set -g window-status-format "$(window_format "$SURFACE_COLOUR" "$inactive_text_style" window_inactive)"
tmux set -g window-status-current-format "$(window_format '#{@thm_secondary}' "$active_text_style" window_active)"
