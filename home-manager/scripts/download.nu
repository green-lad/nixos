#!/usr/bin/env -S nu --stdin

# usage:
# - create links.csv file with song and yt_id column and call call via main;
# ./download.nu
# - pipe table<song: string, yt_id: string> into:
# use download.nu *; let r = open links.csv | download_n
# - download one song into example_dir directory:
# use download.nu *; let r = {song: Asgore_Shogun, yt_id: VPPtxBNQccg} | download_one example_dir

const default_outdir = "songs"

export def download_one [outdir = $default_outdir, audio_format = "mp3"]: [
    record<song: string, yt_id: string> -> record<path: string, duplicate: bool, mismatch: bool, download_failed: bool, command: string, info_dump: list<any>, errors: list<string>>
  ] {
  let input = $in
  let yt_id = $input | get yt_id
  let song = $input | get song
  let link = $"https://youtube.com/watch?v=($yt_id)"
  let output = [$outdir, $"($song).%\(ext\)s"] | path join 

  mkdir $outdir
  let command = $"\(yt-dlp
      --embed-metadata
      --dump-json
      --no-simulate
      --quiet
      --use-extractors 'all'
      --extract-audio
      --audio-format '($audio_format)'
      --restrict-filenames
      --output '($output)'
      --format 'bestaudio'
      --embed-thumbnail
      --convert-thumbnails jpg
      '($link)'\)
    | complete"

  let path = $'($outdir)/($input | get song).($audio_format)'
  if ($path | path exists) {
    let existing = ffmpeg -i $path -f ffmetadata e>| parse -r '^\s*purl\s*:\s*(?P<purl>.*)$' | get purl | get 0 | url parse | get params | get value | get 0
    let mismatch = $existing != $yt_id
    if $mismatch {
      print $"(ansi red_italic)Mismatching missing: ($input), existing: ($existing)(ansi reset)"
    } else {
      print $"(ansi yellow_italic)Already exists, skipping: ($input)(ansi reset)"
    }
    return {song: ($input | get song), duplicate: true, mismatch: $mismatch, download_failed: false, command: $command, info_dump: [], errors: []}
  }

  print $"(ansi green_italic)Start download: ($input)(ansi reset)"
  let return = nu -c $'($command) | to nuon' | from nuon

  let failed = ($return | get exit_code | into int) != 0
  if $failed {
    print $"(ansi red_italic)Download failed [($failed)]: ($input)(ansi reset)"
  }
  return ({
    song: ($input | get song),
    duplicate: false,
    mismatch: false,
    download_failed: $failed,
    command: $command,
    info: ($return | get stdout | from json),
    errors: ($return | get stderr | lines)
  })
}

export def download_n [outdir = $default_outdir]: [
    table<song: string, yt_id: string> -> record<downloads: list<any>, duplicates: list<any>, mismatches: list<any>, download_fails: list<any>>
  ] {
  let input = $in
  mkdir $outdir
  let r = $input | par-each { download_one $outdir }
  return ({
    downloads: ($r | where { |e| not $e.duplicate and not $e.download_failed }),
    duplicates: ($r | where { |e| $e.duplicate and not $e.mismatch }),
    mismatches: ($r | where mismatch),
    download_fails: ($r | where download_failed)
  })
}

def main [input_file = "links.csv", outdir = $default_outdir, --return_data] {
  let $input = open $input_file
  let $r = $input | download_n $outdir
  print ({
    downloads: ($r | get downloads | length),
    duplicates: ($r | get duplicates | length),
    mismatches: ($r | get mismatches | length),
    download_fails: ($r | get download_fails | length)
  })
  if $return_data {
    return $r | to nuon
  }
  return (($r | get mismatches | length) + ($r | get download_fails | length))
}
