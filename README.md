# Wirtschaftsforum Stralsund – Website + Dashboard (GitHub + Supabase)

Statische Website (keine eigene Server-/Node-Infrastruktur nötig) mit
Supabase als Backend: Anmeldungen, Absagen und ein passwortgeschütztes
Admin-Dashboard (Übersicht, Teilnehmendenliste, Absagenliste, Warteliste).

## Struktur

```
index.html          Startseite / Einladung
teilnehmen.html      Anmeldeformular (öffentlich)
absagen.html         Absageformular (öffentlich)
kontakt.html         Kontakt + Datenschutz-Platzhalter
config.js             Supabase-Zugangsdaten (hier eintragen!)
admin/index.html      Admin-Dashboard (passwortgeschützt)
supabase/schema.sql    SQL-Setup für Supabase (Tabellen + Sicherheitsregeln)
```

## Schritt 1 – Supabase-Projekt anlegen

1. Auf [supabase.com](https://supabase.com) kostenlos registrieren, "New project" anlegen.
2. **Wichtig für DSGVO-Konformität**: Bei "Region" unbedingt eine **EU-Region wählen**
   (z. B. "Frankfurt (eu-central-1)"), damit die Daten in der EU verarbeitet werden.
3. Warten, bis das Projekt fertig aufgesetzt ist (dauert ca. 1–2 Minuten).

## Schritt 2 – Datenbank einrichten

1. Im Supabase-Dashboard: **SQL Editor** → **New query**.
2. Inhalt von `supabase/schema.sql` komplett hineinkopieren und **Run** klicken.
3. Das legt drei Tabellen an (`participants`, `cancellations`, `waitlist`) und
   aktiviert Row Level Security (RLS) mit sinnvollen Berechtigungen:
   - Website-Besucher:innen dürfen nur **neue** Anmeldungen/Absagen einfügen.
   - Nur eingeloggte Admin-Nutzer:innen dürfen die Listen lesen/bearbeiten.

## Schritt 3 – Admin-Zugang anlegen

1. Im Supabase-Dashboard: **Authentication** → **Users** → **Add user**.
2. Deine Admin-E-Mail-Adresse und ein sicheres Passwort eintragen.
3. Das sind die Zugangsdaten fürs Dashboard (`admin/index.html`).

Optional: Es lassen sich hier beliebig viele weitere Admin-Zugänge anlegen.

## Schritt 4 – Zugangsdaten eintragen

1. Im Supabase-Dashboard: **Settings** → **API**.
2. **Project URL** und **anon public** Key kopieren.
3. In `config.js` eintragen:

```js
window.SUPABASE_URL = 'https://dein-projekt.supabase.co';
window.SUPABASE_ANON_KEY = 'dein-anon-key';
```

Der `anon`-Key ist bewusst öffentlich im Frontend sichtbar – das ist bei
Supabase so vorgesehen, der eigentliche Schutz kommt über die RLS-Regeln aus
Schritt 2. **Trage niemals den `service_role`-Key hier ein.**

## Schritt 5 – Lokal testen (optional, aber empfohlen)

Da alles reines HTML/JS ist, reicht ein einfacher lokaler Webserver
(direktes Öffnen der Datei per Doppelklick funktioniert wegen
Browser-Sicherheitsrichtlinien bei Fetch-Requests nicht zuverlässig):

```bash
# im Projektordner:
python3 -m http.server 8000
```

Dann: http://localhost:8000 (Website) und http://localhost:8000/admin/ (Dashboard).

Teste:
1. Über `teilnehmen.html` eine Test-Anmeldung abschicken.
2. Im Dashboard einloggen und prüfen, ob die Anmeldung erscheint.
3. Check-in, Absagen-Button, Person hinzufügen, Warteliste, Suche und
   Excel-Export durchklicken.

## Schritt 6 – Auf GitHub veröffentlichen (privates Repo)

Für DSGVO-konformen Betrieb legen wir das Repo **privat** an – dann ist der Code (inkl. `config.js`)
nicht öffentlich einsehbar.

1. Auf github.com: **New repository** → Name vergeben → **Private** auswählen → **Create repository**
   (kein README/.gitignore/License bei der Erstellung anhaken, das Repo muss leer sein).
2. Im Projektordner:

```bash
git remote add origin https://github.com/DEIN-NUTZERNAME/DEIN-REPO.git
git push -u origin main
```

(Der Ordner ist bereits ein fertiges Git-Repository mit erstem Commit – `git init` ist nicht
mehr nötig.)

## Schritt 7 – Hosting einrichten (Netlify statt GitHub Pages)

GitHub Pages kann **private** Repos nur mit einem kostenpflichtigen GitHub-Account veröffentlichen.
Für ein privates Repo im kostenlosen Tarif nutzen wir stattdessen **Netlify** (Vercel funktioniert
nach demselben Prinzip als Alternative):

1. Auf [netlify.com](https://netlify.com) mit dem GitHub-Account anmelden.
2. **Add new site** → **Import an existing project** → GitHub auswählen → dein Repo auswählen.
3. Build-Einstellungen: **kein Build-Command nötig** (Publish directory: `/` bzw. Root),
   da es sich um eine rein statische Seite handelt.
4. **Deploy site** klicken. Nach kurzer Zeit ist die Seite live unter einer
   `*.netlify.app`-Adresse (später auf eigene Domain umstellbar).
5. Das Dashboard ist erreichbar unter `https://DEIN-PROJEKT.netlify.app/admin/`.
6. Bei jedem `git push` wird die Seite automatisch neu deployed.

Netlify verarbeitet dabei nur die statischen Dateien und technische Zugriffsdaten (z. B.
IP-Adressen in Server-Logs) – die eigentlichen Formulardaten (Anmeldungen/Absagen) gehen direkt
an Supabase, nicht über Netlify. Für Netlify als Auftragsverarbeiter bietet Netlify einen
Data Processing Addendum (DPA) an, den du in den Account-Einstellungen findest.

## DSGVO-Checkliste

**Bereits umgesetzt:**

- ✅ Schriftart (Inter) wird **lokal gehostet** (`fonts.css` + `fonts/`), nicht mehr über
  Google Fonts geladen – dadurch werden keine IP-Adressen an Google übertragen (das war als
  reine Google-Fonts-CDN-Einbindung ohne Einwilligung ein bekannter Abmahngrund, u. a. nach
  einem Urteil des LG München).
- ✅ Row Level Security in Supabase: Website-Besucher:innen können nur einfügen, nicht die
  Listen anderer Teilnehmender einsehen.
- ✅ Einwilligungs-Checkbox (Pflichtfeld) bei Anmeldung und Absage, mit Verlinkung zur
  Datenschutzerklärung.
- ✅ Strukturierte Datenschutzerklärung auf `kontakt.html` mit allen nach Art. 13 DSGVO
  erforderlichen Punkten (Verantwortlicher, Zwecke, Rechtsgrundlage, Empfänger, Speicherdauer,
  Betroffenenrechte) – **aber mit Platzhaltern in eckigen Klammern**, die noch ausgefüllt werden
  müssen (siehe unten).
- ✅ GitHub-Repo als **privat** vorgesehen, Hosting über Netlify statt öffentlichem GitHub Pages.

**Das musst du noch selbst erledigen:**

1. In `kontakt.html` im Abschnitt "Datenschutzerklärung" alle `[eckigen Klammern]` durch eure
   echten Angaben ersetzen (Verantwortlicher, Anschrift, genaue Speicherdauer, gewählte
   Supabase-Region, Hosting-Anbieter).
2. Bei Supabase-Projekterstellung die **EU-Region** wählen (siehe Schritt 1).
3. Den Auftragsverarbeitungsvertrag (DPA) von Supabase und Netlify in den jeweiligen
   Account-Einstellungen prüfen/akzeptieren.
4. GitHub-Repo auf **Private** stellen (siehe Schritt 6).
5. Die fertige Datenschutzerklärung **von einer Rechtsberatung prüfen lassen**, bevor die Seite
   live geht – ich bin kein Anwalt und dieser Text ersetzt keine Rechtsberatung.
6. Einen Prozess festlegen, wie Löschanfragen (Recht auf Löschung) gehandhabt werden – aktuell
   nur manuell über das Dashboard möglich (Teilnehmer:in/Absage-Eintrag entfernen).

## Wichtige Hinweise

- **`config.js` landet mit im Git-Repository.** Der `anon`-Key ist bei Supabase bewusst
  clientseitig sichtbar vorgesehen – der eigentliche Schutz kommt über die RLS-Regeln aus
  `schema.sql`, nicht über Geheimhaltung dieses Keys. Da wir hier auf ein **privates Repo**
  setzen, ist der Code ohnehin nicht öffentlich einsehbar.
- **Absage-Formular verschiebt nicht automatisch.** Aus Sicherheitsgründen
  (RLS erlaubt anonymen Nutzer:innen nur das Einfügen, nicht das Löschen)
  landet eine öffentliche Absage nur in der Absagenliste. War die Person
  vorher als Teilnehmer:in registriert, muss das im Dashboard einmal manuell
  über den "Absagen"-Button in der Teilnehmendenliste nachgezogen werden.
- **Datenschutzerklärung** auf `kontakt.html` ist jetzt strukturell vollständig,
  enthält aber noch Platzhalter in eckigen Klammern – siehe DSGVO-Checkliste oben.
- **`EVENT_CAPACITY`** (Kapazität fürs Auslastungsdiagramm) steht fest im
  Code von `admin/index.html` (aktuell 150) – bei Bedarf dort anpassen.
- Weitere Admin-Zugänge lassen sich jederzeit über **Authentication → Users**
  in Supabase hinzufügen oder entfernen.
