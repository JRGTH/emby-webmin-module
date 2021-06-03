#!/usr/local/bin/perl
# restart.cgi
# Restart the Emby daemon

require './emby-lib.pl';
&ReadParse();
&error_setup($text{'restart_err'});
$err = &restart_emby();
&error($err) if ($err);
&webmin_log("restart");
&redirect("");
