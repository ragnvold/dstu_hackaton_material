#!/usr/bin/env perl
use strict;
use warnings;
use JSON::XS;
use Data::Dumper;
use DBI;
use utf8;
use autodie;

my $db = DBI->connect("dbi:SQLite:dbname=database.db");
my $d  = decode_json(
    do { local $/; <>; }
);
my $feats   = $d->{features};
my $gettype = sub {
    return $db->selectrow_array(
        q(SELECT warehouse_type_id FROM warehouse_types where type = ?),
        {}, @_ );
};
my ($wht) = $gettype->("warehouse");
my ($sht) = $gettype->("shop");
for my $feat (@$feats) {
    my $name = $feat->{properties}->{iconCaption};
    $db->do(
        q(INSERT INTO warehouses(longitude, latitude, name, warehouse_type_id)
VALUES(?, ?, ?, ?)),
        {},
        @{ $feat->{geometry}->{coordinates} },
        $name,
        $name =~ /клиент/i ? $sht : $wht
    );
}
