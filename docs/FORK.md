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

Gå till **Settings → Secrets and variables → Actions → New repository secret** i repot och skapa:

| Namn | Värde |
|---|---|
| `KEYSTORE_BASE64` | hela innehållet i `alderplus-release.b64` |
| `KEYSTORE_PASSWORD` | lösenordet för nyckelfilen |
| `KEY_ALIAS` | `alderplus` |
| `KEY_PASSWORD` | lösenordet för nyckeln |

Eller med GitHub CLI:

```bash
gh secret set KEYSTORE_BASE64 < alderplus-release.b64
gh secret set KEYSTORE_PASSWORD
gh secret set KEY_ALIAS --body alderplus
gh secret set KEY_PASSWORD
```

Radera `alderplus-release.b64` när du är klar.

## 3. Bygga och släppa

- **Testbygge:** varje push till `main` bygger en APK. Den finns under **Actions → körningen → Artifacts → AlderPlus-…**.
- **Release:** skapa och pusha en tagg. Versionen tas från taggen:

  ```bash
  git tag v1.2
  git push origin v1.2
  ```

  Flödet bygger, signerar och lägger upp `AlderPlus.apk` under **Releases**. Installerade TV-appar hittar den via den inbyggda uppdateringen.

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
