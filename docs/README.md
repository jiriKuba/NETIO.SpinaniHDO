# Popis

Tento článek popisuje nastavení vývojového prostředí a implementaci scriptu pro aktivaci zásuvky **NETIO4x** při sepnutí *HDO* u *ČEZ*.

Instalace nástrojů a vývoj je uváděn na platformě *Windows*.

Script funguje na zařízení **NETIO4x** s verzí firmware **>= 3.3.0**. Od této verze je implementováno parserování *JSON* v *LUA* scriptu.

## Instalace Lua

* Nejprve je potřeba stáhnout a nainstalovat podporu pro programovací jazyk Lua.
* Nejlépe stáhnout distribuci z oficiálních stránek: <https://www.lua.org/ftp/>
* Je nezbytně nutné stáhnout verzi **> 5.3**
* Soubory distribuce jsou komprimované pomocí .tar a .gz formátu. Tyto soubory lze dekomprimovat např. pomocí 7-Zip (<https://www.7-zip.org/>)
* Jako poslední krok je potřeba nastavit cestu k rozbalené distribuci do proměnných prostředí.
* Tedy ve Windows: *Ovládací panely\Systém a zabezpečení\Systém*, v levém panelu *Upřesnit nastavení systému*, tlačítko **Proměnné prostředí...**
* V okně je potřeba vybrat proměnnou **Path** a přes tlačítko *Upravit...* otevřít okno editace proměnné.
* Zde stačí pomocí tlačítka *Nový* přidat nový řádek s cestou k *Lua* distribuci. Např.: *D:\Programs\lua-5.3.5*

![Nastavení proměnné](https://github.com/jiriKuba/NETIO.SpinaniHDO/blob/master/docs/images/EnvironmentVariables.PNG?raw=true "Nastavení proměnné prostředí")

## Instalace Visual Studio Code

* Visual Studio Code lze ideálně stáhnout a nainstalovat z oficiálního webu: <https://code.visualstudio.com/>

* Po instalaci je nutné doinstalovat rozšíření pro podporu *Lua*. Osvědčilo se rozšíření *Lua Debug*: <https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug>

* Rozšíření *Lua Debug* vyžaduje verzi *Lua* **5.3** nebo **5.4**!

![VS Code Lua Debug](https://github.com/jiriKuba/NETIO.SpinaniHDO/blob/master/docs/images/VsLua.PNG?raw=true "VS Code Lua Debug")

## Debug ve Visual Studio Code

* Ladění *Lua* programu ve *Visual Studio Code* se provádí stejně jako u jakýkoliv jiného programovacího jazyka. Tedy:
  * **F5** - Start/pokračovat
  * **F10** - Další krok
  * **F11** - Vstup do metody
  * **Shift + F11** Výstup z metody
  * **Ctrl + Shift + F5** Restart
  * **Shift + F5** Zastavit

* Pro debug *NETIO* zásuvek byl vytvořen *Lua* script, který částečně implementuje referenční metody a vytváří mock objekty pro testování.
* Tento script je možné zavést pomocí příkazu: `require "netioMock"`.
* Po zavedení tohoto scriptu je možné krokovat vlastní *NETIO* scripty, nebo kódy z [aplikačních poznámek](https://www.netio-products.com/cs/aplikacni-poznamky) *NETIO*.
* ! Zatím není pokryt veškerý výčet referenčních metod a objektů. Veškerý výčet je možné shlédnout zde: <https://wiki.netio-products.com/index.php?title=NETIO_Lua_Reference>

## HDO

* *HDO* je zkratka pro hromadné dálkové ovládání. Jedná se o způsob regulace odběru elektrické energie na dálku. (Zdroj wikipedie: <https://cs.wikipedia.org/wiki/HDO>).

* Tedy pomocí HDO energetické společnosti zapínají a vypínají nízký tarif (*nt* - dříve "noční proud") na odběrném místě.

* Na *nt* mají nárok odběrná místa se sazbou pro ohřev vody nebo vytápění elektrickým proudem. Jsou to distribuční sazby: **D25d, D26d, D35d, D45d, D55d, D56d** nebo **D61d**

* Obvykle bývá jedna zásuvka u bojleru, nebo kotle přizpůsobena tak, že do ní jde elektrický proud pouze v případě sepnutého *nt* (speciální jistič v rozvodné skříni).

* A protože *nt* využívá celé odběrné místo, tak se vyplatí plánovat zapínání elektrických spotřebičů na dobu sepnutí HDO, tedy kdy je aktivní *nt*.

* Čas a dobu sepnutí HDO řídí distributor elektrické energie, tedy v ČR  [ČEZ](https://www.cezdistribuce.cz/cs/pro-zakazniky/spinani-hdo.html) a [E.ON](https://www.eon.cz/domacnosti/kontakty-podpora/poruchy-a-technicke-dotazy/cas-nizkeho-tarifu/jake-jsou-casy-spinani-hdo).

* Tyto údaje mají časově omezenou platnost, tedy se vyplatí použít nějaké automatizované řešení pro plánování spínání zásuvek při *nt*. Proto byl vytvořen tento script pro plánování spínání chytré zásuvky *NETIO*.

## Popis scriptu

* Tento script stahuje data z API ČEZ. Data se transformují do formátu, který lze snáze zpracovat a přiřadí se k jednotlivým časovým úsekům stav zásuvky. Transformované data se prohledají a vybere se časový úsek, který odpovídá aktuálnímu datu a času. Pro tento úsek se načte plán, nastaví se stav zásuvky (např. *zapnuto*) a vypočítá se doba, za kdy se má sepnout další plán. Jako poslední krok se zaplánuje doba, kdy se má zpracovat další plán a kdy dojde ke změně stavu zásuvky (např. na *vypnuto*).
* Celý script by se dal rozložit do šesti částí: *konfigurace, debug, start, stažení dat, transformace dat, naplánování*. Následuje detailní popis jednotlivých částí. Níže je popis jednotlivých částí:

### Konfigurace

* Chování scriptu lze ovlivnit následujícími parametry:
  * `region` - Region odběrného místa. Možnosti: *Vychod, Stred, Sever, Zapad, Morava*.
  * `code` - Povel, kód, nebo kód povelu, který se nalézá na elektroměru. Např.: *A1B6DP1*
  * `baseApiUrl` - Hlavní část *URL* adresy ČEZ API pro získání časů spínání *HDO*. Tato adresa byla získána z webu *ČEZ*, konkrétně z webové aplikace pro zjištění [časů spínání HDO](https://www.cez.cz/cs/podpora/technicke-zalezitosti/pro-odberatele/hdo.html)
  * `initialState` - Počáteční stav, ve kterém je zásuvka ihned po startu scriptu a ve kterém zůstává pokud se nepodaří získat data z ČEZ API. Hodnota stavu je reprezentována řetězcem se 4 čísly, kde každé číslo v řetězci značí stav jednotlivé zdířky zásuvky. Číslo může nabývat hodnotu 0-5 (0 - vypnuto, 1 - zapnuto, 2 - krátké vypnutí, 3 - krátké zapnutí, 4 - přepnutí stavu, 5 - zachován předešlí stav). Např.: `0000` pro vypnutí všech zdířek zásuvky.
  * `onState` - Stav pro případ, kdy je HDO zapnuto. Stejný formát jako `initialState`.
  * `offState` - Stav pro případ, kdy je HDO vypnuti. Stejný formát jako `initialState`.
  * `shortTimeMs` - Doba v milisekundách pro krátké zapnutí/vypnutí.

### Debug

* Tato sekce je určena pro ladění scriptu a obsahuje nastavení výsledku mock metod pro stažení dat z ČEZ API. Pro ladění je potřeba odkomentovat tento kus kódu.

* Před nahrání na *NETIO* je lepší tento tento komentovaný kód smazat. Kód obsahuje JSON data, které zbytečně prodlužují dobu nahrání scriptu.

### Start

* Obsahuje pouze nastavení prvotního stavu `initialState` z konfigurace. Tento stav přetrvává pouze pokud došlo k chybě stažení dat z API ČEZ.

* Dále spouští stažení dat (viz. další sekce).

### Stažení dat

* Sekce obsahuje metodu generování celé URL adresy dle parametrů v konfiguraci (sekce č. 1).

* Pokračuje tím, že volá *NETIO* metodu `cgiGet`, která stáhne data z vytvořené URL adresy.

* Data se zvalidují a v případně, že se nepodařilo data načíst, nebo dojde k chybě, dojde za 10 sekund k opětovnému volání API ČEZ.

### Transformace dat

* Následuje transformace dat z API ČEZ do formátu, který je uveden v [aplikačních poznámkách NETIO](https://www.netio-products.com/cs/aplikacni-poznamky/an07-periodicky-kalendar-pro-rizeni-vystupu-v-textove-podobe-lua-skriptem).

* Formát je ve tvaru `aaaa,hh:mm:ss,mtwtfss`. Přesný popis formátu je uveden v aplikačních poznámkách, v kapitole [Nastavení proměnných](https://www.netio-products.com/cs/aplikacni-poznamky/an07-periodicky-kalendar-pro-rizeni-vystupu-v-textove-podobe-lua-skriptem)

* Data z API ČEZ obsahují setříděný seznam časů zapnutí a vypnutí *nt*. Obsahuje vždy 10 těchto intervalů, ale ne všechny mají nastavenou hodnotu. Prázdné intervaly se vynechávají.

* Pro zadané intervaly se vytvoří *NETIO* formát data a nastaví se stav `onState` nebo `offState`.

### Naplánování

* V první řadě se provede test transformovaných dat metodou `checkFormat`. V případě, že jsou data v pořádku, tak zaloguje hlášku `FORMAT OK`. V případě, že data nejsou v pořádku, tak zaloguje chybu, ale stejně dojde k pokusu o spuštění plánu.

* Po testu proběhne výpočet číselné reprezentace času metodou `loadStates`.

* Po výpočtu dojde vyhledání plánu, který by měl právě běžet, tedy najde se stav pro aktuální den a čas. V případě dohledání tohoto plánu dojde k spuštění plánu (nastavení stavu). Dojde k výpočtu času, který zbývá do dalšího plánu. Nastaví se metodou `delay` doba čekání na plán a po uplynutí dojde ke spuštění kódu, který nastaví aktuální a vypočte plán následující. Je použita rekurze, aby plánování nikdy neskončilo.
