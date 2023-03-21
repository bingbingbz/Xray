#!/bin/sh

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget "https://github.com/AYJCSGM/mikutap/archive/master.zip" -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- "https://raw.githubusercontent.com/bingbingbz/Xray/main/etc/Caddyfile" | sed -e "1c :$PORT" -e "s/\$DOMAIN/$DOMAIN/g" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- "https://raw.githubusercontent.com/bingbingbz/Xray/main/etc/xray.json" | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$SSENCYPT/$SSENCYPT/g" >/xray.json

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $FILES
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
tor &

/xray -config /xray.json &
head -n 30 /etc/caddy/Caddyfile

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
