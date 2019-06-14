# NETIO.SpinaniHDO

Tento článek popisuje nastavení vývojového prostředí a implementaci scriptu pro aktivaci zásuvky **NETIO4x** při sepnutí HDO.

Instalace nástrojů a vývoj je uváděn na platformě *Windows*.

## Instalace Lua

* Nejprve je potřeba stáhnout a nainstalovat podporu pro programovací jazyk Lua.
* Nejlépe stáhnout distribuci z oficiálních stránek: <https://www.lua.org/ftp/>
* Je nezbytně nutné stáhnout verzi > **v5.3**
* Soubory distribuce jsou komprimované pomocí .tar a .gz formátu. Tyto soubory lze dekomprimovat např. pomocí 7-Zip (<https://www.7-zip.org/>)
* Jako poslední krok je potřeba cestu k rozbalené distribuci do proměných prostředí.
* Tedy ve Windows *Ovládací panely\Systém a zabezpečení\Systém*, v levém panelu *Upřesnit nastavení systému*, tlačítko **Proměnné prostředí...**
* V okně je potřeba vybrat proměnnou **Path** a přes tlačítko *Upravit...* otevřít okno editace proměnné.
* Zde stačí pomocí tlačítka *Nový* přidat nový řádek s cesou k *Lua* distribuci. Např.: *D:\Programs\lua-5.3.5*

## Instalace Visual Studio Code
