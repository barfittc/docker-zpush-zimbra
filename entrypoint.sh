#!/bin/sh +x

ZPUSH_CONFIG='/var/www/html/config.php'
PROTO="https://"

#Prepare config file

if [ ! -f  "${ZPUSH_CONFIG}.bkp" ]; then
    # Backun original file
    cp $ZPUSH_CONFIG $ZPUSH_CONFIG.bkp
    echo '#Zimbra config' >> $ZPUSH_CONFIG
    echo "define('MAPI_SERVER', 'file:///var/run/zarafa');" >> $ZPUSH_CONFIG
    echo "define('ZPUSH_URL', '$PROTO$ZPUSH_HOST/Microsoft-Server-ActiveSync');" >> $ZPUSH_CONFIG
    echo "define('ZIMBRA_URL', '$PROTO$ZIMBRA_HOST');" >> $ZPUSH_CONFIG
fi

# Set timezone if exist
if  [ ! -z $TIMEZONE ]; then  
    sed -i "/TIMEZONE/s/'[^']*'/'$TIMEZONE'/2" $ZPUSH_CONFIG
fi

apache2-foreground 