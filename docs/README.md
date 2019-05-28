# NETIO.SpinaniHDO

*Lua* script pro aktivaci zásuvky **NETIO4x** při sepnutí HDO

Script stahuje *JSON* data z API ČEZu. Data obsahují dobu spínání nízkého tarifu (nt).
Časy se poté použijí pro vytvoření plánu zapínání a vypínání zásuvky.

## Parametry

1. Parametr `region` slouží pro zadání regionu bydliště. Možnosti: *Vychod, Stred, Sever, Zapad, Morava*
2. Parametr `code` slouží pro zadání povelu, kódu, nebo kód povelu. Např.: *A1B6DP1 (povel), P64 (kód), 181 (kód povelu)*

## Ladění

Pro odkrokování kódu je potřeba odkomentovat blok **NETIO MOCK METHODS**. Tento kód simuluje API **NETIO** a vypisuje data do konzole.

## Zdroje
1. API ČEZu https://www.cez.cz/edee/content/sysutf/ds3/data/hdo_data.json (Tento endpoint používá webová aplikace ČEZu a není jisté jestli se rozhraní nebude měnit)
2. Aplikační poznámky **NETIO**: https://www.netio-products.com/cs/aplikacni-poznamky/an07-periodicky-kalendar-pro-rizeni-vystupu-v-textove-podobe-lua-skriptem
