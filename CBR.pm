#!/usr/bin/perl -w

#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#    02110-1301, USA

package Finance::Quote::CurrencyRates::CBR;

use strict;
use warnings;

use constant DEBUG => $ENV{DEBUG};
use if DEBUG, 'Smart::Comments';

use XML::LibXML;
use Time::Piece;  # Для получения текущей даты

our $VERSION = '0.04'; # VERSION

sub new
{
  my $self = shift;
  my $class = ref($self) || $self;

  my $this = {};
  bless $this, $class;

  return $this;
}

sub multipliers
{
  my ($this, $ua, $from, $to) = @_;

  unless (exists $this->{cache}) {
    # Получаем сегодняшнюю дату в формате DD/MM/YYYY
    my $date = localtime->strftime('%d/%m/%Y');
    my $url = "https://www.cbr.ru/scripts/XML_daily.asp?date_req=$date";

    my $reply = $ua->get($url);

    return unless ($reply->code == 200);
    my $xml = XML::LibXML->load_xml(string => $reply->content);

    # Извлекаем дату из XML (на всякий случай)
    my $xml_date = $xml->findvalue('/ValCurs/@Date');  # "DD.MM.YYYY"
    $this->{date} = $xml_date;

    my %cache;
    for my $node ($xml->findnodes('//Valute')) {
        my $code = $node->findvalue('./CharCode');
        my $rate = $node->findvalue('./Value');
        $rate =~ s/,/./;  # Заменяем запятую на точку
        $cache{uc($code)} = $rate;
    }

    $cache{RUB} = 1.0;  # Добавляем RUB как базовую валюту

    $this->{cache} = \%cache;

    ### cache : $this->{cache}
  }

  if (exists $this->{cache}->{$from} and exists $this->{cache}->{$to}) {
    ### from : $from, $this->{cache}->{$from}
    ### to   : $to, $this->{cache}->{$to}

    # Возвращаем курсы: сколько RUB за 1 $from и 1 $to
    my $from_rate = $this->{cache}->{$from};
    my $to_rate   = $this->{cache}->{$to};

    # Чтобы Finance::Quote->currency('USD', 'RUB') возвращал (RUB за 1 USD),
    # нужно вернуть (RUB за 1 RUB, RUB за 1 USD) = (1.0, 81.8969)
    # Тогда результат будет: $to_rate / $from_rate = 81.8969 / 1.0 = 81.8969 → 1 USD = 81.8969 RUB
    # Это именно то, что нужно!

    return ($to_rate, $from_rate);
  }

  ### At least one code not found: $from, $to

  return;
}

1;

=head1 NAME

Finance::Quote::CurrencyRates::CBR - Obtain currency rates from
https://www.cbr.ru

=head1 SYNOPSIS

    use Finance::Quote;

    $q = Finance::Quote->new(currency_rates => {order => ['CBR']});

    $value = $q->currency('76.50 RUB', 'USD');

=head1 DESCRIPTION

This module fetches currency rates from https://www.cbr.ru and
provides data to Finance::Quote to convert the first argument to the equivalent
value in the currency indicated by the second argument.

The Central Bank of Russia provides a list of currencies, quoted
against the Russian Ruble (RUB). This module caches the table of rates for the lifetime
of the Finance::Quote object after the first currency conversion.

=head1 Terms & Conditions

Use of https://www.cbr.ru is governed by any terms & conditions of that
site.

Finance::Quote is released under the GNU General Public License, version 2,
which explicitly carries a "No Warranty" clause.

=cut