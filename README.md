Kantinens `infoscreen`-maskine
==============================

Alt indhold der bliver vist ligger i `content`-mappen.  Der er også mapperne
`content-disabled` og `background`, men disse er ikke vigtige for grundlæggende
kørsel.

Dette er repoet for kantinens `infoscreen`-maskine.  Den kører softwaren
<https://github.com/datalogisk-kantineforening/kantinfo>.

Se også vores repo for kantinens `cokepc`-maskine:
<https://github.com/datalogisk-kantineforening/cokepc>.

Maskinen har en opløsning på 1920x1080, så design efter det.


Opsætning
---------

Infoskærmsmaskinen i kantinen (herefter bare kaldet `infoscreen`) køres på en
Odroid, men en hvilken som helst datamat vil være okay.

`infoscreen` er en Odroid som er monteret bag skærmen i kantinen.  Man kan logge
ind på maskinen ved at ssh'e til `odroid@diku.kantinen.org` og derfra ssh'e
videre til `infoscreen` (eftersom K@ntinen har mere end én Odroid).  Niels skal
have ens offentlige nøgle før dette virker.  Løsenet på maskinen for
`odroid`-brugeren er bare `odroid`.  Hvis man vil automatisere denne loggen ind,
kan man indtaste følgende i filen `.ssh/config` på din egen maskine:

```
Host infoscreen
  Hostname infoscreen
  User odroid
  ProxyCommand ssh -W %h:%p odroid@diku.kantinen.org
```

Så kan man logge ind ved at køre `ssh infoscreen`.

Når maskinen starter op, bliver brugeren `odroid` logget ind i en session, der
kører scriptet `.xinitrc`.  Vi har vedhæftet vores `.xinitrc` i dette repo; se
filen `xinitrc` (den er symlinket på odroiden).

Dette scripts primære ansvar er at starte en `tmux`-session der kører
infoskærmsscriptet, samt starte en enkel window manager.  Hvis du vil tilføje
andre baggrundsprocesser og deslige, så start dem her.

Et cronjob (`sudo crontab -e`) sørger for at genstarte maskinen hver morgen
klokken 6.  Dette er for at sikre at der aldrig sniger sig noget ind i
opsætningen der ikke kan overleve en genstart.

Ny Opsætning
------------
Infoskærmen i kantinen har fået nyt SD-kort. Diverse hardware detajler og
log ind informationer gælder stadig. Når vi har konstateret at den kører stabilt
bør gamle informationer slettes.

Filen '/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf' logger
brugeren odroid ind og slår skærmenstrømbesparingsmekanismen fra, hvis denne af en grund skulle være blevet slået til.

Når brugeren er logget ind kører scriptet `.xsessionrc` fra odroids hjemmemappe.
Vi har vedhæftet vores `.xsession` i dette repo; se filen `xsessionrc` (den er
symlinket på odroiden).

Dette scripts primære ansvar er at starte en `tmux`-session der kører
infoskærmscriptet, samt starte en enkel window manager.  Hvis du vil tilføje
andre baggrundsprocesser og deslige, så start dem her.

Et cronjob (`sudo crontab -e`) sørger for at genstarte maskinen hver mandag
klokken 6.  Dette er for at sikre at der aldrig sniger sig noget ind i
opsætningen der ikke kan overleve en genstart.

Afhængigheder
-------------

Vores `xinitrc`, `xsessionrc` afhænger af disse programmer:

  + `matchbox`: Simpel window manager
  + `xdotool`: Musemarkør-skjuler (mm.)
  + `tmux`: Ligesom screen, men fra BSD
  
For at køre vores IRC-viser-slide kræves også:

  + `sic`: Simpel IRC-klient
  + `toilet`: Tekst-formatterings-program
  + `lxterminal` med fontstørrelse 33
  + skrifttypen Gentium
