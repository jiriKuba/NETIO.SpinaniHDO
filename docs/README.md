# Popis

Tento článek popisuje nastavení vývojového prostředí a implementaci scriptu pro aktivaci zásuvky **NETIO4x** při sepnutí HDO.

Instalace nástrojů a vývoj je uváděn na platformě *Windows*.

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

* Čas a dobu sepnutí HDO řídí distributor elektrické energie, tedy v ČR  [ČEZ](https://www.cezdistribuce.cz/cs/pro-zakazniky/spinani-hdo.html) a [E.ON](https://www.eon.cz/domacnosti/kontakty-podpora/poruchy-a-technicke-dotazy/cas-nizkeho-tarifu/jake-jsou-casy-spinani-hdo).

* Tyto údaje mají časově omezenou platnost, tedy se vyplatí použít nějaké automatizované řešení pro plánování spínání zásuvek při *nt*. Proto byl vytvořen tento script pro chytrou zásuvku *NETIO*.
