{
  pkgs,
  config,
  self,
  ...
}: let
  backend = config.virtualisation.oci-containers.backend;
  backendBin = "${pkgs.${backend}}/bin/${backend}";
in {
  virtualisation.oci-containers.containers = {
    firefly-app = {
      image = "fireflyiii/core@sha256:cbd32feae2068326a240d845425efa3fb773830521dc2ca5a560f964220870a2";
      extraOptions = [
        "--network=firefly_network"
      ];
      environmentFiles = [
        config.sops.templates."firefly-app.env".path
      ];
      dependsOn = [
        "firefly-db"
      ];
      volumes = [
        "/nix/backup/services/firefly/upload:/var/www/html/storage/upload"
      ];
    };
    firefly-db = {
      image = "mariadb@sha256:e4a9a6f3644538084d84aa6ad99a0466d34457b095d06099a99e61f3a73e886c";
      extraOptions = [
        "--network=firefly_network"
      ];
      environmentFiles = [
        config.sops.templates."firefly-database.env".path
      ];
      volumes = [
        "/nix/backup/services/firefly/db:/var/lib/mysql"
      ];
    };
    firefly-cron = {
      image = "alpine@sha256:6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0"
      extraOptions = [
        "--network=firefly_network"
      ];
      dependsOn = [
        "firefly-app"
      ];
      cmd = [
        "/bin/sh"
        "-c"
        "echo \"0 3 * * * wget -qO- http://firefly-app:8080/api/v1/cron/$CRON_TOKEN\" | crontab - && crond -f -L /dev/stdout"
      ];
      environmentFiles = [
        config.sops.templates."firefly-cron.env".path
      ];
    };
    firefly-tunnel = {
      image = "cloudflare/cloudflared@sha256:01d46a12aa9e10f679a6a62b1b2052ce67675845caef268c7929249d08e5fbbd";
      extraOptions = [
        "--network=firefly_network"
      ];
      dependsOn = [
        "firefly-app"
      ];
      cmd = [
        "tunnel"
        "run"
      ];
      environmentFiles = [
        config.sops.templates."firefly-tunnel.env".path
      ];
    };
  };

  systemd.services."${backend}-firefly-db" = {
    wantedBy = ["${backend}-firefly-app.service"];
  };

  systemd.services."${backend}-firefly-app" = {
    wantedBy = [
      "${backend}-firefly-cron.service"
      "${backend}-firefly-tunnel.service"
    ];
  };

  systemd.services.prepare-firefly = {
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "${backend}-firefly-db.service"
      "${backend}-firefly-app.service"
      "${backend}-firefly-cron.service"
      "${backend}-firefly-tunnel.service"
    ];
    script = ''
      mkdir -p /nix/backup/services/firefly/db
      mkdir -p /nix/backup/services/firefly/upload
      ${backendBin} network inspect firefly_network >/dev/null 2>&1 || ${backendBin} network create firefly_network
    '';
  };

  sops.secrets.firefly-cron-token = {
    sopsFile = ../../secrets.yaml;
  };

  sops.secrets.firefly-app-key = {
    sopsFile = ../../secrets.yaml;
  };

  sops.secrets.firefly-database-password = {
    sopsFile = ../../secrets.yaml;
  };

  sops.secrets.firefly-tunnel-token = {
    sopsFile = ../../secrets.yaml;
  };

  sops.templates."firefly-tunnel.env".content = ''
    TUNNEL_TOKEN=${config.sops.placeholder.firefly-tunnel-token}
  '';

  sops.templates."firefly-cron.env".content = ''
    CRON_TOKEN=${config.sops.placeholder.firefly-cron-token}
  '';

  sops.templates."firefly-database.env".content = ''
    MYSQL_RANDOM_ROOT_PASSWORD=yes
    MYSQL_USER=firefly
    MYSQL_PASSWORD=${config.sops.placeholder.firefly-database-password}
    MYSQL_DATABASE=firefly
  '';

  sops.templates."firefly-app.env".content = ''
    # You can leave this on "local". If you change it to production most console commands will ask for extra confirmation.
    # Never set it to "testing".
    APP_ENV=production

    # Set to true if you want to see debug information in error screens.
    APP_DEBUG=false

    # This should be your email address.
    # If you use Docker or similar, you can set this variable from a file by using SITE_OWNER_FILE
    # The variable is used in some errors shown to users who aren't admin.
    SITE_OWNER=rui@maciel.sh

    # The encryption key for your sessions. Keep this very secure.
    # Change it to a string of exactly 32 chars or use something like `php artisan key:generate` to generate it.
    # If you use Docker or similar, you can set this variable from a file by using APP_KEY_FILE
    #
    # Avoid the "#" character in your APP_KEY, it may break things.
    #
    APP_KEY=${config.sops.placeholder.firefly-app-key}

    # Firefly III will launch using this language (for new users and unauthenticated visitors)
    # For a list of available languages: https://github.com/firefly-iii/firefly-iii/tree/main/resources/lang
    #
    # If text is still in English, remember that not everything may have been translated.
    DEFAULT_LANGUAGE=en_US

    # The locale defines how numbers are formatted.
    # by default this value is the same as whatever the language is.
    DEFAULT_LOCALE=equal

    # Change this value to your preferred time zone.
    # Example: Europe/Amsterdam
    # For a list of supported time zones, see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    TZ=Europe/Lisbon

    # TRUSTED_PROXIES is a useful variable when using Docker and/or a reverse proxy.
    # Set it to ** and reverse proxies work just fine.
    TRUSTED_PROXIES=**

    # The log channel defines where your log entries go to.
    # Several other options exist. You can use 'single' for one big fat error log (not recommended).
    # Also available are 'syslog', 'errorlog' and 'stdout' which will log to the system itself.
    # A rotating log option is 'daily', creates 5 files that (surprise) rotate.
    # A cool option is 'papertrail' for cloud logging
    # Default setting 'stack' will log to 'daily' and to 'stdout' at the same time.
    LOG_CHANNEL=stack

    # Log level. You can set this from least severe to most severe:
    # debug, info, notice, warning, error, critical, alert, emergency
    # If you set it to debug your logs will grow large, and fast. If you set it to emergency probably
    # nothing will get logged, ever.
    APP_LOG_LEVEL=notice

    # Audit log level.
    # The audit log is used to log notable Firefly III events on a separate channel.
    # These log entries may contain sensitive financial information.
    # The audit log is disabled by default.
    #
    # To enable it, set AUDIT_LOG_LEVEL to "info"
    # To disable it, set AUDIT_LOG_LEVEL to "emergency"
    AUDIT_LOG_LEVEL=emergency

    #
    # If you want, you can redirect the audit logs to another channel.
    # Set 'audit_stdout', 'audit_syslog', 'audit_errorlog' to log to the system itself.
    # Use audit_daily to log to a rotating file.
    # Use audit_papertrail to log to papertrail.
    #
    # If you do this, the audit logs may be mixed with normal logs because the settings for these channels
    # are often the same as the settings for the normal logs.
    AUDIT_LOG_CHANNEL=

    #
    # Used when logging to papertrail:
    # Also used when audit logs log to papertrail:
    #
    PAPERTRAIL_HOST=
    PAPERTRAIL_PORT=

    # Database credentials. Make sure the database exists. I recommend a dedicated user for Firefly III
    # For other database types, please see the FAQ: https://docs.firefly-iii.org/firefly-iii/faq/self-hosted/#i-want-to-use-sqlite
    # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
    # Use "pgsql" for PostgreSQL
    # Use "mysql" for MySQL and MariaDB.
    # Use "sqlite" for SQLite.
    DB_CONNECTION=mysql
    DB_HOST=firefly-db
    DB_PORT=3306
    DB_DATABASE=firefly
    DB_USERNAME=firefly
    DB_PASSWORD=${config.sops.placeholder.firefly-database-password}
    # leave empty or omit when not using a socket connection
    DB_SOCKET=

    # MySQL supports SSL. You can configure it here.
    # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
    MYSQL_USE_SSL=false
    MYSQL_SSL_VERIFY_SERVER_CERT=true
    # You need to set at least of these options
    MYSQL_SSL_CAPATH=/etc/ssl/certs/
    MYSQL_SSL_CA=
    MYSQL_SSL_CERT=
    MYSQL_SSL_KEY=
    MYSQL_SSL_CIPHER=

    # PostgreSQL supports SSL. You can configure it here.
    # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
    PGSQL_SSL_MODE=prefer
    PGSQL_SSL_ROOT_CERT=null
    PGSQL_SSL_CERT=null
    PGSQL_SSL_KEY=null
    PGSQL_SSL_CRL_FILE=null

    # more PostgreSQL settings
    PGSQL_SCHEMA=public

    # If you're looking for performance improvements, you could install memcached or redis
    CACHE_DRIVER=file
    SESSION_DRIVER=file

    # If you set either of the options above to 'redis', you might want to update these settings too
    # If you use Docker or similar, you can set REDIS_HOST_FILE, REDIS_PASSWORD_FILE or
    # REDIS_PORT_FILE to set the value from a file instead of from an environment variable

    # can be tcp, unix or http
    REDIS_SCHEME=tcp

    # use only when using 'unix' for REDIS_SCHEME. Leave empty otherwise.
    REDIS_PATH=

    # use only when using 'tcp' or 'http' for REDIS_SCHEME. Leave empty otherwise.
    REDIS_HOST=127.0.0.1
    REDIS_PORT=6379

    # Use only with Redis 6+ with proper ACL set. Leave empty otherwise.
    REDIS_USERNAME=
    REDIS_PASSWORD=

    # always use quotes and make sure redis db "0" and "1" exists. Otherwise change accordingly.
    REDIS_DB="0"
    REDIS_CACHE_DB="1"

    # Cookie settings. Should not be necessary to change these.
    # If you use Docker or similar, you can set COOKIE_DOMAIN_FILE to set
    # the value from a file instead of from an environment variable
    # Setting samesite to "strict" may give you trouble logging in.
    COOKIE_PATH="/"
    COOKIE_DOMAIN=
    COOKIE_SECURE=false
    COOKIE_SAMESITE=lax

    # If you want Firefly III to email you, update these settings
    # For instructions, see: https://docs.firefly-iii.org/firefly-iii/advanced-installation/email/#email
    # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
    MAIL_MAILER=log
    MAIL_HOST=null
    MAIL_PORT=2525
    MAIL_FROM=changeme@example.com
    MAIL_USERNAME=null
    MAIL_PASSWORD=null
    MAIL_ENCRYPTION=null
    MAIL_SENDMAIL_COMMAND=

    # Other mail drivers:
    # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
    MAILGUN_DOMAIN=
    MAILGUN_SECRET=

    # If you are on EU region in mailgun, use api.eu.mailgun.net, otherwise use api.mailgun.net
    # If you use Docker or similar, you can set this variable from a file by appending it with _FILE
    MAILGUN_ENDPOINT=api.mailgun.net

    # If you use Docker or similar, you can set these variables from a file by appending them with _FILE
    MANDRILL_SECRET=
    SPARKPOST_SECRET=

    # Firefly III can send you the following messages.
    SEND_ERROR_MESSAGE=true

    # These messages contain (sensitive) transaction information:
    SEND_REPORT_JOURNALS=true

    # Set this value to true if you want to set the location of certain things, like transactions.
    # Since this involves an external service, it's optional and disabled by default.
    ENABLE_EXTERNAL_MAP=false

    # Set this value to true if you want Firefly III to download currency exchange rates
    # from the internet. These rates are hosted by the creator of Firefly III inside
    # an Azure Storage Container.
    # Not all currencies may be available. Rates may be wrong.
    ENABLE_EXTERNAL_RATES=false

    # The map will default to this location:
    MAP_DEFAULT_LAT=38.7223
    MAP_DEFAULT_LONG=9.1393
    MAP_DEFAULT_ZOOM=6

    #
    # Some objects have room for an URL, like transactions and webhooks.
    # By default, the following protocols are allowed:
    # http, https, ftp, ftps, mailto
    #
    # To change this, set your preferred comma separated set below.
    # Be sure to include http, https and other default ones if you need to.
    #
    VALID_URL_PROTOCOLS=

    #
    # Firefly III authentication settings
    #

    #
    # Firefly III supports a few authentication methods:
    # - 'web' (default, uses built in DB)
    # - 'remote_user_guard' for Authelia etc
    # Read more about these settings in the documentation.
    # https://docs.firefly-iii.org/firefly-iii/advanced-installation/authentication
    #
    # LDAP is no longer supported :(
    #
    AUTHENTICATION_GUARD=web

    #
    # Remote user guard settings
    #
    AUTHENTICATION_GUARD_HEADER=REMOTE_USER
    AUTHENTICATION_GUARD_EMAIL=

    #
    # Firefly III generates a basic keypair for your OAuth tokens.
    # If you want, you can overrule the key with your own (secure) value.
    # It's also possible to set PASSPORT_PUBLIC_KEY_FILE or PASSPORT_PRIVATE_KEY_FILE
    # if you're using Docker secrets or similar solutions for secret management
    #
    PASSPORT_PRIVATE_KEY=
    PASSPORT_PUBLIC_KEY=

    #
    # Extra authentication settings
    #
    CUSTOM_LOGOUT_URL=

    # You can disable the X-Frame-Options header if it interferes with tools like
    # Organizr. This is at your own risk. Applications running in frames run the risk
    # of leaking information to their parent frame.
    DISABLE_FRAME_HEADER=false

    # You can disable the Content Security Policy header when you're using an ancient browser
    # or any version of Microsoft Edge / Internet Explorer (which amounts to the same thing really)
    # This leaves you with the risk of not being able to stop XSS bugs should they ever surface.
    # This is at your own risk.
    DISABLE_CSP_HEADER=false

    # If you wish to track your own behavior over Firefly III, set valid analytics tracker information here.
    # Nobody uses this except for me on the demo site. But hey, feel free to use this if you want to.
    # Do not prepend the TRACKER_URL with http:// or https://
    # The only tracker supported is Matomo.
    # You can set the following variables from a file by appending them with _FILE:
    TRACKER_SITE_ID=
    TRACKER_URL=

    #
    # Firefly III supports webhooks. These are security sensitive and must be enabled manually first.
    #
    ALLOW_WEBHOOKS=false

    #
    # The static cron job token can be useful when you use Docker and wish to manage cron jobs.
    # 1. Set this token to any 32-character value (this is important!).
    # 2. Use this token in the cron URL instead of a user's command line token that you can find in /profile
    #
    # For more info: https://docs.firefly-iii.org/firefly-iii/advanced-installation/cron/
    #
    # You can set this variable from a file by appending it with _FILE
    #
    STATIC_CRON_TOKEN=${config.sops.placeholder.firefly-cron-token}

    # You can fine tune the start-up of a Docker container by editing these environment variables.
    # Use this at your own risk. Disabling certain checks and features may result in lots of inconsistent data.
    # However if you know what you're doing you can significantly speed up container start times.
    # Set each value to true to enable, or false to disable.

    # Set this to true to build all locales supported by Firefly III.
    # This may take quite some time (several minutes) and is generally not recommended.
    # If you wish to change or alter the list of locales, start your Docker container with
    # `docker run -v locale.gen:/etc/locale.gen -e DKR_BUILD_LOCALE=true`
    # and make sure your preferred locales are in your own locale.gen.
    DKR_BUILD_LOCALE=false

    # Check if the SQLite database exists. Can be skipped if you're not using SQLite.
    # Won't significantly speed up things.
    DKR_CHECK_SQLITE=true

    # Run database creation and migration commands. Disable this only if you're 100% sure the DB exists
    # and is up to date.
    DKR_RUN_MIGRATION=true

    # Run database upgrade commands. Disable this only when you're 100% sure your DB is up-to-date
    # with the latest fixes (outside of migrations!)
    DKR_RUN_UPGRADE=true

    # Verify database integrity. Includes all data checks and verifications.
    # Disabling this makes Firefly III assume your DB is intact.
    DKR_RUN_VERIFY=true

    # Run database reporting commands. When disabled, Firefly III won't go over your data to report current state.
    # Disabling this should have no impact on data integrity or safety but it won't warn you of possible issues.
    DKR_RUN_REPORT=true

    # Generate OAuth2 keys.
    # When disabled, Firefly III won't attempt to generate OAuth2 Passport keys. This won't be an issue, IFF (if and only if)
    # you had previously generated keys already and they're stored in your database for restoration.
    DKR_RUN_PASSPORT_INSTALL=true

    # Leave the following configuration vars as is.
    # Unless you like to tinker and know what you're doing.
    APP_NAME=FireflyIII
    BROADCAST_DRIVER=log
    QUEUE_DRIVER=sync
    CACHE_PREFIX=firefly
    PUSHER_KEY=
    IPINFO_TOKEN=
    PUSHER_SECRET=
    PUSHER_ID=
    DEMO_USERNAME=
    DEMO_PASSWORD=
    FIREFLY_III_LAYOUT=v1

    #
    # If you have trouble configuring your Firefly III installation, DON'T BOTHER setting this variable.
    # It won't work. It doesn't do ANYTHING. Don't believe the lies you read online. I'm not joking.
    # This configuration value WILL NOT HELP.
    #
    # Notable exception to this rule is Synology, which, according to some users, will use APP_URL to rewrite stuff.
    #
    # This variable is ONLY used in some of the emails Firefly III sends around. Nowhere else.
    # So when configuring anything WEB related this variable doesn't do anything. Nothing
    #
    # If you're stuck I understand you get desperate but look SOMEWHERE ELSE.
    #
    APP_URL=https://firefly.maciel.sh
  '';
}
