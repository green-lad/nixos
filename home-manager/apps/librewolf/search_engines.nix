let
  daily = 24 * 60 * 60 * 1000;
  weekly = 7 * daily;
in
{
  "google".metaData.hidden = true;
  "bing".metaData.hidden = true;

  "app store" = {
    urls = [ { template = "https://www.apple.com/us/search/{searchTerms}?src=globalnav"; } ];
    icon = "https://www.apple.com/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@iosapp" ];
  };

  "aliexpress" = {
    urls = [ { template = "https://aliexpress.com/wholesale?SearchText={searchTerms}"; } ];
    updateInterval = weekly;
    definedAliases = [ "@ali" ];
  };

  "amazon" = {
    urls = [ { template = "https://www.amazon.de/s?k={searchTerms}"; } ];
    icon = "https://www.amazon.de/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@a" ];
  };

  "arxiv" = {
    urls = [
      {
        template = "https://arxiv.org/search/?query={searchTerms}&searchtype=all&source=header";
      }
    ];
    icon = "https://static.arxiv.org/static/base/1.0.0a5/images/arxiv-logo-one-color-white.svg";
    updateInterval = weekly;
    definedAliases = [ "@rfa" ];
  };

  "chefkoch" = {
    urls = [
      {
        template = "https://www.chefkoch.de/rs/s0/{searchTerms}/Rezepte.html";
      }
    ];
    icon = "https://img.chefkoch-cdn.de/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@ch" ];
  };

  "crossref" = {
    urls = [
      {
        template = "https://search.crossref.org/search/works?q={searchTerms}&from_ui=yes";
      }
    ];
    icon = "https://assets.crossref.org/favicon/android-chrome-192x192.png";
    updateInterval = weekly;
    definedAliases = [ "@rfc" ];
  };

  "crowd_supply" = {
    urls = [
      {
        template = "https://www.crowdsupply.com/search?q={searchTerms}";
      }
    ];
    icon = "https://www.crowdsupply.com/_marvin/images/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@cs" ];
  };

  "dict" = {
    urls = [ { template = "https://www.dict.cc/?s={searchTerms}"; } ];
    icon = "https://www4.dict.cc/img/favicons/favicon4.png";
    updateInterval = weekly;
    definedAliases = [ "@d" ];
  };

  "dl.acm.org" = {
    urls = [
      {
        template = "https://dl.acm.org/action/doSearch?AllField={searchTerms}";
      }
    ];
    icon = "https://dl.acm.org/pb-assets/head-metadata/apple-touch-icon-1574252172393.png";
    updateInterval = weekly;
    definedAliases = [ "@rfacm" ];
  };

  "etsy.com" = {
    urls = [
      {
        template = "https://www.etsy.com/de-en/search?q={searchTerms}";
      }
    ];
    icon = "https://www.etsy.com/images/favicon-16x16.png";
    updateInterval = weekly;
    definedAliases = [ "@e" ];
  };

  "fdroid" = {
    urls = [ { template = "https://search.f-droid.org/?q={searchTerms}&lang=en"; } ];
    icon = "https://f-droid.org/assets/favicon-16x16_7yyppfDSTAVyGb3ycHY84PYjHUwP96NKICAibLRpnXw=.png";
    updateInterval = weekly;
    definedAliases = [ "@fd" ];
  };

  "firefox extensions" = {
    urls = [
      {
        template = "https://addons.mozilla.org/en-US/firefox/search/";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://www.mozilla.org/media/protocol/img/logos/firefox/logo.fedb52c912d6.svg";
    updateInterval = weekly;
    definedAliases = [ "@fe" ];
  };

  "github code search" = {
    urls = [ { template = "https://github.com/search?q=%22{searchTerms}%22&type=code"; } ];
    icon = "https://github.githubassets.com/favicons/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@g" ];
  };

  "github nix code search" = {
    urls = [
      {
        template = "https://github.com/search?q={searchTerms}%20language%3ANix&type=code";
      }
    ];
    icon = "https://github.githubassets.com/favicons/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@gn" ];
  };

  "github rust" = {
    urls = [
      {
        template = "https://github.com/search?q={searchTerms}%20language%3ARust&type=code";
      }
    ];
    icon = "https://github.githubassets.com/favicons/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@gr" ];
  };

  "google maps" = {
    urls = [ { template = "https://www.google.de/maps/place/{searchTerms}"; } ];
    icon = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@m" ];
  };

  "google scholar" = {
    urls = [ { template = "https://scholar.google.com/scholar?q={searchTerms}"; } ];
    icon = "https://scholar.google.com/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@rfg" ];
  };

  "google" = {
    urls = [ { template = "https://www.google.com/search?q={searchTerms}"; } ];
    updateInterval = weekly;
    definedAliases = [ "@gl" ];
  };

  "helix config" = {
    urls = [
      {
        template = "https://docs.helix-editor.com/editor.html?search={searchTerms}";
      }
    ];
    icon = "https://helix-editor.com/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@hc" ];
  };

  "home-manager options" = {
    urls = [
      {
        template = "https://home-manager-options.extranix.com";
        params = [
          {
            name = "release";
            value = "master";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = weekly;
    definedAliases = [ "@hmo" ];
  };

  "haskell hoogle" = {
    urls = [
      {
        template = "https://hoogle.haskell.org/?hoogle={searchTerms}";
      }
    ];
    icon = "https://hoogle.haskell.org/favicon.png";
    updateInterval = weekly;
    definedAliases = [ "@hh" ];
  };

  "kickstarter" = {
    urls = [ { template = "https://www.kickstarter.com/discover/advanced?term={searchTerms}"; } ];
    icon = "https://a.kickstarter.com/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@ki" ];
  };

  "kleinanzeigen" = {
    urls = [ { template = "https://www.kleinanzeigen.de/s-{searchTerms}/k0"; } ];
    icon = "https://www.kleinanzeigen.de/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@kl" ];
  };

  "nix old version" = {
    urls = [
      {
        template = "https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package={searchTerms}";
      }
    ];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = weekly;
    definedAliases = [ "@nv" ];
  };

  "nix packages" = {
    urls = [
      {
        template = "https://search.nixos.org/packages";
        params = [
          {
            name = "channel";
            value = "unstable";
          }
          {
            name = "type";
            value = "packages";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = weekly;
    definedAliases = [ "@np" ];
  };

  "nixos options" = {
    urls = [
      {
        template = "https://search.nixos.org/options";
        params = [
          {
            name = "channel";
            value = "unstable";
          }
          {
            name = "type";
            value = "packages";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = weekly;
    definedAliases = [ "@no" ];
  };

  "nixos wiki" = {
    urls = [
      {
        template = "https://wiki.nixos.org/w/rest.php/v1/search/title?q={searchTerms}&limit=10";
      }
    ];
    icon = "https://wiki.nixos.org/nixos.png";
    updateInterval = weekly;
    definedAliases = [ "@hw" ];
  };

  "package dhl" = {
    urls = [ { template = "https://www.dhl.de/de/privatkunden/pakete-empfangen/verfolgen.html?piececode={searchTerms}"; } ];
    icon = "https://www.dhl.de/.resources/dhl/webresources/assets/icons/favicons/favicon-16x16.png";
    updateInterval = weekly;
    definedAliases = [ "@pd" ];
  };

  "package hermes" = {
    urls = [ { template = "https://www.myhermes.de/empfangen/sendungsverfolgung/sendungsinformation#{searchTerms}"; } ];
    icon = "https://www.myhermes.de/assets/touchicons/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@ph" ];
  };

  "pixabay" = {
    urls = [ { template = "https://pixabay.com/images/search/{searchTerms}"; } ];
    icon = "https://thepiratebay.org/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@pixabay" ];
  };

  "piratebay" = {
    urls = [ { template = "https://thepiratebay.org/search.php?q={searchTerms}&cat=0"; } ];
    updateInterval = weekly;
    definedAliases = [ "@pb" ];
  };

  "public apis" = {
    urls = [ { template = "https://github.com/public-apis/public-apis/search?q={searchTerms}"; } ];
    updateInterval = weekly;
    definedAliases = [ "@pubapi" ];
  };

  "rust book" = {
    urls = [ { template = "https://doc.rust-lang.org/book/?search={searchTerms}"; } ];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@rb" ];
  };

  "rust by examlpe" = {
    urls = [
      {
        template = "https://doc.rust-lang.org/rust-by-example/index.html?search={searchTerms}";
      }
    ];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@re" ];
  };

  "rust doc" = {
    urls = [
      {
        template = "https://docs.rs/releases/search?query={searchTerms}";
      }
    ];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@rd" ];
  };

  "rust language reference" = {
    urls = [
      {
        template = "https://doc.rust-lang.org/reference/index.html?search={searchTerms}";
      }
    ];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@rr" ];
  };

  "rust std" = {
    urls = [
      {
        template = "https://doc.rust-lang.org/std/index.html?search={searchTerms}";
      }
    ];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@rs" ];
  };

  "rust themis" = {
    urls = [
      {
        template = "file:///home/markus/themis/target/doc/bench_client/index.html?search={searchTerms}";
      }
    ];
    icon = "https://www.rust-lang.org/static/images/favicon.svg";
    updateInterval = weekly;
    definedAliases = [ "@rt" ];
  };

  "steam" = {
    urls = [
      {
        template = "https://store.steampowered.com/search/?term={searchTerms}";
      }
    ];
    icon = "https://store.steampowered.com/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@st" ];
  };

  "thingiverse" = {
    urls = [ { template = "https://www.thingiverse.com/search?q={searchTerms}"; } ];
    icon = "https://cdn.thingiverse.com/site/img/favicons/favicon-192x192.png";
    updateInterval = weekly;
    definedAliases = [ "@th" ];
  };

  "youtube" = {
    urls = [
      {
        template = "https://www.youtube.com/results?search_query={searchTerms}";
      }
    ];
    icon = "https://www.youtube.com/s/desktop/2253fa3d/img/logos/favicon_144x144.png";
    # icon = "https://www.gstatic.com/youtube/img/branding/youtubelogo/svg/youtubelogo.svg";
    updateInterval = weekly;
    definedAliases = [ "@y" ];
  };

  "zerspanungsbude" = {
    urls = [ { template = "https://forum.zerspanungsbude.net/search.php?keywords={searchTerms}"; } ];
    icon = "https://forum.zerspanungsbude.net/favicon.ico";
    updateInterval = weekly;
    definedAliases = [ "@z" ];
  };

}
