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
  local from_tone=$1 to_tone=$2 glyph=$3 from_colour=${4:-} to_colour=${5:-}
  [ -z "$from_colour" ] && from_colour=$(colour_of_tone "$from_tone")
  [ -z "$to_colour" ] && to_colour=$(colour_of_tone "$to_tone")
  # Same tones meet only when a conditional group between them is hidden; they merge
  if [ "$from_tone" = "$to_tone" ] || [ -z "$glyph" ]; then return; fi
  printf '#[nobold]#[fg=%s]#[bg=%s]%s' "$from_colour" "$to_colour" "$glyph"
}

# Background of an accent group holding stateful modules: crit if a shown module is
# crit, else warn if one is warn, else the accent colour. Prints nothing when no
# module has a _state. Stored in a generated option and referenced through #{E:},
# because its commas would otherwise split the #{?} branches it is used inside.
accent_group_colour() {
  local modules=$1 side=$2 index=$3 name condition state
  local -a crit_terms=() warn_terms=()
  for name in $modules; do
    [ -z "$(option "@oasis_module_${name}_state")" ] && continue
    condition=$(option "@oasis_module_${name}_when")
    state="#{E:@oasis_module_${name}_state}"
    crit_terms+=("$(both_of "$condition" "#{==:$state,crit}")")
    warn_terms+=("$(both_of "$condition" "#{==:$state,warn}")")
  done
  [ ${#crit_terms[@]} -eq 0 ] && return
  tmux set -g "@oasis_group_colour_${side}_${index}" \
    "#{?$(any_of "${crit_terms[@]}"),#{E:@oasis_state_crit_color},#{?$(any_of "${warn_terms[@]}"),#{E:@oasis_state_warn_color},$ACCENT_COLOUR}}"
  printf '%s' "#{E:@oasis_group_colour_${side}_${index}}"
}

# Fills group_modules, group_conditions, group_tones and group_colours for one side
parse_groups() {
  local list=$1 side=$2 group name modules count i edge_distance colour
  local -a raw_groups names conditions
  group_modules=(); group_conditions=(); group_tones=(); group_colours=()
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
    colour=""
    [ "${group_tones[$i]}" = accent ] && colour=$(accent_group_colour "${group_modules[$i]}" "$side" "$i")
    group_colours+=("${colour:-$(colour_of_tone "${group_tones[$i]}")}")
  done
}

# Surface groups: colours a module's text by its _state format. crit and warn pick
# their option's colour, anything else keeps the group's text colour.
# One attribute per #[...] because commas inside #{?} branches split them.
with_state_colour() {
  local name=$1 text_colour=$2 state
  state="#{E:@oasis_module_${name}_state}"
  printf '#{?#{==:%s,crit},#[fg=#{E:@oasis_state_crit_color}],#{?#{==:%s,warn},#[fg=#{E:@oasis_state_warn_color}],#[fg=%s]}}#{E:@oasis_module_%s}#[fg=%s]' \
    "$state" "$state" "$text_colour" "$name" "$text_colour"
}

group_body() {
  local tone=$1 modules=$2 colour=$3 name condition body="" text_tone=surface text
  local -a earlier_conditions=()
  [ "$tone" = surface ] && text_tone=accent
  for name in $modules; do
    condition=$(option "@oasis_module_${name}_when")
    if [ ${#earlier_conditions[@]} -gt 0 ]; then
      body+=$(shown_when "$(both_of "$condition" "$(any_of "${earlier_conditions[@]}")")" "$module_separator")
    fi
    text="#{E:@oasis_module_$name}"
    # Accent groups show state in their background instead, see accent_group_colour
    [ "$tone" = surface ] && [ -n "$(option "@oasis_module_${name}_state")" ] && text=$(with_state_colour "$name" "$(colour_of_tone "$text_tone")")
    body+=$(shown_when "$condition" "$text")
    earlier_conditions+=("$condition")
  done
  printf '#[bg=%s]#[fg=%s]#[bold] %s ' "$colour" "$(colour_of_tone "$text_tone")" "$body"
}

# Takes the indices of the groups between this one and the middle, nearest first.
# The nearest visible one decides the separator's colour, else the middle does.
separator_toward_middle() {
  local own_tone=$1 own_colour=$2 glyph=$3; shift 3
  local condition separator_to_nearest
  if [ $# -eq 0 ]; then
    separator "$own_tone" middle "$glyph" "$own_colour"
    return
  fi
  condition=${group_conditions[$1]}
  separator_to_nearest=$(separator "$own_tone" "${group_tones[$1]}" "$glyph" "$own_colour" "${group_colours[$1]}")
  shift
  if [ -z "$condition" ]; then printf '%s' "$separator_to_nearest"; return; fi
  printf '#{?%s,%s,%s}' "$condition" "$separator_to_nearest" "$(separator_toward_middle "$own_tone" "$own_colour" "$glyph" "$@")"
}

build_left() {
  local count=${#group_modules[@]} i j output=""
  local -a groups_toward_middle
  for ((i = 0; i < count; i++)); do
    groups_toward_middle=()
    for ((j = i + 1; j < count; j++)); do groups_toward_middle+=("$j"); done
    output+=$(shown_when "${group_conditions[$i]}" \
      "$(group_body "${group_tones[$i]}" "${group_modules[$i]}" "${group_colours[$i]}")$(separator_toward_middle "${group_tones[$i]}" "${group_colours[$i]}" "$left_glyph" ${groups_toward_middle[@]+"${groups_toward_middle[@]}"})")
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
      "$(separator_toward_middle "${group_tones[$i]}" "${group_colours[$i]}" "$right_glyph" ${groups_toward_middle[@]+"${groups_toward_middle[@]}"})$(group_body "${group_tones[$i]}" "${group_modules[$i]}" "${group_colours[$i]}")")
  done
  [ -n "$output" ] && output=" $output"
  printf '%s' "$output"
}

parse_groups "$(option @oasis_status_left)" left
tmux set -g status-left "$(build_left)"

parse_groups "$(option @oasis_status_right)" right
tmux set -g status-right "$(build_right)"

window_format() {
  local pill_colour=$1 text_style=$2 module=$3 text_padding=${4:-} output=""
  if [ -n "$window_left_glyph" ]; then
    if $window_left_is_notch; then
      output+="#[fg=$MIDDLE_COLOUR]#[bg=$pill_colour]$window_left_glyph"
    else
      output+="#[fg=$pill_colour]#[bg=$MIDDLE_COLOUR]$window_left_glyph"
    fi
  fi
  output+="#[bg=$pill_colour]$text_style#{E:@oasis_module_$module}$text_padding"
  [ -n "$window_right_glyph" ] && output+="#[fg=$pill_colour]#[bg=$MIDDLE_COLOUR]$window_right_glyph"
  printf '%s' "$output"
}

# Inactive windows change text colour while the prefix key table is active
inactive_text_style='#{?#{==:#{client_key_table},prefix},#[fg=#{@thm_secondary}],#[fg=#{@thm_primary_strong}]}'
active_text_style='#[fg=#{@thm_core}]#[bold]'
# The inactive text has no trailing space; a right cap pads it, so only a capless pill needs one
inactive_text_padding=''
[ -z "$window_right_glyph" ] && inactive_text_padding=' '
tmux set -g window-status-format "$(window_format "$SURFACE_COLOUR" "$inactive_text_style" window_inactive "$inactive_text_padding")"
tmux set -g window-status-current-format "$(window_format '#{@thm_secondary}' "$active_text_style" window_active)"
