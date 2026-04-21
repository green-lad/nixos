#!/usr/bin/env -S nu

let preview =  r##'
  let p = r#####{}#####
  | str replace -a r#''\'''# r#'''#
  | cliphist decode;

  if ($p | describe) == "binary" {
    $p | chafa -f sixel -s $"($env.FZF_PREVIEW_COLUMNS)x($env.FZF_PREVIEW_LINES)"
  } else {
    # TODO: nu-check seems to be broken, it returns true for svg content for example, this causes nu-highlight two be used when the highlight of a different language is wanted
    if ($p | nu-check) {
      $p | nu-highlight
    } else {
      $p | highlight -t Nord
    }
  }
'##

(
  cliphist list
    | fzf
      --layout reverse
      --bind 'ctrl-/:change-preview-window(hidden|)'
      --bind 'ctrl-space:change-preview-window(top,99%|)'
      --preview $preview
      --preview-window='wrap'
    | cliphist decode
    | wl-copy
)
