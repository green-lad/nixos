{ config, pkgs, ... }: {
  config.xdg.configFile = {
    "neomutt/mailcap" = {
      enable = true;
      text = ''
        text/*; xdg-open %s; needsterminal=false
        application/*; xdg-open %s; needsterminal=false
        image/*; xdg-open %s; needsterminal=false
      '';
    };
  };

  config.programs.msmtp.enable = true;
  config.programs.mbsync.enable = true;

  config.services.mbsync = {
    enable = true;
    frequency = "*:0/2";
  };

  config.accounts.email.accounts.Personal = {
    address = "markus.schoetz@fau.de";
    realName = "Markus Schoetz";
    userName = "markus.schoetz@fau.de";
    passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.imap_password.path}";

    mbsync = {
      enable = true;
      create = "maildir";
      remove = "both";
      expunge = "both";
    };

    msmtp.enable = true;

    smtp = {
      host = "smtp-auth.fau.de";
      port = 587;
      tls.useStartTls = true;
    };

    imap = {
      host = "faumail.fau.de";
      port = 143;
      tls.useStartTls = true;
    };

    neomutt = {
      enable = true;
      sendMailCommand = "${pkgs.msmtp}/bin/msmtp -a Personal";
      extraMailboxes = [
        "Archive"
        "Drafts"
        "Sent"
        "Trash"
      ];

      # extraConfig = ''
      #   set pgp_default_key = "${pgpKey}"
      #   set pgp_sign_as = "${pgpKey}"
      # '';
    };

    signature = {
      showSignature = "append";
      text = ''
        Markus Schoetz
        https://green-lad.xyz
      '';
    };

    # gpgConfig.gpg = {
    #   encryptByDefault = true;
    #   signByDefault = true;
    # };

    primary = true;
    flavor = "plain";
    folders = {
      inbox = "INBOX";
      drafts = "Drafts";
      sent = "Sent";
      trash = "Trash";
    };
  };

  config.programs.neomutt = {
    enable = true;
    vimKeys = true;
    editor = "hx";
    binds = [
      {
        action = "complete-query";
        key = "<Tab>";
        map = [ "editor" ];
      }
      {
        action = "group-reply";
        key = "R";
        map = [
          "index"
          "pager"
        ];
      }
    ];
    macros = [
      {
        action = "<sidebar-prev><sidebar-open>";
        key = "[";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "<sidebar-next><sidebar-open>";
        key = "]";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "!systemctl --user start mbsync &^M";
        key = "<F5>";
        map = [ "index" ];
      }
      {
        action = "<change-folder>${config.accounts.email.accounts.Personal.maildir.absPath}/INBOX<enter>";
        key = "P";
        map = [ "index" ];
      }
      {
        action = "<save-message>+Archive<enter>";
        key = "A";
        map = [
          "index"
          "pager"
        ];
      }
      {
        key = "a";
        map = [
          "index"
          "pager"
        ];
        action = "<pipe-message>khard add-email<return> 'Add sender to address book'";
      }
      {
        action = "<save-message>?<tab>";
        key = "s";
        map = [ "index" ];
      }
      {
        action = "<tag-prefix><save-message>+Trash<enter>";
        key = "S";
        map = [ "index" ];
      }
      {
        action = "<pipe-message>${pkgs.urlscan}/bin/urlscan -dc<Enter>";
        key = "\\Cl";
        map = [
          "attach"
          "compose"
          "index"
          "pager"
        ];
      }
      {
        key = "<Tab>";
        action = "<complete-query>";
        map = [ "editor" ];
      }
      {
        key = "<return>";
        action = "<display-message>";
        map = [ "index" ];
      }
      {
        key = "N";
        action = "<toggle-new>";
        map = [ "index" ];
      }
      {
        key = "e";
        action = "<pipe-entry>${pkgs.helix}/bin/hx<enter>";
        map = [ "attach" ];
      }
    ];

    sidebar = {
      enable = true;
      width = 40;
      format = "%B%?F? [%F]?%* %?N?%N/?%S";
      shortPath = false;
    };

    settings = {
      abort_key = "<Esc>";
      allow_ansi = "yes";
      beep = "no";
      beep_new = "no"; # bell on new mails
      confirmappend = "no"; # don't ask, just do!
      crypt_chars = ''"󰈡 "'';
      date_format = ''"%d %h %H:%M"'';
      delete = "yes"; # don't ask, just do
      edit_headers = "yes"; # show headers when composing
      fast_reply = "yes"; # skip to compose when replying
      fcc_attach = "yes"; # save attachments with the body
      flag_chars = ''"󰩹󰩺 󰇰󰇮 "'';
      folder = "${config.home.homeDirectory}/Mail";
      forward_quote = "yes"; # include message in forwards
      imap_check_subscribed = "yes";
      include = "yes"; # include message in replies
      mail_check = "0"; # how often look for new mail
      mail_check_stats = "yes";
      mailcap_path = "${config.xdg.configHome}/neomutt/mailcap";
      mark_old = "no"; # read/new is good enough for me
      markers = "no"; # show '+' at start of wrapped lines
      move = "no"; # gmail does that
      pager_context = "3";
      pager_format = ''"[ %n ] [ %T %s ]%* [ 󰸗 %{!%Y %a %d %b %H:%M} ] %?X?[ 󰁦 %X ]? [  %P ]%|─"'';
      pager_index_lines = "10"; # shows 10 lines of index when pager is active
      pager_stop = "yes";
      query_command = ''"${pkgs.khard}/bin/khard email --parsable %s"'';
      quit = "yes"; # don't ask, just do!!
      reply_to = "yes"; # reply to Reply to: field
      reverse_name = "yes"; # reply as whomever it was to
      sort = "threads";
      sort_aux = "reverse-last-date-received";
      sort_re = "yes";
      status_chars = ''" 󰁦"'';
      status_format = ''"[ %D ] %?r?[ 󰇰 %m ] ?%?n?[ 󰇮 %n ] ?%?d?[ 󰩹 %d ] ?%?t?[  %t ] ?%?F?[  %F ] ?%?p?[  %p ]?%|─"'';
      text_flowed = "yes";
      timeout = "0";
      tmpdir = "${config.xdg.configHome}/neomutt/tmp";
      to_chars = ''" "'';
      wait_key = "no"; # don't ask "press key to continue"
    };
  };
}
