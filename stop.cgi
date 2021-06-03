#!/usr/local/bin/perl
# stop.cgi
# Stop the Emby daemon

require './emby-lib.pl';
&ReadParse();
&error_setup($text{'stop_err'});
$err = &stop_emby();
&error($err) if ($err);
&webmin_log("stop");
&redirect("");
