AVAHIFILE=/etc/avahi/services/squid-deb-proxy-desktop.service

# not used at the moment since various things can get broken.
concat_file_from_dir() {
      # the .d directory
      DIR="$1"
      # the target file
      FILE="$2"
      # (optional) additional file append to $FILE
      ADDITIONAL_FILE_TO_CAT="$3"
      cat > $FILE <<EOF 
# WARNING: this file is auto-generated from the files in
#          $DIR
#          on squid-deb-proxy-desktop (re)start, do NOT edit here
EOF
      if [ -n "$ADDITIONAL_FILE_TO_CAT" ]; then
          cat "$ADDITIONAL_FILE_TO_CAT" >> "$FILE"
      fi

      for f in "$DIR"/*; do
          cat "$f" >> "$FILE"
      done
}

pre_start() {
  if [ -x /usr/sbin/squid ]; then
      SQUID=/usr/sbin/squid
  elif  [ -x /usr/sbin/squid3 ]; then
      SQUID=/usr/sbin/squid3
  else
      echo "No squid binary found"
      exit 1
  fi

  # ensure all cache dirs are there
  install -d -o proxy -g proxy -m 750 /var/cache/squid-deb-proxy-desktop/
  install -d -o proxy -g proxy -m 750 /var/log/squid-deb-proxy-desktop/
  if [ ! -d /var/cache/squid-deb-proxy-desktop/00 ]; then
   $SQUID -z -N -f /etc/squid-deb-proxy-desktop/squid-deb-proxy-desktop.conf
  fi
}

post_start() {
  # create avahi service
  PORT=$(grep http_port /etc/squid-deb-proxy-desktop/squid-deb-proxy-desktop.conf|cut -d' ' -f2)
  if [ -n "$PORT" ] && [ -d /etc/avahi/services/ ]; then
      (umask 022 && cat > $AVAHIFILE << EOF
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
	<name replace-wildcards="yes">Squid deb proxy on %h</name>
	<service protocol="ipv6">
		<type>_apt_proxy._tcp</type>
		<port>$PORT</port>
	</service>
	<service protocol="ipv4">
		<type>_apt_proxy._tcp</type>
		<port>$PORT</port>
	</service>
</service-group>
EOF
)
  fi
}

post_stop() {
  # remove avahi file again
  rm -f $AVAHIFILE
}

# from the squid3 debian init script
find_cache_dir () {
        w="     " # space tab
        res=`sed -ne '
                s/^'$1'['"$w"']\+[^'"$w"']\+['"$w"']\+\([^'"$w"']\+\).*$/\1/p;
                t end;
                d;
                :end q' < $CONFIG`
        [ -n "$res" ] || res=$2
        echo "$res"
}

