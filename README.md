# Finance::Quote::CurrencyRates::CBR
`Finance::Quote::CurrencyRates::CBR` is a Perl module for retrieving currency exchange rates from the official website of the Central Bank of the Russian Federation (CBR) via `Finance::Quote`. The module allows GNUCash and other applications using `Finance::Quote` to fetch up-to-date currency rates for the **current date**.

## Features
- Fetches currency rates from the official CBR website: `https://www.cbr.ru/scripts/XML_daily.asp`
- Requests rates for the **current date** (in `DD/MM/YYYY` format)
- Supports all currencies listed in the CBR daily rate feed

## Requirements
- Perl 5.10+
- `Finance::Quote` module (version 1.64+ recommended)
- `XML::LibXML` module
- `Time::Piece` module

## Installation
### 1. Where to copy the file
Place the `CBR.pm` file into the directory where `Finance::Quote` looks for `CurrencyRates` modules:

#### For Strawberry Perl (or other system Perl installations):
```
<perl_site_lib>/Finance/Quote/CurrencyRates/CBR.pm
```

For example:
```
C:/ProgramData/StrawberryPerl/perl/site/lib/Finance/Quote/CurrencyRates/CBR.pm
```

### 2. Add `CBR` to the `@CURRENCY_RATES_MODULES` list
Open the `Quote.pm` file and find the line:
```perl
@CURRENCY_RATES_MODULES = qw(
    AlphaVantage
    CurrencyFreaks
    ECB
    FinanceAPI
    Fixer
    OpenExchange
    YahooJSON
);
```

Add `CBR` to this list:
```perl
@CURRENCY_RATES_MODULES = qw(
    AlphaVantage
    CurrencyFreaks
    ECB
    FinanceAPI
    Fixer
    OpenExchange
    YahooJSON
    CBR
);
```

### 3. Set the environment variable
To make `Finance::Quote` use `CBR` as the **primary** source for currency rates, set the environment variable:
```bash
export FQ_CURRENCY=CBR
```

or on Windows:
```cmd
set FQ_CURRENCY=CBR
```

## Usage
### In `Finance::Quote`
```perl
use Finance::Quote;

my $q = Finance::Quote->new(currency_rates => {order => ['CBR']});
my $rate = $q->currency("USD", "RUB");
print "1 USD = $rate RUB\n";
```

### In GNUCash
After installation and configuration:
- Open GNUCash
- Go to `Tools → Price Editor`
- Click `Get Online Quotes`
- GNUCash will use the CBR for fetching rates (if `CBR` is set as the source)

Or via the command line:
```bash
gnucash-cli -Q dump currency USD RUB
```

Should output:
```
1 USD = 80.7498 RUB
```

## See Also
- [Finance::Quote](https://metacpan.org/release/Finance-Quote)
- [GNUCash](https://www.gnucash.org/)
- [Central Bank of the Russian Federation](https://www.cbr.ru/)
