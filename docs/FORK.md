# Alder+ (fork av Alder)

Alder+ är en fork av [aradhyas8/Alder](https://github.com/aradhyas8/Alder), släppt under samma licens (GPL-3.0).

Skillnader mot originalet:

| | Alder | Alder+ |
|---|---|---|
| App-id | `dev.alder` | `se.cashew.alder` (kan ligga bredvid originalet på TV:n) |
| Namn på TV:n | Alder | Alder+ |
| Uppdateringar hämtas från | aradhyas8/Alder | cashew1975/Alder-cashew- |
| Bygge | Lokalt | GitHub Actions (`.github/workflows/build.yml`) |

Eftersom app-id:t är nytt har Alder+ egna profiler och inställningar. Logga in med Stremio-koden en gång till.

## 1. Skapa signeringsnyckeln (en gång)

Android godtar bara en uppdatering som är signerad med **samma nyckel** som den installerade appen. Nyckeln är alltså det som binder ihop alla framtida versioner.

> Tappar du nyckeln kan TV:n inte uppdateras längre, och appen måste avinstalleras och installeras om. Läcker nyckeln kan någon annan bygga "uppdateringar". Spara den i en lösenordshanterare och lägg den aldrig i repot (`.gitignore` blockerar redan `*.jks`).

Kör på din egen dator (kräver Java, `keytool` följer med JDK):

```bash
keytool -genkeypair -v \
  -keystore alderplus-release.jks \
  -alias alderplus \
  -keyalg RSA -keysize 4096 -validity 10000
```

Du får välja ett lösenord för nyckelfilen och ett för själva nyckeln. Samma lösenord för båda går bra.

## 2. Lägg in nyckeln som secrets i GitHub

Gör om nyckelfilen till text:

```bash
base64 -w0 alderplus-release.jks > alderplus-release.b64   # Linux
```

Nyckeln ska bara kunna användas av release-körningar som du har godkänt. Därför ligger den i en **miljö** (environment), inte bland repots vanliga secrets.

**a. Skapa miljön:** **Settings → Environments → New environment**, döp den till `release` och ställ in:
- **Required reviewers:** lägg till dig själv. Varje release väntar då på att du klickar **Approve** under Actions.
- **Deployment branches and tags:** välj *Selected branches and tags* och lägg till branchen `main` och taggmönstret `v*`.

**b. Lägg in nyckeln i miljön:** under **Environment secrets** i miljön `release`, skapa:

| Namn | Värde |
|---|---|
| `KEYSTORE_BASE64` | hela innehållet i `alderplus-release.b64` |
| `KEYSTORE_PASSWORD` | lösenordet för nyckelfilen |
| `KEY_ALIAS` | `alderplus` |
| `KEY_PASSWORD` | lösenordet för nyckeln |

Eller med GitHub CLI:

```bash
gh secret set KEYSTORE_BASE64 --env release < alderplus-release.b64
gh secret set KEYSTORE_PASSWORD --env release
gh secret set KEY_ALIAS --env release --body alderplus
gh secret set KEY_PASSWORD --env release
```

Radera `alderplus-release.b64` när du är klar. Ligger nycklarna sedan tidigare under **Settings → Secrets and variables → Actions → Repository secrets**, ta bort dem därifrån, annars kringgås godkännandet.

**c. Skydda GitHub-kontot** med passkey eller tvåfaktorsinloggning (**Settings → Password and authentication** på ditt konto). Den som kommer åt kontot kan annars godkänna en release själv.

## 3. Bygga och släppa

- **Testbygge:** varje push till `main` bygger en APK, signerad med debug-nyckeln (testbyggen rör aldrig release-nyckeln). Den finns under **Actions → körningen → Artifacts → AlderPlus-…**.
- **Release med en knapp (enklast):** gå till **Actions → Build → Run workflow**, skriv in en version som är högre än den förra (till exempel `1.3`) och klicka **Run workflow**. Flödet skapar själv taggen `v1.3`. Det fungerar även från mobilen.
- **Release med git:** skapa och pusha en tagg. Versionen tas från taggen:

  ```bash
  git tag v1.3
  git push origin v1.3
  ```

  I båda fallen väntar körningen på ditt godkännande (**Review deployments → Approve** på körningens sida). Sedan bygger flödet, signerar och lägger upp `AlderPlus.apk` under **Releases**. Installerade TV-appar hittar den via den inbyggda uppdateringen, och TV:n frågar alltid innan den installerar.

En release vägrar byggas utan signeringsnyckel, så en osignerad version kan aldrig hamna på TV:n av misstag.

## 4. Första installationen på TV:n

1. Ladda ner `AlderPlus.apk` från senaste release.
2. Installera med *Downloader*, ett USB-minne eller `adb install AlderPlus.apk`.
3. **Valfritt men rekommenderat:** för att själv godkänna varje uppdatering, stäng av *Inställningar → Appar → Särskild åtkomst → Installera okända appar → Alder+* och uppdatera manuellt.

## Hålla forken i takt med originalet

```bash
git remote add upstream https://github.com/aradhyas8/Alder.git
git fetch upstream
git merge upstream/main
```

Konflikter uppstår oftast i `app/build.gradle.kts`, `strings.xml` och `Updates.kt`, alltså raderna som ändrats för forken. Behåll forkens värden där.

## Kodstil: Ponytail-skills

Under `.claude/skills/` ligger skills från [Ponytail](https://github.com/DietrichGebert/ponytail) (v5.3.2, commit `09c434a`, MIT-licens, se `.claude/skills/ponytail/LICENSE`). Originalutvecklaren skriver Alder i samma stil, så forken fortsätter i den. Claude Code läser dem automatiskt när du arbetar i repot.

| Skill | Gör |
|---|---|
| `ponytail` | Minsta ändring som löser hela uppgiften. Återanvänd det som finns, inga onödiga beroenden eller abstraktioner. Säkerhet, validering och felhantering kapas aldrig. |
| `ponytail-review` | Granskar en ändring: logik, säkerhet, prestanda, tester och onödig kod. |
| `ponytail-audit` | Granskar hela repot och rangordnar fynden. |
| `ponytail-debt` | Listar medvetna genvägar (`shortcut:`- och `ponytail:`-kommentarer) som en skuldlista. |
| `ponytail-help` | Snabbreferens. |

Bara skillsen är kopierade. Pluginets hooks (skript som körs automatiskt) och `ponytail-gain` är medvetet utelämnade. Uppdatera genom att kopiera in nya `SKILL.md` från originalrepot.
