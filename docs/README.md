# Popis

Tento článek popisuje nastavení vývojového prostředí a implementaci scriptu pro aktivaci zásuvky **NETIO4x** při sepnutí *HDO* u *ČEZ*.

Instalace nástrojů a vývoj je uváděn na platformě *Windows*.

Script funguje na zařízení s verzí firmware **>= 3.3.0**. Od této verze je implementováno parserování *JSON* v *LUA* scriptu.

## Instalace Lua

* Nejprve je potřeba stáhnout a nainstalovat podporu pro programovací jazyk Lua.
* Nejlépe stáhnout distribuci z oficiálních stránek: <https://www.lua.org/ftp/>
* Je nezbytně nutné stáhnout verzi **> 5.3**
* Soubory distribuce jsou komprimované pomocí .tar a .gz formátu. Tyto soubory lze dekomprimovat např. pomocí 7-Zip (<https://www.7-zip.org/>)
* Jako poslední krok je potřeba cestu k rozbalené distribuci do proměnných prostředí.
* Tedy ve Windows *Ovládací panely\Systém a zabezpečení\Systém*, v levém panelu *Upřesnit nastavení systému*, tlačítko **Proměnné prostředí...**
* V okně je potřeba vybrat proměnnou **Path** a přes tlačítko *Upravit...* otevřít okno editace proměnné.
* Zde stačí pomocí tlačítka *Nový* přidat nový řádek s cestou k *Lua* distribuci. Např.: *D:\Programs\lua-5.3.5*

![Nastavení proměnné](https://github.com/jiriKuba/NETIO.SpinaniHDO/blob/master/docs/images/EnvironmentVariables.PNG?raw=true "Nastavení proměnné prostředí")

## Instalace Visual Studio Code

* Visual Studio Code lze ideálně stáhnout a nainstalovat z oficiálního webu: <https://code.visualstudio.com/>

* Po instalaci je nutné doinstalovat rozšíření pro podporu *Lua*. Osvědčilo se rozšíření *Lua Debug*: <https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug>

* Rozšíření *Lua Debug* vyžaduje verzi *Lua* **5.3** nebo **5.4**!

![VS Code Lua Debug](https://github.com/jiriKuba/NETIO.SpinaniHDO/blob/master/docs/images/EVsLua.PNG?raw=true "VS Code Lua Debug")

## Debug ve Visual Studio Code

* Ladění *Lua* programu ve Visual Studio Code se provádí stejně jako u jakýkoliv jiného programovacího jazyka. Tedy:
  * **F5** - Start/pokračovat
  * **F10** - Další krok
  * **F11** - Vstup do metody
  * **Shift + F11** Výstup z metody
  * **Ctrl + Shift + F5** Restart
  * **Shift + F5** Zastavit

* Pro debug *NETIO* zásuvek byl vytvořen *Lua* script, který částečně implementuje referenční metody a vytváří mock objekty pro testování.
* Tento script je možné zavést pomocí příkazu: `require "netioMock"`.
* Po zavední tohoto scriptu je možné krokovat vlastní kódy nebo kódy z aplikačních poznámek *NETIO*.
* ! Zatím není pokryt veškerý výčet referenčních metod a objektů. Veškerý výčet je možné shlédnout zde: <https://wiki.netio-products.com/index.php?title=NETIO_Lua_Reference>

## HDO

* *HDO* je zkratka pro hromadné dálkové ovládání. Jedná se o způsob regulace odběru elektrické energie na dálku. (Zdroj wikipedie: <https://cs.wikipedia.org/wiki/HDO>).

* Tedy pomocí HDO energetické společnosti zapínají a vypínají nízký tarif (*nt* - dříve "noční proud") na odběrném místě.

* Na *nt* mají nárok odběrná místa se sazbou pro ohřev vody nebo vytápění elektrickým proudem.

* Obvykle bývá jedna zásuvka u bojleru nebo kotle přizpůsobena tak, že do ní jde elektrický proud pouze v případě sepnutého *nt* (speciální jistič v rozvodné skříni).

* A protože *nt* využívá celé odběrné místo, tak se vyplatí plánovat zapínání elektrických spotřebičů na dobu sepnutí HDO.

* Odběrné místo využívá *nt* pokud má nastavenou distribuční sazbu na **D25d, D26d, D35d, D45d, D55d, D56d** nebo **D61d**

* Čas a dobu sepnutí HDO řídí distributor elektrické energie, tedy v ČR  [ČEZ](https://www.cezdistribuce.cz/cs/pro-zakazniky/spinani-hdo.html) a [E.ON](https://www.eon.cz/domacnosti/kontakty-podpora/poruchy-a-technicke-dotazy/cas-nizkeho-tarifu/jake-jsou-casy-spinani-hdo).

* Tyto údaje mají časově omezenou platnost, tedy se vyplatí použít nějaké automatizované řešení pro plánování spínání zásuvek při *nt*. Proto byl vytvořen tento script pro chytrou zásuvku *NETIO*.

## Popis scriptu

* Tento script stahuje data z API ČEZ. Data se transformují do formátu, který lze snáze spracovat a přiřadí se k jednotlivým časovým úsekům stav zásuvky. Transformované data se prohledají a vybere se časový úsek, který odpovídá aktuálnímu datumu a času. Pro tento úsek se načte plán, nastaví se stav zásuvky (např. *zapnuto*) a vypočítá se doba, za kdy se má sepnout další plán. Jako poslední krok se zaplánuje doba kdy se má zpracovat další plán a kde dojde ke změně stavu zásuvky (např. na *vypnuto*).
* Celý script by se dal rozložit do šesti částí: *konfigurace, debug, stažení dat, transformace dat, naplánování, start*. Následuje detailní popis jednotlivých částí. Níže je popis jednotlivých částí:

### Konfigurace

* Chování scriptu lze ovlivnit následujícími parametry:
  * `region` - Region odběrného místa. Možnosti: *Vychod, Stred, Sever, Zapad, Morava*.
  * `code` - Povel, kód, nebo kód povelu, který se nalézá na elektroměru.
  * `baseApiUrl` - Hlavní část *URL* adresy API pro získání časů spínání *HDO*. Tato adresa bylý získána z webu *ČEZ*, konkrétně z webové aplikace pro zjištění [časů spínání HDO](https://www.cez.cz/cs/podpora/technicke-zalezitosti/pro-odberatele/hdo.html)
  * `initialState` - Počáteční stav, ve kterém je zásuvka ihned po startu scriptu a ve kterém zůstává pokud se nepodaří získat data z API. Hodnota stavu je reprezentována řetězcem se 4 čísly, kde každé číslo v řetězci značí stav jednotlivé zásuvky. Číslo může nabývat hodnotu 0-5 (0 - vypnuto, 1 - zapnuto, 2 - krátké vypnutí, 3 - krátké zapnutí, 4 - přepnutí stavu, 5 - zachován předešlí stav).
  * `onState` - Stav pro případ, kdy je HDO zapnuto.
  * `offState` - Stav pro případ, kdy je HDO vypnuti.
  * `shortTimeMs` - Doba v milisekundách pro krátké zapnutí/vypnutí.

### Debug

* **TODO**

### Stažení dat

* **TODO**

### transformace dat

* **TODO**

### naplánování

* **TODO**

### start

* **TODO**
