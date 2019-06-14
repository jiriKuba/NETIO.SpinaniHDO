# NETIO.SpinaniHDO

Tento článek popisuje nastavení vývojového prostředí a implementaci scriptu pro aktivaci zásuvky **NETIO4x** při sepnutí HDO.

Instalace nástrojů a vývoj je uváděn na platformě *Windows*.

## Instalace Lua

* Nejprve je potřeba stáhnout a nainstalovat podporu pro programovací jazyk Lua.
* Nejlépe stáhnout distribuci z oficiálních stránek: <https://www.lua.org/ftp/>
* Je nezbytně nutné stáhnout verzi > **5.3**
* Soubory distribuce jsou komprimované pomocí .tar a .gz formátu. Tyto soubory lze dekomprimovat např. pomocí 7-Zip (<https://www.7-zip.org/>)
* Jako poslední krok je potřeba cestu k rozbalené distribuci do proměných prostředí.
* Tedy ve Windows *Ovládací panely\Systém a zabezpečení\Systém*, v levém panelu *Upřesnit nastavení systému*, tlačítko **Proměnné prostředí...**
* V okně je potřeba vybrat proměnnou **Path** a přes tlačítko *Upravit...* otevřít okno editace proměnné.
* Zde stačí pomocí tlačítka *Nový* přidat nový řádek s cesou k *Lua* distribuci. Např.: *D:\Programs\lua-5.3.5*

![Nastavení proměnné](https://github.com/jiriKuba/NETIO.SpinaniHDO/tree/master/docs/images/EnvironmentVariables.png "Nastavení proměnné prostředí")

## Instalace Visual Studio Code

* Visual Studio Code lze ideálně stáhnout a nainstalovat z oficiálního webu: <https://code.visualstudio.com/>

* Po instalaci je nutné doinstalovat rozšíření pro podporu *Lua*. Osvětčilo se rozšíření *Lua Debug*: <https://marketplace.visualstudio.com/items?itemName=actboy168.lua-debug>

* Rozšíření *Lua Debug* vyžaduje verzi *Lua* **5.3** nebo **5.4**!

## Debug ve Visual Studio Code
